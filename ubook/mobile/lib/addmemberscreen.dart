import 'package:flutter/material.dart';
import 'package:ubook/services/group_service.dart';
import 'package:ubook/services/auth_service.dart';

class AddMemberScreen extends StatefulWidget {
  final String groupId;

  AddMemberScreen({required this.groupId});

  @override
  _AddMemberScreenState createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final GroupService _groupService = GroupService();
  final AuthService _authService = AuthService();
  String? currentUserId; // Cambia esto a String, no a nullable
  List<Map<String, dynamic>> availableUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getCurrentUserId(); // Asegúrate de obtener el ID del usuario actual al inicio
  }

  // Obtener el ID del usuario actual
  void getCurrentUserId() async {
    currentUserId =
        await _authService.getUserId(); // Obtén el ID del usuario actual
    loadAvailableUsers(); // Carga los usuarios disponibles después de obtener el ID
  }

  Future<void> loadAvailableUsers() async {
    setState(() {
      isLoading =
          true; // Muestra un indicador de carga mientras se obtienen los usuarios
    });

    try {
      // Cargar usuarios disponibles
      final users =
          await _groupService.getAvailableUsers(currentUserId!, widget.groupId);

      setState(() {
        availableUsers = users;
        isLoading = false; // Desactiva el indicador de carga
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Desactiva el indicador de carga en caso de error
      });

      // Muestra un mensaje de error en caso de que algo falle
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar usuarios disponibles: $e')),
      );
    }
  }

  // Añadir miembro al grupo
  Future<void> addMember(String userId) async {
    final success = await _groupService.addGroupMember(widget.groupId, userId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Miembro añadido con éxito')),
      );
      Navigator.pop(context); // Regresar a la lista de miembros
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al añadir miembro')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir miembro'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator()) // Mostrar indicador de carga
          : ListView.builder(
              itemCount: availableUsers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(availableUsers[index]['name']),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      addMember(availableUsers[index]['uid']
                          .toString()); // Asegúrate de usar 'uid' aquí
                    },
                  ),
                );
              },
            ),
    );
  }
}
