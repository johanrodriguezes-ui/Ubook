import 'package:flutter/material.dart';
import 'package:ubook/services/community_service.dart';
import 'package:ubook/services/auth_service.dart';

class CreateCommunityScreen extends StatefulWidget {
  @override
  _CreateCommunityScreenState createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final CommunityService _communityService = CommunityService();
  final AuthService _authService = AuthService();

  final TextEditingController _communityNameController =
      TextEditingController();
  String? currentUserId;
  String? _communityImage; // Variable para almacenar la imagen seleccionada

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    currentUserId = await _authService.getUserId();
  }

  // Función para crear la comunidad
  Future<void> _createCommunity() async {
    final String communityName = _communityNameController.text.trim();
    final String communityImage =
        _communityImage ?? ""; // Si no hay imagen, será una cadena vacía

    if (communityName.isEmpty) {
      // Validación simple
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, complete todos los campos.')),
      );
      return;
    }

    if (currentUserId != null) {
      bool success = await _communityService.createCommunity(
        communityName,
        communityImage, // Imagen opcional
        currentUserId!,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Comunidad creada exitosamente.')),
        );
        Navigator.pop(context); // Regresar a la pantalla anterior
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hubo un error al crear la comunidad.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Comunidad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _communityNameController,
              decoration: InputDecoration(labelText: 'Nombre de la comunidad'),
            ),
            SizedBox(height: 16),

            // Mostrar imagen o ícono predeterminado
            Center(
              child: _communityImage == null
                  ? Icon(
                      Icons.group, // Ícono predeterminado si no hay imagen
                      size: 100,
                      color: Colors.grey,
                    )
                  : Image.network(
                      _communityImage!, // Si hay imagen, se muestra aquí
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
            ),
            SizedBox(height: 16),

            // Botón para crear la comunidad
            ElevatedButton(
              onPressed: _createCommunity,
              child: Text('Crear Comunidad'),
            ),
          ],
        ),
      ),
    );
  }
}
