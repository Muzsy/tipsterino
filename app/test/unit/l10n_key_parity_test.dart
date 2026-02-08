import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _readArb(String path) {
  final raw = File(path).readAsStringSync();
  final decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) {
    throw StateError('ARB file is not a JSON object: $path');
  }
  return decoded;
}

Set<String> _realKeys(Map<String, dynamic> arb) {
  return arb.keys.where((key) => !key.startsWith('@')).toSet();
}

Set<String> _metaKeys(Map<String, dynamic> arb) {
  return arb.keys
      .where((key) => key.startsWith('@') && !key.startsWith('@@'))
      .toSet();
}

Set<String> _placeholderNames(Map<String, dynamic> arb, String key) {
  final meta = arb['@$key'];
  if (meta is! Map) {
    return <String>{};
  }
  final placeholders = meta['placeholders'];
  if (placeholders is! Map) {
    return <String>{};
  }
  return placeholders.keys.map((name) => name.toString()).toSet();
}

String _diffMessage(Set<String> leftOnly, Set<String> rightOnly) {
  final left = leftOnly.toList()..sort();
  final right = rightOnly.toList()..sort();
  return 'Missing in HU: $left\nMissing in EN: $right';
}

void main() {
  test('EN/HU ARB key sets are identical and metadata is valid', () {
    final en = _readArb('lib/l10n/app_en.arb');
    final hu = _readArb('lib/l10n/app_hu.arb');

    final enKeys = _realKeys(en);
    final huKeys = _realKeys(hu);

    final onlyInEn = enKeys.difference(huKeys);
    final onlyInHu = huKeys.difference(enKeys);
    expect(
      onlyInEn.isEmpty && onlyInHu.isEmpty,
      isTrue,
      reason: _diffMessage(onlyInEn, onlyInHu),
    );

    for (final metaKey in _metaKeys(en)) {
      final base = metaKey.substring(1);
      expect(
        en.containsKey(base),
        isTrue,
        reason: 'Orphan EN meta key: $metaKey',
      );
    }

    for (final metaKey in _metaKeys(hu)) {
      final base = metaKey.substring(1);
      expect(
        hu.containsKey(base),
        isTrue,
        reason: 'Orphan HU meta key: $metaKey',
      );
    }

    final keys = enKeys.toList()..sort();
    for (final key in keys) {
      final enPlaceholders = _placeholderNames(en, key);
      final huPlaceholders = _placeholderNames(hu, key);
      if (enPlaceholders.isEmpty && huPlaceholders.isEmpty) {
        continue;
      }

      final onlyInEnPlaceholder = enPlaceholders.difference(huPlaceholders);
      final onlyInHuPlaceholder = huPlaceholders.difference(enPlaceholders);
      expect(
        onlyInEnPlaceholder.isEmpty && onlyInHuPlaceholder.isEmpty,
        isTrue,
        reason:
            'Placeholder mismatch for "$key". '
            'Only in EN: ${onlyInEnPlaceholder.toList()..sort()}, '
            'only in HU: ${onlyInHuPlaceholder.toList()..sort()}',
      );
    }
  });
}
