import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'validadores.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmacaoController = TextEditingController();

  bool _ocultarSenha = true;
  bool _ocultarConfirmacao = true;
  bool _tentouCadastrar = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmacaoController.dispose();
    super.dispose();
  }

  void _cadastrar() {
    FocusScope.of(context).unfocus();
    // validate() executa o validator de todos os campos do Form.
    final valido = _formKey.currentState!.validate();
    setState(() => _tentouCadastrar = true);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: valido
            ? const Color(0xFF166534)
            : Theme.of(context).colorScheme.error,
        content: Text(
          valido
              ? 'Cadastro realizado com sucesso!'
              : 'Revise os campos indicados para continuar.',
        ),
      ),
    );
    // Demonstração: dados capturados pelos controllers ficam apenas em memória.
    // Um cadastro real enviaria os dados validados a um serviço neste ponto.
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final tema = Theme.of(context);
    // Limita a largura sem inserir widgets na hierarquia obrigatória.
    final margem = math.max(24.0, (media.size.width - 480) / 2);

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de usuário')),
      body: Form(
        key: _formKey,
        autovalidateMode: _tentouCadastrar
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            margem,
            24,
            margem,
            24 + media.padding.bottom,
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tema.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.person_add_alt_1_rounded,
                    color: tema.colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Crie sua conta',
                style: tema.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF18213A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Preencha seus dados. Todos os campos são obrigatórios.',
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              TextFormField(
                key: const ValueKey('nome'),
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  hintText: 'Digite seu nome completo',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: Validadores.nome,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('email'),
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  hintText: 'nome@exemplo.com',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                validator: Validadores.email,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('cpf'),
                controller: _cpfController,
                decoration: const InputDecoration(
                  labelText: 'CPF',
                  hintText: 'Somente números',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (valor) => Validadores.numerico(valor, 'seu CPF'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('telefone'),
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  hintText: 'DDD + número, sem espaços',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (valor) =>
                    Validadores.numerico(valor, 'seu telefone'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('senha'),
                controller: _senhaController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  helperText: 'Use pelo menos 6 caracteres.',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: _ocultarSenha ? 'Mostrar senha' : 'Ocultar senha',
                    onPressed: () =>
                        setState(() => _ocultarSenha = !_ocultarSenha),
                    icon: Icon(
                      _ocultarSenha
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.next,
                obscureText: _ocultarSenha,
                autocorrect: false,
                enableSuggestions: false,
                validator: Validadores.senha,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('confirmacao'),
                controller: _confirmacaoController,
                decoration: InputDecoration(
                  labelText: 'Confirme sua senha',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: _ocultarConfirmacao
                        ? 'Mostrar confirmação de senha'
                        : 'Ocultar confirmação de senha',
                    onPressed: () => setState(
                      () => _ocultarConfirmacao = !_ocultarConfirmacao,
                    ),
                    icon: Icon(
                      _ocultarConfirmacao
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                obscureText: _ocultarConfirmacao,
                autocorrect: false,
                enableSuggestions: false,
                validator: (valor) =>
                    Validadores.confirmacaoSenha(valor, _senhaController.text),
                onFieldSubmitted: (_) => _cadastrar(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                key: const ValueKey('cadastrar'),
                onPressed: _cadastrar,
                child: const Text('CADASTRAR'),
              ),
              const SizedBox(height: 20),
              Text(
                'Atividade prática • Flutter e Dart\n'
                'Demonstração de formulário, sem envio de dados.',
                textAlign: TextAlign.center,
                style: tema.textTheme.bodySmall?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
