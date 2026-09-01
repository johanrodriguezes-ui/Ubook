import 'dart:async'; // Importar para el Timer
import 'package:flutter/material.dart';
import 'package:ubook/services/community_service.dart'; // Servicio de comunidad
import 'package:ubook/memberslist.dart'; // Importa el archivo para la lista de miembros
import 'package:ubook/group_window.dart'; // Importa la pantalla de detalles del grupo
import 'package:ubook/services/auth_service.dart';

class CommunityWindow extends StatefulWidget {
  final int communityId;
  final String communityName;

  const CommunityWindow({
    required this.communityId,
    required this.communityName,
  });

  @override
  _CommunityWindowState createState() => _CommunityWindowState();
}

class _CommunityWindowState extends State<CommunityWindow> {
  final AuthService _authService = AuthService();
  List groups = [];
  int? selectedGroupId;
  bool isLoading = true; // Indicador de carga
  bool hasError = false; // Indicador de errores
  Timer? _timer; // Timer para el polling

  @override
  void initState() {
    super.initState();
    fetchGroups(); // Obtener grupos de la comunidad actual

    // Iniciar el polling
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchGroups(); // Volver a cargar los grupos cada 10 segundos
    });
  }

  // Función para obtener los grupos de la comunidad actual
  Future<void> fetchGroups() async {
    try {
      final fetchedGroups = await CommunityService().getCommunityGroups(
        widget.communityId.toString(),
      );
      setState(() {
        groups = fetchedGroups;
        isLoading = false; // Ocultar carga
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        hasError = true; // Mostrar error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los grupos: $error')),
      );
    }
  }

  // Función cuando se selecciona un grupo de la lista
  void onGroupSelected(int groupId, String groupName, String creatorId) {
    print(
        "Seleccionado groupId: $groupId, groupName: $groupName, createdBy: $creatorId");

    setState(() {
      selectedGroupId = groupId;
    });

    // Navegar a los detalles del grupo seleccionado
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupWindow(
          groupId: groupId.toString(), // Pasa el groupId correcto
          creatorId: creatorId, // Usa 'creator_id'
          groupName: groupName, // Pasa el nombre del grupo
        ),
      ),
    );
  }

  Future<void> _leaveCommunity() async {
    final userId = await _authService
        .getUserId(); // Suponiendo que ya tienes la función para obtener el ID del usuario

    final success = await CommunityService().removeCommunityMember(
      widget.communityId.toString(),
      userId.toString(),
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Has salido de la comunidad')),
      );
      Navigator.pop(context); // Vuelve a la pantalla anterior
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al salir de la comunidad')),
      );
    }
  }

  // Navegar a la lista de miembros de la comunidad
  void _navigateToMembersList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityMembersListScreen(
          communityId: widget.communityId, // Usa el ID de la comunidad actual
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancelar el Timer cuando se destruye el widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.communityName),
        actions: [
          IconButton(
            icon: Icon(Icons.people),
            onPressed: _navigateToMembersList, // Navega a la lista de miembros
            tooltip: 'Lista de Miembros',
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed:
                _leaveCommunity, // Llama a la función para salir de la comunidad
            tooltip: 'Salir de la comunidad',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Indicador de carga
          : hasError
              ? const Center(child: Text('Error al cargar los grupos'))
              : groups.isEmpty
                  ? const Center(child: Text('No hay grupos disponibles'))
                  : ListView.builder(
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final groupName = groups[index]['group_name'] ??
                            'Sin nombre'; // Valor predeterminado
                        final creatorId = groups[index]['creator_id'] != null
                            ? groups[index]['creator_id'].toString()
                            : 'Desconocido'; // Conversión segura
                        final groupId = groups[index]
                            ['group_id']; // Obtén el verdadero group_id

                        // Imprimir valores para verificar
                        print('Datos del grupo completo: ${groups[index]}');
                        print(
                            'group_name: $groupName, created_by: $creatorId, group_id: $groupId');

                        return ListTile(
                          title: Text(groupName),
                          subtitle: Text(groups[index]['lastMessage'] ??
                              'No hay mensajes'), // Muestra el último mensaje
                          selected:
                              groupId.toString() == selectedGroupId.toString(),
                          onTap: () => onGroupSelected(
                            groupId, // Pasa el verdadero group_id
                            groupName, // Pasa el nombre del grupo
                            creatorId, // Pasa el 'creator_id'
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            showAvailableGroupsDialog, // Mostrar diálogo de grupos disponibles
        child: Icon(Icons.add),
        tooltip: 'Añadir Grupo',
      ),
    );
  }

// Función para mostrar el diálogo de grupos disponibles
  Future<void> showAvailableGroupsDialog() async {
    try {
      final availableGroups =
          await CommunityService().getAvailableGroups(widget.communityId);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Grupos Disponibles'),
            content: availableGroups.isEmpty
                ? Text('No hay grupos disponibles')
                : SizedBox(
                    height:
                        200, // Fija la altura del ListView para evitar el error
                    width: double
                        .maxFinite, // Fija un ancho máximo si es necesario
                    child: ListView.builder(
                      shrinkWrap:
                          true, // Permite que el ListView se ajuste a su contenido
                      itemCount: availableGroups.length,
                      itemBuilder: (context, index) {
                        final group = availableGroups[index];
                        return ListTile(
                          title: Text(group['group_name']),
                          onTap: () {
                            Navigator.pop(context); // Cerrar el diálogo
                            addSelectedGroup(
                                group); // Añadir grupo seleccionado
                          },
                        );
                      },
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cerrar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los grupos disponibles')),
      );
    }
  }

// Función para añadir el grupo seleccionado a la comunidad
  Future<void> addSelectedGroup(Map<String, dynamic> group) async {
    final success = await CommunityService().addCommunityGroup(
      widget.communityId.toString(),
      group['group_id'].toString(),
      group['group_name'],
      group['group_image'],
      group['created_by'].toString(),
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Grupo añadido con éxito')),
      );
      fetchGroups(); // Actualizar los grupos de la comunidad
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al añadir el grupo')),
      );
    }
  }
}

