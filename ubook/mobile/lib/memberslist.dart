import 'package:flutter/material.dart';
import 'package:ubook/services/community_service.dart'; // Servicio para gestionar comunidades

class CommunityMembersListScreen extends StatefulWidget {
  final int
      communityId; // communityId es int, pero lo convertiremos a String cuando sea necesario

  const CommunityMembersListScreen({
    required this.communityId,
  });

  @override
  _CommunityMembersListScreenState createState() =>
      _CommunityMembersListScreenState();
}

class _CommunityMembersListScreenState
    extends State<CommunityMembersListScreen> {
  List communityMembers = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchCommunityMembers();
  }

  // Función para obtener los miembros de la comunidad
  Future<void> fetchCommunityMembers() async {
    try {
      print("Fetching community members for ID: ${widget.communityId}");
      final fetchedMembers = await CommunityService().getCommunityMembers(
          widget.communityId.toString()); // Convertimos communityId a String

      setState(() {
        communityMembers = fetchedMembers;
        isLoading = false;
      });
    } catch (error, stacktrace) {
      print("Error while fetching community members: $error");
      print("Stacktrace: $stacktrace");
      setState(() {
        isLoading = false;
        hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los miembros: $error')),
      );
    }
  }

  // Función para obtener usuarios disponibles y mostrar un BottomSheet
  Future<void> showAvailableUsers() async {
    try {
      print("Fetching available users for community ID: ${widget.communityId}");
      final availableUsers =
          await CommunityService().getAvailableUsersForCommunity(
        'currentUserId', // Sustituir con el ID actual del usuario
        widget.communityId.toString(), // Convertimos communityId a String
      );

      print("Available users: $availableUsers");

      showModalBottomSheet(
        context: context,
        builder: (context) {
          return availableUsers.isEmpty
              ? const Center(child: Text('No hay usuarios disponibles'))
              : ListView.builder(
                  itemCount: availableUsers.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(availableUsers[index]['name']),
                      onTap: () {
                        print(
                            "Adding user ${availableUsers[index]['uid']} to community");
                        addUserToCommunity(availableUsers[index]['uid']
                            .toString()); // Asegúrate de convertir el uid a String
                      },
                    );
                  },
                );
        },
      );
    } catch (e, stacktrace) {
      print("Error fetching available users: $e");
      print("Stacktrace: $stacktrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar usuarios disponibles: $e')),
      );
    }
  }

  // Función para añadir un usuario a la comunidad
  Future<void> addUserToCommunity(String userId) async {
    try {
      print("Adding user $userId to community ${widget.communityId}");
      final success = await CommunityService().addCommunityMember(
        widget.communityId, // communityId como int
        userId, // userId sigue siendo String, asumiendo que este es el tipo correcto
      );

      Navigator.pop(context); // Cerrar el BottomSheet

      if (success) {
        print("User $userId added successfully to community");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Miembro añadido exitosamente')),
        );
        fetchCommunityMembers(); // Refrescar la lista de miembros
      } else {
        print("Failed to add user $userId to community");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al añadir miembro')),
        );
      }
    } catch (e, stacktrace) {
      print("Error while adding user to community: $e");
      print("Stacktrace: $stacktrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al añadir miembro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Miembros de la Comunidad'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add), // Icono para añadir miembros
            onPressed:
                showAvailableUsers, // Mostrar la lista de usuarios disponibles
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text('Error al cargar los miembros'))
              : communityMembers.isEmpty
                  ? const Center(
                      child: Text('No hay miembros en esta comunidad'),
                    )
                  : ListView.builder(
                      itemCount: communityMembers.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(communityMembers[index]['user_name']),
                          leading: communityMembers[index]['user_image'] !=
                                      null &&
                                  communityMembers[index]['user_image']
                                      .isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      communityMembers[index]['user_image']),
                                )
                              : const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                        );
                      },
                    ),
    );
  }
}
