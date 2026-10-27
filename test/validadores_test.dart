import 'package:cadastro_usuario/validadores.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('todos os campos rejeitam vazio, null e somente espaços', () {
    for (final valor in [null, '', '   ']) {
      expect(Validadores.nome(valor), isNotNull);
      expect(Validadores.email(valor), isNotNull);
      expect(Validadores.numerico(valor, 'CPF'), isNotNull);
      expect(Validadores.numerico(valor, 'telefone'), isNotNull);
      expect(Validadores.senha(valor), isNotNull);
      expect(Validadores.confirmacaoSenha(valor, '123456'), isNotNull);
    }
  });
  test(
    'nome aceita texto livre e e-mail exige domínio e não permite espaços',
    () {
      expect(Validadores.nome('José'), isNull);
      expect(Validadores.nome('Maria da Silva'), isNull);
      expect(Validadores.email(' pessoa+teste@exemplo.com.br '), isNull);
      for (final email in [
        'pessoa',
        'pessoa@',
        '@exemplo.com',
        'a@@b.com',
        'a b@exemplo.com',
        'pessoa@localhost',
      ]) {
        expect(Validadores.email(email), isNotNull, reason: email);
      }
    },
  );
  test('CPF e telefone aceitam somente números, sem impor regras extras', () {
    expect(Validadores.numerico('12345678901', 'CPF'), isNull);
    expect(Validadores.numerico('11987654321', 'telefone'), isNull);
    expect(Validadores.numerico('1', 'CPF'), isNull);
    for (final valor in ['123.456', '+5511', '123abc', '123 456']) {
      expect(Validadores.numerico(valor, 'CPF'), isNotNull);
    }
  });
  test('senha tem mínimo de seis e confirmação compara exatamente', () {
    expect(Validadores.senha('12345'), isNotNull);
    expect(Validadores.senha('123456'), isNull);
    expect(Validadores.senha(' 123456 '), isNull);
    expect(Validadores.confirmacaoSenha('123456', '123456'), isNull);
    expect(Validadores.confirmacaoSenha('123456 ', '123456'), isNotNull);
    expect(Validadores.confirmacaoSenha('abcdef', '123456'), isNotNull);
  });
}
