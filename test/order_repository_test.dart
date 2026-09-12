import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_app/models/service_order.dart';
import 'package:oficina_app/services/order_repository.dart';

void main() {
  late OrderRepository repository;

  setUp(() {
    repository = OrderRepository(seed: []);
  });

  test('inicia sem ordens quando a semente é vazia', () {
    expect(repository.orders, isEmpty);
  });

  test(
    'addOrder cria uma nova ordem em status "aberta" e notifica ouvintes',
    () {
      var notificado = false;
      repository.addListener(() => notificado = true);

      final order = repository.addOrder(
        cliente: 'Marcos Andrade',
        veiculo: 'Fiat Uno 2015',
        descricao: 'Barulho na suspensão',
        valor: 250.0,
      );

      expect(repository.orders, hasLength(1));
      expect(order.status, OrderStatus.aberta);
      expect(notificado, isTrue);
    },
  );

  test('addOrder insere a ordem mais recente no início da lista', () {
    repository.addOrder(
      cliente: 'A',
      veiculo: 'Carro A',
      descricao: 'x',
      valor: 10,
    );
    repository.addOrder(
      cliente: 'B',
      veiculo: 'Carro B',
      descricao: 'y',
      valor: 20,
    );

    expect(repository.orders.first.cliente, 'B');
  });

  test('advanceStatus avança aberta -> em andamento -> concluída', () {
    final order = repository.addOrder(
      cliente: 'C',
      veiculo: 'Carro C',
      descricao: 'z',
      valor: 30,
    );

    repository.advanceStatus(order.id);
    expect(repository.findById(order.id)!.status, OrderStatus.emAndamento);

    repository.advanceStatus(order.id);
    expect(repository.findById(order.id)!.status, OrderStatus.concluida);
  });

  test('advanceStatus não faz nada quando a ordem já está concluída', () {
    final order = repository.addOrder(
      cliente: 'D',
      veiculo: 'Carro D',
      descricao: 'w',
      valor: 40,
    );
    repository.advanceStatus(order.id);
    repository.advanceStatus(order.id);

    repository.advanceStatus(order.id);

    expect(repository.findById(order.id)!.status, OrderStatus.concluida);
  });

  test('removeOrder remove a ordem correta', () {
    final order1 = repository.addOrder(
      cliente: 'E',
      veiculo: 'Carro E',
      descricao: 'a',
      valor: 50,
    );
    repository.addOrder(
      cliente: 'F',
      veiculo: 'Carro F',
      descricao: 'b',
      valor: 60,
    );

    repository.removeOrder(order1.id);

    expect(repository.orders, hasLength(1));
    expect(repository.findById(order1.id), isNull);
  });

  test('faturamentoConcluido soma apenas as ordens concluídas', () {
    final order1 = repository.addOrder(
      cliente: 'G',
      veiculo: 'Carro G',
      descricao: 'a',
      valor: 100,
    );
    repository.addOrder(
      cliente: 'H',
      veiculo: 'Carro H',
      descricao: 'b',
      valor: 200,
    );

    repository.advanceStatus(order1.id);
    repository.advanceStatus(order1.id); // agora concluída

    expect(repository.faturamentoConcluido, 100);
  });
}
