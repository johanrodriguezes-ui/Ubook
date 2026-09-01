import 'package:flutter/material.dart';
import 'dart:async';
import 'package:ubook/services/group_service.dart';
import 'package:ubook/services/auth_service.dart';
import 'package:ubook/addgroup.dart';
import 'package:ubook/group_window.dart'; // Asegúrate de importar GroupWindow

class GroupScreen extends StatefulWidget {
  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final AuthService _authService = AuthService();
  final GroupService _groupService = GroupService();
  List<Map<String, dynamic>> groups = [];
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    loadGroups();
    _startPolling(); // Iniciar polling para actualizar grupos periódicamente
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    print("Polling timer cancelled."); // Añadir esta línea para depurar
    super.dispose();
  }

  // Iniciar polling cada 10 segundos (ajusta si es necesario)
  void _startPolling() {
    _pollingTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      loadGroups();
    });
  }

  // Cargar los grupos
  Future<void> loadGroups() async {
    String? currentUserId = await _authService.getUserId();

    if (currentUserId != null) {
      List<Map<String, dynamic>> loadedGroups =
          await _groupService.getGroups(currentUserId);

      setState(() {
        groups = loadedGroups;
      });

      print("Grupos cargados: $groups");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: groups.isEmpty
          ? Center(
              child:
                  Text('No hay grupos disponibles')) // Mensaje si no hay grupos
          : ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.group, color: Colors.white),
                  ),
                  title: Text(groups[index]['group_name'] ?? 'Sin nombre'),
                  subtitle: Text(groups[index]['lastMessage'] ?? 'Sin mensaje'),
                  onTap: () {
                    // Navegar a la pantalla GroupWindow
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupWindow(
                          groupId: groups[index]['group_id']
                              .toString(), // Asegúrate de que sea un String
                          creatorId: groups[index]['created_by']
                              .toString(), // Asegúrate de que sea un String
                          groupName: groups[index]['group_name']
                              .toString(), // Pasar el nombre del grupo
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navega a la pantalla para agregar un nuevo grupo
          final newGroup = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddGroupScreen()),
          );

          // Verificar que el nuevo grupo no sea null y tenga los valores requeridos
          if (newGroup != null &&
              newGroup['group_name'] != null &&
              newGroup['lastMessage'] != null) {
            setState(() {
              groups.add(newGroup); // Actualiza la lista con el nuevo grupo
            });
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}
