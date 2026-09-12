import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_app/services/order_validator.dart';

void main() {
  group('OrderValidator.validateCliente', () {
    test('rejeita valor nulo ou vazio', () {
      expect(OrderValidator.validateCliente(null), isNotNull);
      expect(OrderValidator.validateCliente(''), isNotNull);
      expect(OrderValidator.validateCliente('   '), isNotNull);
    });

    test('rejeita nome muito curto', () {
      expect(OrderValidator.validateCliente('A'), isNotNull);
    });

    test('aceita nome válido', () {
      expect(OrderValidator.validateCliente('Ana Souza'), isNull);
    });
  });

  group('OrderValidator.validateVeiculo', () {
    test('rejeita vazio', () {
      expect(OrderValidator.validateVeiculo(''), isNotNull);
    });

    test('aceita valor preenchido', () {
      expect(OrderValidator.validateVeiculo('Fiat Uno 2015'), isNull);
    });
  });

  group('OrderValidator.validateDescricao', () {
    test('rejeita vazio', () {
      expect(OrderValidator.validateDescricao(''), isNotNull);
    });

    test('aceita descrição preenchida', () {
      expect(OrderValidator.validateDescricao('Troca de óleo'), isNull);
    });
  });

  group('OrderValidator.validateValor', () {
    test('rejeita vazio', () {
      expect(OrderValidator.validateValor(''), isNotNull);
    });

    test('rejeita valor não numérico', () {
      expect(OrderValidator.validateValor('abc'), isNotNull);
    });

    test('rejeita valor zero ou negativo', () {
      expect(OrderValidator.validateValor('0'), isNotNull);
      expect(OrderValidator.validateValor('-10'), isNotNull);
    });

    test('aceita valor positivo com ponto', () {
      expect(OrderValidator.validateValor('180.50'), isNull);
    });

    test('aceita valor positivo com vírgula (padrão brasileiro)', () {
      expect(OrderValidator.validateValor('180,50'), isNull);
    });
  });
}
