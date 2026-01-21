import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app.dart';
import 'src/providers/supabase_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final envLoaded = await dotenv
      .load(fileName: '.env')
      .then((_) => true)
      .catchError((_) => false);

  final supabaseUrl = envLoaded ? dotenv.env['SUPABASE_URL'] : null;
  final supabaseAnonKey = envLoaded ? dotenv.env['SUPABASE_ANON_KEY'] : null;
  bool isSupabaseReady = false;
  SupabaseClient? client;

  if (supabaseUrl != null &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey != null &&
      supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
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
