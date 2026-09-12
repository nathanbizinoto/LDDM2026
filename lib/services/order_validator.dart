/// Regras de validação do formulário de nova ordem de serviço.
///
/// Extraídas como funções puras (sem dependência de widgets) para permitir
/// testá-las isoladamente seguindo o ciclo TDD (red -> green -> refactor).
class OrderValidator {
  const OrderValidator._();

  static String? validateCliente(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o nome do cliente';
    }
    if (value.trim().length < 2) {
      return 'Nome muito curto';
    }
    return null;
  }

  static String? validateVeiculo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o veículo (modelo e ano)';
    }
    return null;
  }

  static String? validateDescricao(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Descreva o problema relatado';
    }
    return null;
  }

  static String? validateValor(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o valor orçado';
    }
    final normalizado = value.trim().replaceAll(',', '.');
    final numero = double.tryParse(normalizado);
    if (numero == null) {
      return 'Valor inválido';
    }
    if (numero <= 0) {
      return 'Valor deve ser maior que zero';
    }
    return null;
  }
}
