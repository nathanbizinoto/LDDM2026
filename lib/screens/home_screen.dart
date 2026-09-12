import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/ab_test_service.dart';
import '../services/order_repository.dart';
import '../widgets/order_card.dart';
import 'ab_dashboard_screen.dart';
import 'new_order_screen.dart';
import 'order_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final abTest = context.watch<ABTestService>();
    final repository = context.watch<OrderRepository>();
    final orders = repository.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oficina Rápida'),
        actions: [
          IconButton(
            tooltip: 'Painel do teste A/B',
            icon: const Icon(Icons.insights_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ABDashboardScreen()),
            ),
          ),
        ],
      ),
      body: orders.isEmpty
          ? const Center(child: Text('Nenhuma ordem de serviço cadastrada.'))
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 96),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return OrderCard(
                  order: order,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(orderId: order.id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('cta_nova_os'),
        backgroundColor: abTest.content.ctaColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          abTest.content.ctaLabel,
          style: const TextStyle(color: Colors.white),
        ),
        onPressed: () async {
          final abTestService = context.read<ABTestService>();
          final criada = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const NewOrderScreen()),
          );
          if (criada == true) {
            await abTestService.registerConversion();
          }
        },
      ),
    );
  }
}
