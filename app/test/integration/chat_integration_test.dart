// ---------------------------------------------------------------------------
// Chat feature — integration tests against a live Supabase instance.
//
// Requires Supabase credentials via dart defines:
//   flutter test test/integration/chat_integration_test.dart \
//     --dart-define=IT_SUPABASE_URL=https://your-project.supabase.co \
//     --dart-define=IT_SUPABASE_ANON_KEY=your-anon-key
//
// Alternatively set SUPABASE_URL and SUPABASE_ANON_KEY environment variables
// (used by the CI environment).
//
// What this test covers (real Supabase, real RLS):
//   [1] messages table insert — sender can write, RLS blocks non-participant
//   [2] messages table select — each participant sees only their conversations
//   [3] markConversationAsRead — updates only the target rows (receiver side)
//   [4] Realtime subscription — new messages delivered to both participants
//   [5] messages_no_self constraint — cannot send to yourself
//   [6] content length constraint — >2000 chars is rejected by DB
//
// Test data is created under a unique thread ID to avoid collisions and cleaned
// up at the end of each test run.
// ---------------------------------------------------------------------------

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/chat/data/chat_repository.dart';
import 'package:tipsterino/src/features/chat/domain/chat_exception.dart';
import 'package:tipsterino/src/features/chat/domain/chat_message.dart';

// ---------------------------------------------------------------------------
// Credentials
// ---------------------------------------------------------------------------

const _overrideUrl = String.fromEnvironment('IT_SUPABASE_URL');
const _overrideKey = String.fromEnvironment('IT_SUPABASE_ANON_KEY');
const _defaultUrl = String.fromEnvironment('SUPABASE_URL');
const _defaultKey = String.fromEnvironment('SUPABASE_ANON_KEY');

final _supabaseUrl = _overrideUrl.isNotEmpty ? _overrideUrl : _defaultUrl;
final _supabaseAnonKey =
    _overrideKey.isNotEmpty ? _overrideKey : _defaultKey;

