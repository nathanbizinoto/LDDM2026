enum OrderStatus { aberta, emAndamento, concluida }

extension OrderStatusLabel on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.aberta:
        return 'Aberta';
      case OrderStatus.emAndamento:
        return 'Em andamento';
      case OrderStatus.concluida:
        return 'Concluída';
    }
  }

  OrderStatus? get next {
    switch (this) {
      case OrderStatus.aberta:
        return OrderStatus.emAndamento;
      case OrderStatus.emAndamento:
        return OrderStatus.concluida;
      case OrderStatus.concluida:
        return null;
    }
  }
}

class ServiceOrder {
  final String id;
  final String cliente;
  final String veiculo;
  final String descricao;
  final double valor;
  final OrderStatus status;
  final DateTime dataCriacao;

  const ServiceOrder({
    required this.id,
    required this.cliente,
    required this.veiculo,
    required this.descricao,
    required this.valor,
    this.status = OrderStatus.aberta,
    required this.dataCriacao,
  });

  ServiceOrder copyWith({OrderStatus? status}) {
    return ServiceOrder(
      id: id,
      cliente: cliente,
      veiculo: veiculo,
      descricao: descricao,
      valor: valor,
      status: status ?? this.status,
      dataCriacao: dataCriacao,
    );
  }
}
