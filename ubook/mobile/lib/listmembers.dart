import 'package:flutter/material.dart';
import 'package:ubook/services/group_service.dart';
import 'package:ubook/addmemberscreen.dart';

class MembersListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> members;
  final String groupId;
  final String creatorId;
  final String? currentUserId;

  MembersListScreen({
    required this.members,
    required this.groupId,
    required this.creatorId,
    required this.currentUserId,
  });

  @override
  _MembersListScreenState createState() => _MembersListScreenState();
}

class _MembersListScreenState extends State<MembersListScreen> {
  final GroupService _groupService = GroupService();
  late List<Map<String, dynamic>> membersCopy;

  @override
  void initState() {
    super.initState();
    membersCopy = List.from(
        widget.members); // Crear una copia de la lista inicial de miembros
  }

  // Cargar miembros del grupo
  Future<void> loadMembers() async {
    try {
      List<Map<String, dynamic>> newMembers =
          await _groupService.getGroupMembers(widget.groupId);
      setState(() {
        membersCopy = newMembers; // Actualizar la copia de miembros
      });
    } catch (e) {
      showError('Error al cargar miembros: $e');
    }
  }

// Eliminar miembro
  Future<void> removeMember(String memberId) async {
    try {
      // Asegurarse de que groupId y memberId sean Strings
      await _groupService.removeGroupMember(
        widget.groupId.toString(), // Asegurarse de que sea un String
        memberId.toString(), // Asegurarse de que sea un String
      );
      print("groupId: ${widget.groupId}, memberId: $memberId");
      loadMembers(); // Recargar la lista de miembros
    } catch (e) {
      showError('Error al eliminar miembro: $e');
    }
  }

  // Mostrar error
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Agregar miembro
  void addMember(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMemberScreen(groupId: widget.groupId),
      ),
    ).then((_) => loadMembers()); // Recargar miembros al volver
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de miembros'),
        actions: [
          if (widget.currentUserId == widget.creatorId) // Solo para el creador
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => addMember(context),
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: membersCopy.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(membersCopy[index]['name'] ?? 'Desconocido'),
            trailing: widget.currentUserId == widget.creatorId
                ? IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      removeMember(membersCopy[index]['uid']
                          .toString()); // Asegurarse de que sea un String
                    },
                  )
                : null,
          );
        },
      ),
    );
  }
}
