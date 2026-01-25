import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

class SupabaseConfiguration {
  final bool isConfigured;
  final SupabaseClient? client;
  const SupabaseConfiguration({required this.isConfigured, this.client});
}

final supabaseConfigProvider = Provider<SupabaseConfiguration>(
  (_) => const SupabaseConfiguration(isConfigured: false),
);
