import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/service_order.dart';
import '../services/order_repository.dart';
import '../widgets/status_badge.dart';

final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final repository = context.watch<OrderRepository>();
    final order = repository.findById(orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ordem de serviço')),
        body: const Center(child: Text('Esta ordem de serviço foi removida.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(order.cliente),
        actions: [
          IconButton(
            tooltip: 'Excluir',
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              context.read<OrderRepository>().removeOrder(order.id);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.veiculo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Aberta em ${_dateFormat.format(order.dataCriacao)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            const Text(
              'Problema relatado',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(order.descricao),
            const SizedBox(height: 16),
            const Text(
              'Valor orçado',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              _currencyFormat.format(order.valor),
              style: const TextStyle(fontSize: 18),
            ),
            const Spacer(),
            if (order.status != OrderStatus.concluida)
              ElevatedButton(
                key: const Key('botao_avancar_status'),
                onPressed: () =>
                    context.read<OrderRepository>().advanceStatus(order.id),
                child: Text('Avançar para "${order.status.next!.label}"'),
              ),
          ],
        ),
      ),
    );
  }
}
