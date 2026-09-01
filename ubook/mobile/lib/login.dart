import 'package:flutter/material.dart';
import 'package:ubook/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para los campos de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  // Variable para controlar la visibilidad de la contraseña
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'assets/icon/logo.png',
                height: 150,
              ),
              const SizedBox(height: 80),

              // Campo de correo con ancho fijo de 200px
              SizedBox(
                width: 500,
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Campo de contraseña con ancho fijo de 200px y icono para mostrar/ocultar
              SizedBox(
                width: 500,
                child: TextField(
                  controller: _passwordController,
                  obscureText:
                      !_isPasswordVisible, // Contraseña oculta o visible
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),

              // Botón de inicio de sesión con icono de llave
              SizedBox(
                width: 140, // Tamaño ajustado para el botón
                child: ElevatedButton(
                  onPressed: () async {
                    // Validar que los campos no estén vacíos
                    if (_emailController.text.isEmpty ||
                        _passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Por favor, ingresa tu correo y contraseña')),
                      );
                      return;
                    }

                    // Llamar a la función de inicio de sesión
                    String result = await _authService.loginUser(
                      _emailController.text,
                      _passwordController.text,
                    );

                    // Verificar si el inicio de sesión fue exitoso
                    if (result == 'success') {
                      Navigator.pushNamed(context, '/home');
                    } else {
                      // Mostrar mensaje de error específico
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result)),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004D40),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.vpn_key,
                          color: Colors.white), // Icono de llave
                      SizedBox(width: 8), // Espacio entre el icono y el texto
                      Text(
                        'Iniciar sesión',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              // Opción de registro
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  '¿No tienes una cuenta? Regístrate',
                  style: TextStyle(
                    color: Color(0xFF004D40),
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
