# 🔧 Oficina Rápida

**App mobile em Flutter para gestão de ordens de serviço de uma oficina mecânica**, desenvolvido como trabalho do 1º bimestre.

![CI/CD](https://github.com/nathanbizinoto/LDDM2026/actions/workflows/ci.yml/badge.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Tests](https://img.shields.io/badge/testes-28%20passing-brightgreen)

> **Aluno:** Nathan Bizinoto
> **Tema:** Oficina mecânica (gestão de ordens de serviço)
> **Tecnologia:** Flutter (Dart)
> **Repositório:** [nathanbizinoto/LDDM2026](https://github.com/nathanbizinoto/LDDM2026)

## Sumário

- [Checklist do trabalho](#checklist-do-trabalho)
- [Screenshots](#screenshots)
- [Tema e viabilidade](#tema-e-viabilidade)
- [Funcionalidades](#funcionalidades)
- [Arquitetura](#arquitetura)
- [TDD (Desenvolvimento Orientado por Testes)](#tdd-desenvolvimento-orientado-por-testes)
- [Teste A/B](#teste-ab)
- [CI/CD](#cicd)
- [Como rodar o projeto](#como-rodar-o-projeto)
- [Estrutura de pastas](#estrutura-de-pastas)
- [Limitações e próximos passos](#limitações-e-próximos-passos)

## Checklist do trabalho

Resumo rápido de onde cada requisito pedido no trabalho foi implementado:

| Requisito | Como foi atendido | Onde ver |
|---|---|---|
| **Testes A/B** | Botão de criar OS com 2 variantes (cor/texto), sorteada e persistida por dispositivo, com painel de conversões | [`lib/services/ab_test_service.dart`](lib/services/ab_test_service.dart), [`lib/screens/ab_dashboard_screen.dart`](lib/screens/ab_dashboard_screen.dart), seção [Teste A/B](#teste-ab) |
| **CI/CD** | Pipeline no GitHub Actions: analisa, testa, builda APK e faz deploy automático da versão web | [`.github/workflows/ci.yml`](.github/workflows/ci.yml), seção [CI/CD](#cicd) |
| **TDD** | Regras de negócio escritas como funções puras e testadas antes/junto da implementação (28 testes) | pasta [`test/`](test), seção [TDD](#tdd-desenvolvimento-orientado-por-testes) |
| **Tema escolhido** | Oficina mecânica: cadastro, acompanhamento e faturamento de ordens de serviço | seção [Tema e viabilidade](#tema-e-viabilidade) |
| **Framework** | Flutter/Dart, Material 3, gerenciamento de estado com `provider` | seção [Arquitetura](#arquitetura) |

## Screenshots

<!--
  Para gerar os prints: rode `flutter run -d chrome`, abra cada tela e
  salve o print em docs/screenshots/ com o nome indicado na legenda.
  Formato recomendado: recorte só a janela do app (proporção de celular).
-->

<table>
  <tr>
    <td align="center" width="25%">
      <img src="docs/screenshots/home.png" width="200" alt="Lista de ordens de serviço"/><br/>
      <sub><b>Lista de OS</b></sub>
    </td>
    <td align="center" width="25%">
      <img src="docs/screenshots/nova_os.png" width="200" alt="Formulário de nova ordem de serviço"/><br/>
      <sub><b>Nova OS</b></sub>
    </td>
    <td align="center" width="25%">
      <img src="docs/screenshots/detalhe_os.png" width="200" alt="Detalhe da ordem de serviço"/><br/>
      <sub><b>Detalhe da OS</b></sub>
    </td>
    <td align="center" width="25%">
      <img src="docs/screenshots/ab_dashboard.png" width="200" alt="Painel do teste A/B"/><br/>
      <sub><b>Painel A/B</b></sub>
    </td>
  </tr>
</table>

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

O workflow [`.github/workflows/ci.yml`](.github/workflows/ci.yml) roda no
GitHub Actions a cada push ou pull request para a branch `main`:

1. **`test`** — instala dependências, roda `flutter analyze`, checa
   formatação (`dart format`) e executa `flutter test` (o mesmo conjunto de
   testes do TDD), publicando o relatório de cobertura como artefato.
2. **`build-android`** — (depende do `test` passar) gera um APK de release e
   publica como artefato do workflow, demonstrando **entrega contínua**.
3. **`deploy-web`** — (depende do `test` passar, só na branch `main`) builda
   a versão web do app e publica automaticamente no **GitHub Pages**,
   demonstrando **implantação contínua** de fato (o app fica acessível por
   uma URL pública a cada novo push).

Acompanhe as execuções na aba
[**Actions**](https://github.com/nathanbizinoto/LDDM2026/actions) do
repositório — é o melhor lugar para mostrar o CI/CD funcionando na
apresentação.

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
  docs/screenshots/
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



  ## Screenshots
<img width="406" height="733" alt="image" src="https://github.com/user-attachments/assets/305937b6-a960-408e-b7b2-e6abbb757a99" />
<img width="405" height="730" alt="Screenshot 2026-09-11 at 23 17 48" src="https://github.com/user-attachments/assets/71f47eb2-9791-40db-ab9d-f007c261cf4a" />
<img width="406" height="731" alt="Screenshot 2026-09-11 at 23 18 16" src="https://github.com/user-attachments/assets/900696f8-2ae7-42c0-9e42-6bead7737f82" />
<img width="405" height="736" alt="Screenshot 2026-09-11 at 23 18 42" src="https://github.com/user-attachments/assets/62b7332b-4b93-4d13-bd76-769e6b3c08bb" />



