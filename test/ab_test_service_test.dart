import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_app/services/ab_test_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('resolveVariant (função pura)', () {
    test('valores abaixo de 0.5 caem na variante A', () {
      expect(resolveVariant(0.0), ABVariant.a);
      expect(resolveVariant(0.4999), ABVariant.a);
    });

    test('valores a partir de 0.5 caem na variante B', () {
      expect(resolveVariant(0.5), ABVariant.b);
      expect(resolveVariant(0.9999), ABVariant.b);
    });
  });

  group('ABTestService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('atribui e persiste uma variante na primeira execução', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = ABTestService(prefs);

      final variantePersistida = prefs.getString('ab_variant');
      expect(variantePersistida, isNotNull);
      expect(service.variant.name, variantePersistida);
    });

    test('mantém a mesma variante entre instâncias (persistência)', () async {
      final prefs = await SharedPreferences.getInstance();
      final primeiraExecucao = ABTestService(prefs);
      final variante = primeiraExecucao.variant;

      final segundaExecucao = ABTestService(prefs);

      expect(segundaExecucao.variant, variante);
    });

    test(
      'registerConversion incrementa apenas o contador da variante atual',
      () async {
        SharedPreferences.setMockInitialValues({'ab_variant': 'a'});
        final prefs = await SharedPreferences.getInstance();
        final service = ABTestService(prefs);

        await service.registerConversion();
        await service.registerConversion();

        expect(service.conversionsA, 2);
        expect(service.conversionsB, 0);
      },
    );

    test('resetExperiment limpa variante e contadores', () async {
      SharedPreferences.setMockInitialValues({
        'ab_variant': 'b',
        'ab_conversions_b': 5,
      });
      final prefs = await SharedPreferences.getInstance();
      final service = ABTestService(prefs);
      expect(service.conversionsB, 5);

      await service.resetExperiment();

      expect(service.conversionsA, 0);
      expect(service.conversionsB, 0);
    });
  });
}
