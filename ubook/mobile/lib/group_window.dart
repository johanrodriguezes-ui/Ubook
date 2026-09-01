import 'package:flutter/material.dart';
import 'dart:async'; // Importar Timer
import 'package:ubook/services/group_service.dart';
import 'package:ubook/services/auth_service.dart';
import 'package:ubook/listmembers.dart'; // Importamos la pantalla de lista de miembros
import 'package:collection/collection.dart'; // Para comparar listas
import 'package:intl/intl.dart'; // Importar para formatear fecha y hora

class GroupWindow extends StatefulWidget {
  final String groupId;
  final String creatorId;
  final String groupName;

  GroupWindow({
    required this.groupId,
    required this.creatorId,
    required this.groupName,
    Key? key,
  }) : super(key: key);

  @override
  _GroupWindowState createState() => _GroupWindowState();
}

class _GroupWindowState extends State<GroupWindow> {
  final GroupService _groupService = GroupService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> messages = [];
  List<Map<String, dynamic>> members = [];
  String? currentUserId;
  TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController =
      ScrollController(); // Añadir ScrollController
  bool _isLoading = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    getCurrentUserId();
    // Configurar el polling para ejecutar loadMessages cada 5 segundos
    _pollingTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      loadMessages(); // Actualizar los mensajes periódicamente
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // Cancelar el timer cuando se destruye el widget
    _messageController.dispose(); // Liberar el controlador del TextField
    _scrollController.dispose(); // Liberar el ScrollController
    super.dispose();
  }

  // Desplazar al final de la lista
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Obtener el ID del usuario actual
  void getCurrentUserId() async {
    currentUserId = await _authService.getUserId();
    await loadMessages();
    await loadMembers();
    setState(() {});
  }

// Cargar mensajes del grupo
  Future<void> loadMessages() async {
    try {
      List<Map<String, dynamic>> rawMessages =
          await _groupService.getGroupMessages(widget.groupId);

      List<Map<String, dynamic>> newMessages = rawMessages.map((message) {
        String senderId = message['sender_id'].toString();
        String currentUserIdStr = currentUserId.toString();
        bool isSender = senderId == currentUserIdStr;

        return {
          ...message,
          'isSender': isSender,
        };
      }).toList();

      // Solo actualizar si los mensajes son diferentes
      if (newMessages.length != messages.length ||
          !ListEquality().equals(newMessages, messages)) {
        setState(() {
          messages = newMessages;
        });
        _scrollToBottom(); // Desplazar al final cuando se carguen nuevos mensajes
      }
    } catch (e) {
      showError('Error al cargar mensajes: $e');
    }
  }

  // Cargar miembros del grupo
  Future<void> loadMembers() async {
    try {
      members = await _groupService.getGroupMembers(widget.groupId);
      setState(() {}); // Actualizar lista de miembros
    } catch (e) {
      showError('Error al cargar miembros: $e');
    }
  }

  // Enviar un nuevo mensaje
  Future<void> sendMessage() async {
    String message = _messageController.text;
    if (message.isNotEmpty) {
      try {
        await _groupService.sendMessageToGroup(
          widget.groupId,
          currentUserId!,
          message,
          null,
        );
        _messageController.clear(); // Limpiar el campo de mensaje

        // Añadir el mensaje localmente sin recargar toda la lista
        setState(() {
          messages.add({
            'message': message,
            'isSender': true,
            'sender_id': currentUserId,
          });
        });
        _scrollToBottom(); // Desplazar al final cuando se envíe un nuevo mensaje
      } catch (e) {
        showError('Error al enviar el mensaje: $e');
      }
    }
  }

// Editar mensaje
  Future<void> _editMessage(String messageId, String currentMessage) async {
    TextEditingController _editController =
        TextEditingController(text: currentMessage);

    // Mostrar un diálogo para editar el mensaje
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar mensaje'),
          content: TextField(
            controller: _editController,
            decoration:
                InputDecoration(hintText: 'Escribe tu nuevo mensaje...'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                String newMessage = _editController.text;
                if (newMessage.isNotEmpty) {
                  try {
                    await _groupService.editGroupMessage(messageId, newMessage);
                    Navigator.pop(context);
                    await loadMessages(); // Recargar los mensajes después de editar
                  } catch (e) {
                    showError('Error al editar el mensaje: $e');
                  }
                }
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

// Eliminar mensaje
  Future<void> _deleteMessage(String messageId) async {
    try {
      await _groupService.deleteGroupMessage(messageId);
      await loadMessages(); // Recargar los mensajes después de eliminar
    } catch (e) {
      showError('Error al eliminar el mensaje: $e');
    }
  }

  // Mostrar error
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Navegar a la lista de miembros
  void navigateToMembersList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MembersListScreen(
          members: members,
          groupId: widget.groupId,
          creatorId: widget.creatorId,
          currentUserId: currentUserId,
        ),
      ),
    );
  }

  // Salir del grupo
  Future<void> leaveGroup() async {
    try {
      // Asegurarse de que los valores sean cadenas
      String groupId = widget.groupId.toString();
      String userId = currentUserId!.toString();

      await _groupService.removeGroupMember(groupId, userId);
      Navigator.pop(context); // Volver a la pantalla anterior después de salir
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Has salido del grupo con éxito')),
      );
    } catch (e) {
      showError('Error al salir del grupo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        actions: [
          IconButton(
            icon: Icon(Icons.group),
            onPressed: navigateToMembersList,
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              // Lógica para salir del grupo
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    key: Key('messagesList'),
                    controller: _scrollController, // Asignar ScrollController
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index];
                      bool isSender = message['isSender'];

                      return MessageWidget(
                        key: Key(message['message_id'].toString()),
                        message: message['message'],
                        senderName: message['senderName'] ?? 'Desconocido',
                        isSender: isSender,
                        timestamp: message['timestamp'].toString(),
                        onEdit: () => _editMessage(
                            message['message_id'].toString(),
                            message['message']),
                        onDelete: () =>
                            _deleteMessage(message['message_id'].toString()),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  final String message;
  final String senderName;
  final bool isSender;
  final String timestamp;
  final Function() onEdit; // Callback para editar
  final Function() onDelete; // Callback para eliminar

  const MessageWidget({
    Key? key,
    required this.message,
    required this.senderName,
    required this.isSender,
    required this.timestamp,
    required this.onEdit, // Incluir el callback de edición
    required this.onDelete, // Incluir el callback de eliminación
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedTime = '';
    try {
      DateTime parsedTimestamp = DateTime.parse(timestamp);
      formattedTime = DateFormat('hh:mm a').format(parsedTimestamp);
    } catch (e) {
      formattedTime = 'Hora desconocida';
    }

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: isSender // Solo mostrar menú si el usuario es el remitente
            ? () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Wrap(
                      children: [
                        ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Editar'),
                          onTap: () {
                            Navigator.pop(context);
                            onEdit();
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.delete),
                          title: Text('Eliminar'),
                          onTap: () {
                            Navigator.pop(context);
                            onDelete();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            : null, // Deshabilitar si no es el remitente
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: isSender ? Colors.blue[200] : Colors.grey[300],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
              bottomLeft: isSender ? Radius.circular(12.0) : Radius.zero,
              bottomRight: isSender ? Radius.zero : Radius.circular(12.0),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                isSender ? 'Tú' : senderName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 5),
              Text(message),
              SizedBox(height: 5),
              Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

      ),
    );
  }
}
