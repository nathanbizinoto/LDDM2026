import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/ab_test_service.dart';

class ABDashboardScreen extends StatelessWidget {
  const ABDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final abTest = context.watch<ABTestService>();
    final totalConversoes = abTest.conversionsA + abTest.conversionsB;

    return Scaffold(
      appBar: AppBar(title: const Text('Painel do teste A/B')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Este dispositivo está na variante',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    abTest.variant == ABVariant.a ? 'A' : 'B',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Botão exibido: "${abTest.content.ctaLabel}"'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Conversões registradas (toques em "criar OS" que resultaram em uma ordem salva)',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _VariantBar(
            label: 'Variante A — "Nova Ordem de Serviço"',
            value: abTest.conversionsA,
            total: totalConversoes,
            color: abVariantContent[ABVariant.a]!.ctaColor,
          ),
          const SizedBox(height: 12),
          _VariantBar(
            label: 'Variante B — "+ Criar OS agora"',
            value: abTest.conversionsB,
            total: totalConversoes,
            color: abVariantContent[ABVariant.b]!.ctaColor,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            key: const Key('botao_reset_experimento'),
            onPressed: () => context.read<ABTestService>().resetExperiment(),
            child: const Text('Reiniciar experimento neste dispositivo'),
          ),
        ],
      ),
    );
  }
}

class _VariantBar extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;

  const _VariantBar({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final proporcao = total == 0 ? 0.0 : value / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: proporcao,
            minHeight: 12,
            backgroundColor: color.withValues(alpha: 0.15),
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text('$value conversões'),
      ],
    );
  }
}
