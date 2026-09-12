import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/order_repository.dart';
import '../services/order_validator.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clienteController = TextEditingController();
  final _veiculoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();

  @override
  void dispose() {
    _clienteController.dispose();
    _veiculoController.dispose();
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;

    final valor = double.parse(_valorController.text.replaceAll(',', '.'));
    context.read<OrderRepository>().addOrder(
      cliente: _clienteController.text.trim(),
      veiculo: _veiculoController.text.trim(),
      descricao: _descricaoController.text.trim(),
      valor: valor,
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Ordem de Serviço')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('campo_cliente'),
              controller: _clienteController,
              decoration: const InputDecoration(labelText: 'Cliente'),
              validator: OrderValidator.validateCliente,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('campo_veiculo'),
              controller: _veiculoController,
              decoration: const InputDecoration(
                labelText: 'Veículo (modelo e ano)',
              ),
              validator: OrderValidator.validateVeiculo,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('campo_descricao'),
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Problema relatado'),
              validator: OrderValidator.validateDescricao,
              maxLines: 3,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('campo_valor'),
              controller: _valorController,
              decoration: const InputDecoration(
                labelText: 'Valor orçado (R\$)',
              ),
              validator: OrderValidator.validateValor,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              key: const Key('botao_salvar_os'),
              onPressed: _salvar,
              child: const Text('Salvar ordem de serviço'),
            ),
          ],
        ),
      ),
    );
  }
}