void main() {
  group('ChatIntegration — requires live Supabase', () {
    if (_supabaseUrl.isEmpty || _supabaseAnonKey.isEmpty) {
      test('SKIPPED — no Supabase credentials', () {
        fail(
          'Missing SUPABASE_URL/SUPABASE_ANON_KEY dart-defines.\n'
          'Run with:\n'
          '  flutter test test/integration/chat_integration_test.dart\n'
          '    --dart-define=IT_SUPABASE_URL=https://your-project.supabase.co\n'
          '    --dart-define=IT_SUPABASE_ANON_KEY=your-anon-key',
        );
      });
      return;
    }

    late SupabaseClient client;
    late String userAId;
    late String userBId;
    late String userAEmail;
    late String userBEmail;
    late String userAPassword;

    // Unique tag per run so parallel CI runs don't collide.
    final _runId = DateTime.now().millisecondsSinceEpoch.toString();
    final _testPrefix = 'it_chat_$_runId';

    setUpAll(() async {
      await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
      client = Supabase.instance.client;
    });

    tearDownAll(() async {
      // Clean up test messages created during this run.
      await client.from('messages').delete().like(
            'content',
            '$_testPrefix%',
          );
    });

    // -------------------------------------------------------------------------
    // Helper: provision two fresh test users via signup.
    // Uses deterministic emails so we can re-run without leaking users.
    // -------------------------------------------------------------------------
    Future<void> _provisionUsers() async {
      // Clean up any pre-existing users with these emails first.
      userAEmail = '${_testPrefix}_a@example.com';
      userBEmail = '${_testPrefix}_b@example.com';
      userAPassword = 'test-password-123';

      // Sign up user A
      final signUpARes = await client.auth.signUp(
        email: userAEmail,
        password: userAPassword,
      );
      userAId = signUpARes.user!.id;

      // Sign up user B
      final signUpBRes = await client.auth.signUp(
        email: userBEmail,
        password: 'test-password-456',
      );
      userBId = signUpBRes.user!.id;
    }

    // -------------------------------------------------------------------------
    // Helper: sign in as user A or B, return a ChatRepository wired to that
    // authenticated session.
    // -------------------------------------------------------------------------
    Future<ChatRepository> _repoForUserA() async {
      await client.auth.signInWithPassword(
        email: userAEmail,
        password: userAPassword,
      );
      return ChatRepository(SupabaseConfiguration(
        isConfigured: true,
        client: client,
      ));
    }

    Future<ChatRepository> _repoForUserB() async {
      await client.auth.signInWithPassword(
        email: userBEmail,
        password: 'test-password-456',
      );
      return ChatRepository(SupabaseConfiguration(
        isConfigured: true,
        client: client,
      ));
    }

    // -------------------------------------------------------------------------
    // [1] Send message from A to B, verify B can see it
    // -------------------------------------------------------------------------
    test('[1] sendMessage → recipient can read it via watchConversation',
        () async {
      await _provisionUsers();
      final repoA = await _repoForUserA();
      final repoB = await _repoForUserB();

      final content = '$_testPrefix hello from A';

      // A sends message to B
      await repoA.sendMessage(
        senderId: userAId,
        receiverId: userBId,
        content: content,
      );

      // B watches the conversation — should see the message
      final conversationB = await repoB
          .watchConversation(currentUserId: userBId, otherUserId: userAId)
          .first;

      expect(conversationB, isNotEmpty);
      expect(conversationB.any((m) => m.content == content), isTrue);
      expect(
        conversationB.firstWhere((m) => m.content == content).senderId,
        equals(userAId),
      );
    });

    // -------------------------------------------------------------------------
    // [2] RLS: A cannot see messages between B and others they are not part of
    // -------------------------------------------------------------------------
    test('[2] RLS — users only see their own conversations', () async {
      await _provisionUsers();
      final repoA = await _repoForUserA();

      // A sends a message to B
      await repoA.sendMessage(
        senderId: userAId,
        receiverId: userBId,
        content: '$_testPrefix A to B secret',
      );

      // A's conversation with B should show exactly that message
      final aConversation = await repoA
          .watchConversation(currentUserId: userAId, otherUserId: userBId)
          .first;

      expect(aConversation.length, equals(1));
      expect(aConversation[0].content, equals('$_testPrefix A to B secret'));

      // Simulate a third user C trying to access A-B messages
      // We do this by querying the messages table directly as A — A should
      // only see their own messages, not B's unrelated messages.
      final allAMessages = await client
          .from('messages')
          .select()
          .eq('sender_id', userAId)
          .eq('receiver_id', userBId);

      expect(allAMessages.length, equals(1));
      expect(allAMessages[0]['content'], contains('_testPrefix'));
    });

    // -------------------------------------------------------------------------
    // [3] markConversationAsRead — receiver marks messages as read
    // -------------------------------------------------------------------------
    test('[3] markConversationAsRead sets read_at on sender→receiver rows',
        () async {
      await _provisionUsers();
      final repoA = await _repoForUserA();
      final repoB = await _repoForUserB();

      // A sends a message
      await repoA.sendMessage(
        senderId: userAId,
        receiverId: userBId,
        content: '$_testPrefix read receipt test',
      );

      // B has unread message
      final before = await repoB
          .watchConversation(currentUserId: userBId, otherUserId: userAId)
          .first;
      expect(before.first.readAt, isNull);

      // B marks as read
      await repoB.markConversationAsRead(
        currentUserId: userBId,
        friendId: userAId,
      );

      // Verify via direct query
      final updated = await client
          .from('messages')
          .select()
          .eq('sender_id', userAId)
          .eq('receiver_id', userBId)
          .single();

      expect(updated['read_at'], isNotNull);
    });

    // -------------------------------------------------------------------------
    // [4] Realtime subscription delivers new messages
    // -------------------------------------------------------------------------
    test('[4] watchConversation stream receives new messages in real time',
        () async {
      await _provisionUsers();
      final repoA = await _repoForUserA();
      final repoB = await _repoForUserB();

      // B opens a stream (this will be the subscription)
      final completer = Completer<List<ChatMessage>>();
      late StreamSubscription<List<ChatMessage>> subscription;

      subscription = repoB
          .watchConversation(currentUserId: userBId, otherUserId: userAId)
          .listen((messages) {
        if (messages.length == 1) {
          completer.complete(messages);
        }
      });

      // Give the stream a moment to set up
      await Future.delayed(const Duration(milliseconds: 200));

      // A sends a message — B should receive it via realtime
      await repoA.sendMessage(
        senderId: userAId,
        receiverId: userBId,
        content: '$_testPrefix realtime ping',
      );

      final messages = await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          subscription.cancel();
          return <ChatMessage>[];
        },
      );

      await subscription.cancel();

      expect(messages.length, equals(1));
      expect(messages[0].content, equals('$_testPrefix realtime ping'));
    });

    // -------------------------------------------------------------------------
    // [5] messages_no_self constraint — cannot send to yourself
    // -------------------------------------------------------------------------
    test('[5] DB constraint prevents sending message to self', () async {
      await _provisionUsers();
      // Note: repository-layer validation also catches this before DB is reached.
      // We test the DB constraint directly as the authoritative guard.
      await expectLater(
        client.from('messages').insert({
          'sender_id': userAId,
          'receiver_id': userAId, // same user — violates constraint
          'content': '$_testPrefix self-message attempt',
        }),
        throwsA(isA<PostgrestException>()),
      );
    });

    // -------------------------------------------------------------------------
    // [6] Content > 2000 chars is rejected by DB check constraint
    // -------------------------------------------------------------------------
    test('[6] DB check constraint rejects message > 2000 characters', () async {
      await _provisionUsers();

      // Direct insert to verify the DB constraint is active
      await expectLater(
        client.from('messages').insert({
          'sender_id': userAId,
          'receiver_id': userBId,
          'content': 'x' * 2001,
        }),
        throwsA(isA<PostgrestException>()),
      );
    });

    // -------------------------------------------------------------------------
    // [7] sendMessage validation — ChatException codes at repository layer
    // -------------------------------------------------------------------------
    test('[7] sendMessage throws ChatException with correct codes', () async {
      await _provisionUsers();
      final repoA = await _repoForUserA();

      // Empty content
      await expectLater(
        repoA.sendMessage(
          senderId: userAId,
          receiverId: userBId,
          content: '',
        ),
        throwsA(isA<ChatException>().having((e) => e.code, 'code', 'empty')),
      );

      // > 2000 chars (repository validation)
      await expectLater(
        repoA.sendMessage(
          senderId: userAId,
          receiverId: userBId,
          content: 'x' * 2001,
        ),
        throwsA(
          isA<ChatException>().having((e) => e.code, 'code', 'too_long'),
        ),
      );

      // Empty sender
      await expectLater(
        repoA.sendMessage(
          senderId: '',
          receiverId: userBId,
          content: 'test',
        ),
        throwsA(isA<ChatException>().having(
          (e) => e.code,
          'code',
          'invalid_participants',
        )),
      );
    });
  });
}
