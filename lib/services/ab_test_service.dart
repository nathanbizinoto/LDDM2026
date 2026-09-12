import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ABVariant { a, b }

const _prefsVariantKey = 'ab_variant';
const _prefsConversionsAKey = 'ab_conversions_a';
const _prefsConversionsBKey = 'ab_conversions_b';

ABVariant resolveVariant(double randomValue) {
  return randomValue < 0.5 ? ABVariant.a : ABVariant.b;
}

class ABVariantContent {
  final String ctaLabel;
  final Color ctaColor;

  const ABVariantContent({required this.ctaLabel, required this.ctaColor});
}

const abVariantContent = {
  ABVariant.a: ABVariantContent(
    ctaLabel: 'Nova Ordem de Serviço',
    ctaColor: Color(0xFFEF6C00),
  ),
  ABVariant.b: ABVariantContent(
    ctaLabel: '+ Criar OS agora',
    ctaColor: Color(0xFF2E7D32),
  ),
};

class ABTestService extends ChangeNotifier {
  final SharedPreferences _prefs;
  final Random _random;

  late ABVariant _variant;

  ABTestService(this._prefs, {Random? random}) : _random = random ?? Random() {
    _variant = _loadOrAssignVariant();
  }

  ABVariant get variant => _variant;

  ABVariantContent get content => abVariantContent[_variant]!;

  int get conversionsA => _prefs.getInt(_prefsConversionsAKey) ?? 0;

  int get conversionsB => _prefs.getInt(_prefsConversionsBKey) ?? 0;

  ABVariant _loadOrAssignVariant() {
    final stored = _prefs.getString(_prefsVariantKey);
    if (stored == ABVariant.a.name) return ABVariant.a;
    if (stored == ABVariant.b.name) return ABVariant.b;

    final assigned = resolveVariant(_random.nextDouble());
    _prefs.setString(_prefsVariantKey, assigned.name);
    return assigned;
  }

  Future<void> registerConversion() async {
    final key = _variant == ABVariant.a
        ? _prefsConversionsAKey
        : _prefsConversionsBKey;
    final atual = _prefs.getInt(key) ?? 0;
    await _prefs.setInt(key, atual + 1);
    notifyListeners();
  }

  Future<void> resetExperiment() async {
    await _prefs.remove(_prefsVariantKey);
    await _prefs.remove(_prefsConversionsAKey);
    await _prefs.remove(_prefsConversionsBKey);
    _variant = _loadOrAssignVariant();
    notifyListeners();
  }
}
