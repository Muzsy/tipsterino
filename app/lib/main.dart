import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app.dart';
import 'src/providers/supabase_provider.dart';

const _supabaseUrlDefine = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKeyDefine = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? supabaseUrl = _supabaseUrlDefine.isNotEmpty
      ? _supabaseUrlDefine
      : null;
  String? supabaseAnonKey = _supabaseAnonKeyDefine.isNotEmpty
      ? _supabaseAnonKeyDefine
      : null;

  if (supabaseUrl == null || supabaseAnonKey == null) {
    final envLoaded = await dotenv
        .load(fileName: '.env')
        .then((_) => true)
        .catchError((_) => false);
    if (envLoaded) {
      supabaseUrl ??= dotenv.env['SUPABASE_URL'];
      supabaseAnonKey ??= dotenv.env['SUPABASE_ANON_KEY'];
    }
  }

  final hasSupabaseConfig =
      (supabaseUrl?.isNotEmpty ?? false) &&
      (supabaseAnonKey?.isNotEmpty ?? false);

  bool isSupabaseReady = false;
  SupabaseClient? client;

  if (hasSupabaseConfig) {
    try {
      await Supabase.initialize(
        url: supabaseUrl!,
        anonKey: supabaseAnonKey!,
        debug: false,
      );
      client = Supabase.instance.client;
      isSupabaseReady = true;
    } catch (error) {
      debugPrint('Supabase initialization failed: $error');
    }
  }

  final supabaseConfig = isSupabaseReady
      ? SupabaseConfiguration(isConfigured: true, client: client)
      : const SupabaseConfiguration(isConfigured: false);

  runApp(
    ProviderScope(
      overrides: [supabaseConfigProvider.overrideWithValue(supabaseConfig)],
      child: const TipsterinoApp(),
    ),
  );
}
