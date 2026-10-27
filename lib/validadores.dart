/// Retorna uma mensagem de erro ou null quando o valor é válido.
abstract final class Validadores {
  static String? obrigatorio(String? valor, String campo) {
    if (valor == null || valor.trim().isEmpty) return 'Informe $campo.';
    return null;
  }

  static String? nome(String? valor) => obrigatorio(valor, 'seu nome completo');

  static String? email(String? valor) {
    final erro = obrigatorio(valor, 'seu e-mail');
    if (erro != null) return erro;
    // Além do @, exige domínio, extensão e ausência de espaços internos.
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(valor!.trim())) {
      return 'Informe um e-mail válido, como nome@exemplo.com.';
    }
    return null;
  }

  static String? numerico(String? valor, String campo) {
    final erro = obrigatorio(valor, campo);
    if (erro != null) return erro;
    if (!RegExp(r'^[0-9]+$').hasMatch(valor!)) {
      return 'Use apenas números em $campo.';
    }
    return null;
  }

  static String? senha(String? valor) {
    final erro = obrigatorio(valor, 'sua senha');
    if (erro != null) return erro;
    if (valor!.length < 6) return 'A senha deve ter no mínimo 6 caracteres.';
    return null;
  }

  static String? confirmacaoSenha(String? valor, String senha) {
    final erro = obrigatorio(valor, 'a confirmação da senha');
    if (erro != null) return erro;
    if (valor != senha) return 'As senhas não coincidem.';
    return null;
  }
}
