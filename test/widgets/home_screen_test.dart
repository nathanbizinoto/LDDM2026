import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_app/screens/home_screen.dart';
import 'package:oficina_app/services/ab_test_service.dart';
import 'package:oficina_app/services/order_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _buildApp(OrderRepository repository, ABTestService abTestService) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: repository),
      ChangeNotifierProvider.value(value: abTestService),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('exibe as ordens de serviço cadastradas', (tester) async {
    final repository = OrderRepository(seed: []);
    repository.addOrder(
      cliente: 'Marcos Andrade',
      veiculo: 'Fiat Uno 2015',
      descricao: 'Barulho na suspensão',
      valor: 250.0,
    );
    final prefs = await SharedPreferences.getInstance();
    final abTestService = ABTestService(prefs);

    await tester.pumpWidget(_buildApp(repository, abTestService));

    expect(find.text('Marcos Andrade'), findsOneWidget);
    expect(find.text('Fiat Uno 2015'), findsOneWidget);
  });

  testWidgets('mostra estado vazio quando não há ordens', (tester) async {
    final repository = OrderRepository(seed: []);
    final prefs = await SharedPreferences.getInstance();
    final abTestService = ABTestService(prefs);

    await tester.pumpWidget(_buildApp(repository, abTestService));

    expect(find.text('Nenhuma ordem de serviço cadastrada.'), findsOneWidget);
  });

  testWidgets('botão de criar OS exibe o rótulo da variante A/B atribuída', (
    tester,
  ) async {
    final repository = OrderRepository(seed: []);
    SharedPreferences.setMockInitialValues({'ab_variant': 'b'});
    final prefs = await SharedPreferences.getInstance();
    final abTestService = ABTestService(prefs);

    await tester.pumpWidget(_buildApp(repository, abTestService));

    expect(find.text('+ Criar OS agora'), findsOneWidget);
  });
}
