import 'package:flutter/material.dart';
import 'package:ubook/services/group_service.dart';
import 'package:ubook/services/auth_service.dart'; // Importa el servicio de autenticación

class AddGroupScreen extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final GroupService _groupService = GroupService(); // Instancia del servicio
  final AuthService _authService =
      AuthService(); // Instancia del servicio de autenticación

  AddGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Nuevo Grupo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre del grupo'),
            ),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Mensaje inicial'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String name = _nameController.text;
                String message = _messageController.text;

                // Obtener el uid del usuario logueado
                String? createdBy = await _authService.getUserId();
                if (createdBy == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error: UID no encontrado.')),
                  );
                  return; // No continuar si el UID no se recupera
                }

                // Si no se proporciona una URL de imagen, usar un icono de Flutter por defecto
                String groupImage = 'URL_IMAGEN_GRUPO'; // Predeterminada
                if (groupImage.isEmpty || groupImage == 'URL_IMAGEN_GRUPO') {
                  // Icono por defecto de Flutter si no hay imagen
                  groupImage =
                      'flutter_icon_default'; // Esto es simbólico, ya que no se puede usar directamente en la UI
                }

                // Usamos el servicio para crear el grupo con el UID dinámico y el mensaje inicial
                bool success = await _groupService.createGroup(
                    name, groupImage, createdBy, message);

                if (success) {
                  // Si el grupo se creó exitosamente, lo retornamos a la pantalla anterior
                  Navigator.pop(context, {
                    'name': name,
                    'lastMessage':
                        message, // Retornar el mensaje inicial como último mensaje
                    'image': groupImage,
                  });
                } else {
                  // Muestra un mensaje de error si falla la creación del grupo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al crear el grupo')),
                  );
                }
              },
              child: const Text('Agregar Grupo'),
            )
          ],
        ),
      ),
    );
  }
}
