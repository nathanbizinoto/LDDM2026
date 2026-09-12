import 'package:flutter/foundation.dart';

import '../models/service_order.dart';

class OrderRepository extends ChangeNotifier {
  final List<ServiceOrder> _orders;

  OrderRepository({List<ServiceOrder>? seed}) : _orders = seed ?? _seedOrders();

  List<ServiceOrder> get orders => List.unmodifiable(_orders);

  static List<ServiceOrder> _seedOrders() {
    final agora = DateTime.now();
    return [
      ServiceOrder(
        id: '1',
        cliente: 'Marcos Andrade',
        veiculo: 'Fiat Uno 2015',
        descricao: 'Barulho na suspensão dianteira',
        valor: 320.0,
        status: OrderStatus.emAndamento,
        dataCriacao: agora.subtract(const Duration(days: 1)),
      ),
      ServiceOrder(
        id: '2',
        cliente: 'Juliana Reis',
        veiculo: 'Honda Civic 2019',
        descricao: 'Troca de óleo e filtros',
        valor: 180.0,
        dataCriacao: agora.subtract(const Duration(hours: 3)),
      ),
    ];
  }

  ServiceOrder addOrder({
    required String cliente,
    required String veiculo,
    required String descricao,
    required double valor,
  }) {
    final order = ServiceOrder(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      cliente: cliente,
      veiculo: veiculo,
      descricao: descricao,
      valor: valor,
      dataCriacao: DateTime.now(),
    );
    _orders.insert(0, order);
    notifyListeners();
    return order;
  }

  void advanceStatus(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;
    final atual = _orders[index];
    final proximo = atual.status.next;
    if (proximo == null) return;
    _orders[index] = atual.copyWith(status: proximo);
    notifyListeners();
  }

  void removeOrder(String orderId) {
    _orders.removeWhere((o) => o.id == orderId);
    notifyListeners();
  }

  ServiceOrder? findById(String orderId) {
    for (final order in _orders) {
      if (order.id == orderId) return order;
    }
    return null;
  }

  double get faturamentoConcluido => _orders
      .where((o) => o.status == OrderStatus.concluida)
      .fold(0.0, (soma, o) => soma + o.valor);
}
