import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:admin/controllers/Auth.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        // Garante que o conteúdo não ultrapasse uma largura razoável
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                  maxWidth: 400), // Largura ideal para formulários
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize:
                    MainAxisSize.min, // Ocupa apenas o espaço necessário
                children: [
                  // Logo ou Ícone da SunCity
                  const Icon(Icons.solar_power_rounded,
                      size: 80, color: Colors.orangeAccent),
                  const SizedBox(height: 16),
                  Text(
                    'SUNSYSTEM',
                    style: GoogleFonts.orbitron(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const Text(
                    'Gestão de Operações SunCity',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 48),

                  _buildTextField(
                    controller: _emailController,
                    label: 'E-mail Institucional',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _passwordController,
                    label: 'Senha',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: authController.isLoading
                          ? null
                          : () async {
                              String? erro =
                                  await context.read<AuthController>().login(
                                        _emailController.text.trim(),
                                        _passwordController.text.trim(),
                                      );

                              if (erro != null && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(erro),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: authController.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black87,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'ENTRAR',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Esqueceu a senha?',
                        style: TextStyle(color: Colors.orangeAccent)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.orangeAccent),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.orangeAccent, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }
}
