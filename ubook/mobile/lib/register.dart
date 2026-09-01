import 'package:flutter/material.dart';
import 'package:ubook/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _identyController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedProgram;

  final AuthService _authService = AuthService();
  bool _isPasswordVisible = false; // Estado para controlar visibilidad

  final List<String> programs = [
    'Ingeniería de Sistemas',
    'Ingeniería Civil',
    'Ingeniería Agroindustrial',
    'Ingeniería Agroforestal',
    'Derecho',
    'Medicina Veterinaria y Zootecnia',
    'Contaduría Pública'
  ];

  bool _isValidEmail(String email) {
    return email.endsWith('@gmail.com') || email.endsWith('@unitropico.edu.co');
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _registerUser() async {
    if (_identyController.text.isNotEmpty &&
        _usernameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _selectedDate != null &&
        _selectedProgram != null) {
      if (!_isValidEmail(_emailController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('El correo debe ser @gmail.com o @unitropico.edu.co')),
        );
        return;
      }

      bool emailExists =
          await _authService.checkEmailExists(_emailController.text);

      if (emailExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('El correo ya está registrado. Usa otro.')),
        );
        return;
      }

      String formattedDate =
          "${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}";

      await _authService.registerUser(
        _identyController.text,
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
        formattedDate,
        _selectedProgram!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrado con éxito')),
      );
      Navigator.pushNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Registro',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF004D40), // Verde oscuro
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Crea una cuenta',
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00594E), // Aplica el color verde
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Es rápido y fácil...',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'A continuación, ingresa los datos correspondientes:',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                // Campo de identificación
                SizedBox(
                  width: 500, // Ancho específico
                  child: TextField(
                    controller: _identyController,
                    decoration: InputDecoration(
                      labelText: 'Identificación',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      hintText: 'Número de identificación',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Campo de nombre de usuario
                SizedBox(
                  width: 500, // Ancho específico
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de usuario',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Campo de correo
                SizedBox(
                  width: 500, // Ancho específico
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Correo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      hintText: 'ejemplo@unitropico.edu.co',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Campo de contraseña con ícono de visibilidad
                SizedBox(
                  width: 500, // Ancho específico
                  child: TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
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
                const SizedBox(height: 10),
                // Selector de fecha de nacimiento
                SizedBox(
                  width: 500, // Ancho específico
                  child: ListTile(
                    title: Text(
                      _selectedDate == null
                          ? 'Fecha de Nacimiento'
                          : 'Fecha de Nacimiento: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(height: 10),
                // Selector de programa
                SizedBox(
                  width: 500, // Ancho específico
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Programa',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    value: _selectedProgram,
                    items: programs.map((program) {
                      return DropdownMenuItem(
                        value: program,
                        child: Text(program),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProgram = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 110),
                // Botón de registro
                SizedBox(
                  width: 120,
                  child: ElevatedButton.icon(
                    onPressed: _registerUser,
                    icon: const Icon(Icons.person, color: Colors.white),
                    label: const Text(
                      'Registrarse',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004D40), // Verde oscuro
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
