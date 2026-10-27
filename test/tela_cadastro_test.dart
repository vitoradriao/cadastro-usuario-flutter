import 'package:cadastro_usuario/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Finder campo(String chave) => find.byKey(ValueKey(chave));

bool oculto(WidgetTester tester, String chave) => tester
    .widget<TextField>(
      find.descendant(of: campo(chave), matching: find.byType(TextField)),
    )
    .obscureText;

Future<void> digitar(WidgetTester tester, String chave, String texto) async {
  await tester.ensureVisible(campo(chave));
  await tester.enterText(campo(chave), texto);
  await tester.pumpAndSettle();
}

Future<void> cadastrar(WidgetTester tester) async {
  await tester.ensureVisible(campo('cadastrar'));
  await tester.tap(campo('cadastrar'));
  await tester.pumpAndSettle();
}

Future<void> preencher(WidgetTester tester) async {
  await digitar(tester, 'nome', 'Maria da Silva');
  await digitar(tester, 'email', 'maria@exemplo.com');
  await digitar(tester, 'cpf', '12345678901');
  await digitar(tester, 'telefone', '11987654321');
  await digitar(tester, 'senha', 'senha123');
  await digitar(tester, 'confirmacao', 'senha123');
}

void main() {
  testWidgets('hierarquia obrigatória e seis campos sem erros iniciais', (
    tester,
  ) async {
    await tester.pumpWidget(const CadastroApp());
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.body, isA<Form>());
    final form = scaffold.body! as Form;
    expect(form.key, isA<GlobalKey<FormState>>());
    expect(form.child, isA<SingleChildScrollView>());
    expect((form.child as SingleChildScrollView).child, isA<Column>());
    expect(find.byType(TextFormField), findsNWidgets(6));
    expect(find.text('Informe seu nome completo.'), findsNothing);
  });
  testWidgets('cadastro vazio exibe erros por campo e SnackBar vermelho', (
    tester,
  ) async {
    await tester.pumpWidget(const CadastroApp());
    await cadastrar(tester);
    for (final erro in [
      'Informe seu nome completo.',
      'Informe seu e-mail.',
      'Informe seu CPF.',
      'Informe seu telefone.',
      'Informe sua senha.',
      'Informe a confirmação da senha.',
    ]) {
      expect(find.text(erro), findsOneWidget);
    }
    expect(
      find.text('Revise os campos indicados para continuar.'),
      findsOneWidget,
    );
    final snack = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(
      snack.backgroundColor,
      Theme.of(tester.element(find.byType(Form))).colorScheme.error,
    );
    expect(find.text('Cadastro realizado com sucesso!'), findsNothing);
  });
  testWidgets('filtros removem letras, pontuação e espaços de CPF e telefone', (
    tester,
  ) async {
    await tester.pumpWidget(const CadastroApp());
    await digitar(tester, 'cpf', '123.456.789-01abc');
    await digitar(tester, 'telefone', '+55 (11) 98765-4321abc');
    expect(
      tester.widget<TextFormField>(campo('cpf')).controller!.text,
      '12345678901',
    );
    expect(
      tester.widget<TextFormField>(campo('telefone')).controller!.text,
      '5511987654321',
    );
  });
  testWidgets('dados válidos exibem sucesso', (tester) async {
    await tester.pumpWidget(const CadastroApp());
    await preencher(tester);
    await cadastrar(tester);
    expect(find.text('Cadastro realizado com sucesso!'), findsOneWidget);
    expect(find.text('As senhas não coincidem.'), findsNothing);
  });
  testWidgets(
    'e-mail inválido, senha curta e divergência impedem sucesso e podem ser corrigidos',
    (tester) async {
      await tester.pumpWidget(const CadastroApp());
      await preencher(tester);
      await digitar(tester, 'email', 'maria.exemplo.com');
      await digitar(tester, 'senha', '12345');
      await cadastrar(tester);
      expect(
        find.text('Informe um e-mail válido, como nome@exemplo.com.'),
        findsOneWidget,
      );
      expect(
        find.text('A senha deve ter no mínimo 6 caracteres.'),
        findsOneWidget,
      );
      expect(find.text('As senhas não coincidem.'), findsOneWidget);
      expect(find.text('Cadastro realizado com sucesso!'), findsNothing);
      await digitar(tester, 'email', 'maria@exemplo.com');
      await digitar(tester, 'senha', 'senha123');
      await cadastrar(tester);
      expect(find.text('Cadastro realizado com sucesso!'), findsOneWidget);
    },
  );
  testWidgets('alterar senha revalida confirmação após primeira tentativa', (
    tester,
  ) async {
    await tester.pumpWidget(const CadastroApp());
    await preencher(tester);
    await cadastrar(tester);
    await digitar(tester, 'senha', 'outrasenha');
    expect(find.text('As senhas não coincidem.'), findsOneWidget);
  });
  testWidgets('botões de visibilidade independentes preservam texto', (
    tester,
  ) async {
    await tester.pumpWidget(const CadastroApp());
    await digitar(tester, 'senha', 'segredo123');
    await tester.tap(find.byTooltip('Mostrar senha'));
    await tester.pumpAndSettle();
    expect(oculto(tester, 'senha'), isFalse);
    expect(oculto(tester, 'confirmacao'), isTrue);
    expect(
      tester.widget<TextFormField>(campo('senha')).controller!.text,
      'segredo123',
    );
    await tester.tap(find.byTooltip('Ocultar senha'));
    await tester.pumpAndSettle();
    expect(oculto(tester, 'senha'), isTrue);
    await tester.ensureVisible(campo('confirmacao'));
    await tester.tap(find.byTooltip('Mostrar confirmação de senha'));
    await tester.pumpAndSettle();
    expect(oculto(tester, 'confirmacao'), isFalse);
    expect(oculto(tester, 'senha'), isTrue);
  });
  testWidgets('tela pequena com teclado permite rolagem e cadastro', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = FakeViewPadding(bottom: 240);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(const CadastroApp());
    await preencher(tester);
    await cadastrar(tester);
    expect(find.text('Cadastro realizado com sucesso!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
