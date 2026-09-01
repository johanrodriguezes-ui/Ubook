import 'package:flutter/material.dart';
import 'dart:async';
import 'package:ubook/services/chatservice.dart';
import 'package:ubook/services/auth_service.dart';
import 'package:ubook/chat_window.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final AuthService _authService = AuthService();
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> chats = [];
  List<Map<String, dynamic>> availableUsers = [];
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    loadChats();
    _startPolling(); // Iniciar el polling al cargar el chat
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // Cancelamos el polling al destruir el widget
    super.dispose();
  }

  // Iniciar el polling cada 10 segundos (puedes ajustar el intervalo)
  void _startPolling() {
    _pollingTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      loadChats(); // Volvemos a cargar los chats cada 10 segundos
    });
  }

  // Cargar los chats existentes
  Future<void> loadChats() async {
    String? currentUserId = await _authService.getUserId();

    if (currentUserId != null) {
      // Obtener los chats en los que está involucrado el usuario actual
      List<Map<String, dynamic>> loadedChats =
          await _chatService.getChats(currentUserId);

      print("Chats cargados: $loadedChats");

      // Crear un Map para almacenar los chats únicos con la información formateada
      Map<String, Map<String, dynamic>> uniqueChats = {};

      for (var chat in loadedChats) {
        // Determinar el ID del otro usuario en el chat
        String otherUserId = (chat['user_id'].toString() == currentUserId)
            ? chat['chat_partner_id'].toString()
            : chat['user_id'].toString();

        // Obtener el nombre del otro usuario
        String otherUserName = chat['user_name'] ?? 'Usuario desconocido';

        // Obtener el último mensaje
        String message = chat['last_message']?.toString() ?? 'Sin mensajes';

        // Obtener el timestamp ya formateado
        String formattedTimestamp = chat['timestamp'];

        // Agregar el chat al Map de chats únicos
        uniqueChats[otherUserId] = {
          'name': otherUserName,
          'message': message,
          'timestamp': formattedTimestamp,
          'receiver_id': otherUserId,
        };
      }

      // Actualizar el estado de la UI con los chats únicos
      setState(() {
        chats = uniqueChats.values.toList(); // Convertimos a lista
      });

      print("Chats únicos: $chats");
    }
  }

  // Iniciar un nuevo chat
  void startNewChat() async {
    String? currentUserId = await _authService.getUserId();
    if (currentUserId != null) {
      List<Map<String, dynamic>> users =
          await _chatService.getAvailableUsers(currentUserId);

      // Verificar si hay usuarios disponibles
      if (users.isNotEmpty) {
        setState(() {
          availableUsers = users;
        });
        _showUserSelectionDialog();
      } else {
        _showNoAvailableUsersDialog(); // Si no hay usuarios, mostramos otro diálogo
      }
    }
  }

// En _showUserSelectionDialog, eliminamos la llamada a la creación del chat
  void _showUserSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selecciona un usuario para chatear'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableUsers.length,
              itemBuilder: (context, index) {
                var user = availableUsers[index];
                return ListTile(
                  title: Text(user['name'] ?? 'Usuario desconocido'),
                  onTap: () {
                    Navigator.pop(context);
                    // Al seleccionar un usuario, abrimos la ventana de chat
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatWindow(
                          receiverId: user['uid'].toString(),
                          receiverName: user['name'] ?? 'Usuario desconocido',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Diálogo cuando no hay usuarios disponibles
  void _showNoAvailableUsersDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No hay usuarios disponibles'),
          content: Text(
              'No hay otros usuarios con los que puedas iniciar un chat en este momento.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: chats.isEmpty
          ? Center(child: Text('No hay chats disponibles.'))
          : ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                var chat = chats[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green, // Fondo verde
                    child: Icon(Icons.person,
                        color: Colors.white), // Ícono de persona en blanco
                  ),
                  title: Text(chat['name'] ?? 'Usuario desconocido'),
                  subtitle: Row(
                    children: [
                      Expanded(child: Text(chat['message'] ?? 'Sin mensajes')),
                      if (chat['is_seen'] ==
                          true) // Muestra un ícono si el mensaje fue visto
                        Icon(Icons.check, color: Colors.blue, size: 16),
                    ],
                  ),
                  trailing: Text(chat['timestamp'] ?? ''),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatWindow(
                          receiverId: chat['receiver_id'] ?? '',
                          receiverName: chat['name'] ?? 'Usuario desconocido',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: startNewChat, // Llamada para iniciar un nuevo chat
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor, // Color del botón
      ),
    );
  }
}

