# Oficina Rápida

Aplicativo mobile (Flutter) para gestão de ordens de serviço de uma **oficina
mecânica**, desenvolvido como trabalho do 1º bimestre. O projeto foi
construído seguindo **TDD**, inclui um **teste A/B** real embutido no app e
possui um pipeline de **CI/CD** completo via GitHub Actions.

## Sumário

- [Tema e viabilidade](#tema-e-viabilidade)
- [Funcionalidades](#funcionalidades)
- [Arquitetura](#arquitetura)
- [TDD (Desenvolvimento Orientado por Testes)](#tdd-desenvolvimento-orientado-por-testes)
- [Teste A/B](#teste-ab)
- [CI/CD](#cicd)
- [Como rodar o projeto](#como-rodar-o-projeto)
- [Estrutura de pastas](#estrutura-de-pastas)
- [Limitações e próximos passos](#limitações-e-próximos-passos)

## Tema e viabilidade

O tema escolhido foi **oficina mecânica**: o app permite que o atendente
cadastre uma ordem de serviço (OS) com cliente, veículo, problema relatado e
valor orçado, acompanhe o status (**Aberta → Em andamento → Concluída**) e
veja o faturamento das OS concluídas.

É um domínio pequeno, mas realista e completo o suficiente para caber em um
projeto de bimestre: tem cadastro, fluxo de estado, validação de formulário e
uma regra de negócio simples (faturamento), o que permite demonstrar TDD,
teste A/B e CI/CD sem a complexidade de integrar um backend externo.

## Funcionalidades

- **Lista de ordens de serviço** com status colorido e valor orçado.
- **Cadastro de nova OS** com validação de formulário (cliente, veículo,
  descrição do problema e valor).
- **Detalhe da OS** com opção de avançar o status ou excluir a ordem.
- **Painel do teste A/B**, mostrando a variante do dispositivo e o placar de
  conversões de cada variante.

## Arquitetura

Gerenciamento de estado simples com `provider` (`ChangeNotifier`), sem
dependência de backend — os dados ficam em memória durante a execução do
app. Camadas:

```
lib/
  models/      -> entidades do domínio (ServiceOrder, OrderStatus)
  services/    -> regras de negócio puras e persistência (repositório,
                  validação de formulário, serviço de teste A/B)
  screens/     -> telas (Home, Nova OS, Detalhe da OS, Painel A/B)
  widgets/     -> componentes de UI reutilizáveis (card de OS, badge de status)
  theme/       -> tema visual do Material 3
```

A separação entre `services/` (lógica pura, sem `Widget`) e `screens/`
(interface) é o que torna o projeto testável via TDD.

## TDD (Desenvolvimento Orientado por Testes)

O ciclo **red → green → refactor** foi aplicado nas três peças de lógica de
negócio do app, todas em `test/`:

| Teste | O que valida |
|---|---|
| `order_validator_test.dart` | Regras de validação do formulário de nova OS (campos obrigatórios, valor numérico e positivo, vírgula/ponto decimal) |
| `order_repository_test.dart` | Criação, avanço de status, remoção de OS e cálculo do faturamento |
| `ab_test_service_test.dart` | Atribuição e persistência da variante do teste A/B, e contagem de conversões |
| `widgets/home_screen_test.dart` | Teste de widget: lista renderiza as OS cadastradas, estado vazio e rótulo do botão conforme a variante A/B |

A lógica de validação e a atribuição de variante do teste A/B foram escritas
como **funções puras** (`OrderValidator`, `resolveVariant`) justamente para
serem testadas sem precisar de widgets nem de plataforma — o núcleo de um bom
ciclo de TDD.

Para rodar os testes:

```bash
flutter test
```

## Teste A/B

O experimento compara duas variantes do botão de criar uma nova OS na tela
inicial:

- **Variante A**: botão laranja "Nova Ordem de Serviço".
- **Variante B**: botão verde "+ Criar OS agora".

Ao abrir o app pela primeira vez, o dispositivo é sorteado (50/50) para uma
das variantes (`ABTestService.resolveVariant`) e essa escolha é **persistida**
com `shared_preferences`, então o usuário sempre vê a mesma variante nas
próximas aberturas. Toda vez que uma OS é criada com sucesso, isso é contado
como uma **conversão** da variante atual.

O ícone de gráfico no canto superior direito da tela inicial abre o **Painel
do teste A/B**, que mostra a variante do dispositivo e o placar de conversões
de cada grupo — simulando, de forma simples e offline, um painel de
experimentação como o de ferramentas de growth (ex.: Firebase A/B Testing,
Optimizely), sem depender de conta em nuvem para o trabalho.

## CI/CD

O workflow `.github/workflows/ci.yml` roda no GitHub Actions a cada push ou
pull request para a branch `main`:

1. **`test`** — instala dependências, roda `flutter analyze`, checa
   formatação (`dart format`) e executa `flutter test` (o mesmo conjunto de
   testes do TDD), publicando o relatório de cobertura como artefato.
2. **`build-android`** — (depende do `test` passar) gera um APK de release e
   publica como artefato do workflow, demonstrando **entrega contínua**.
3. **`deploy-web`** — (depende do `test` passar, só na branch `main`) builda
   a versão web do app e publica automaticamente no **GitHub Pages**,
   demonstrando **implantação contínua** de fato (o app fica acessível por
   uma URL pública a cada novo push).

Para ativar o pipeline, basta dar push deste projeto para um repositório no
GitHub — o workflow já está configurado e não exige nenhum segredo além do
`GITHUB_TOKEN` padrão. Se o nome do repositório remoto não for `oficina_app`,
ajuste o `--base-href` do job `deploy-web` para `/nome-do-repositorio/`.

## Como rodar o projeto

Pré-requisitos: [Flutter SDK](https://docs.flutter.dev/get-started/install)
(canal stable).

```bash
flutter pub get
flutter test        # roda a suíte de testes (TDD)
flutter analyze      # análise estática
flutter run -d chrome   # roda no navegador
# ou
flutter run             # roda em um emulador/dispositivo conectado
```

## Estrutura de pastas

```
oficina_app/
  lib/
    models/service_order.dart
    services/order_repository.dart
    services/order_validator.dart
    services/ab_test_service.dart
    screens/home_screen.dart
    screens/new_order_screen.dart
    screens/order_detail_screen.dart
    screens/ab_dashboard_screen.dart
    widgets/order_card.dart
    widgets/status_badge.dart
    theme/app_theme.dart
    main.dart
  test/
    order_validator_test.dart
    order_repository_test.dart
    ab_test_service_test.dart
    widgets/home_screen_test.dart
  .github/workflows/ci.yml
```

## Limitações e próximos passos

- Os dados das ordens de serviço ficam em memória (não persistem ao fechar o
  app). Evolução natural: salvar em SQLite local (`sqflite`) ou em um backend
  (ex.: Firebase/Supabase).
- O teste A/B é local ao dispositivo (não agrega dados entre usuários). Em um
  cenário real de produção, o ideal seria enviar os eventos de conversão para
  um serviço de analytics (Firebase Analytics, Amplitude, etc.) para agregar
  os resultados de todos os usuários.
