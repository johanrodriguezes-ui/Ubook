import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:logger/logger.dart';
import 'package:ubook/services/chatservice.dart';
import 'package:ubook/services/auth_service.dart';

class ChatWindow extends StatefulWidget {
  final String receiverId; // ID del usuario con quien estamos chateando
  final String receiverName; // Nombre del usuario con quien estamos chateando

  ChatWindow({required this.receiverId, required this.receiverName});

  @override
  _ChatWindowState createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {
  final Logger logger = Logger(); // Inicializado en el estado
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  String? currentUserId;
  double _dateMarkerOpacity = 1.0;
  Timer? _pollingTimer;
  Timer? _dateMarkerTimer;
  String currentDateMarker = '';

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    _startPolling();
    _scrollController.addListener(_handleScroll);
  }

  @override
  Future<void> _loadCurrentUserId() async {
    currentUserId = await _authService.getUserId();
    if (currentUserId != null) {
      await _loadMessages();
    }
  }

  Future<void> _loadMessages() async {
    if (currentUserId != null && widget.receiverId != null) {
      try {
        // Obtener mensajes del chat entre currentUserId y receiverId
        List<Map<String, dynamic>> fetchedMessages = await _chatService
            .getChatMessages(currentUserId!, widget.receiverId!);

        // Solo actualizar el estado si hay nuevos mensajes
        if (fetchedMessages.isNotEmpty) {
          setState(() {
            messages = fetchedMessages.map((message) {
              return {
                // messageId como int
                'messageId': message['message_id']
                    as int, // Asegura que sea tratado como entero
                'senderId': message['sender_id'] as int, // Igual para sender_id

                // Verificación de que 'message' es un String o asignar un valor predeterminado
                'message': message['message'] ?? 'Mensaje no disponible',

                // timestamp es tratado como cadena para convertir luego a DateTime
                'timestamp':
                    DateTime.parse(message['timestamp']).toIso8601String(),

                // Comparación directa para determinar si el mensaje es del usuario actual
                'isSender':
                    message['sender_id'].toString() == currentUserId.toString(),

                // Conversión del campo booleano
                'isSeen': message['is_seenmessages'] == 1,
              };
            }).toList();

            // Ordenar mensajes por timestamp
            messages.sort((a, b) => DateTime.parse(a['timestamp'])
                .compareTo(DateTime.parse(b['timestamp'])));
          });

          // Desplazar el scroll hacia abajo después de cargar los mensajes
          _scrollToBottom();
        }
      } catch (e) {
        print("Error al cargar mensajes: $e");
      }
    }
  }

  // Iniciar polling
  void _startPolling() {
    _pollingTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      _loadMessages(); // Llamar a _loadMessages cada 2 segundos
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // Cancela el temporizador de polling
    _dateMarkerTimer?.cancel(); // Cancela el temporizador de marcador de fecha
    _scrollController.dispose(); // Libera el controlador de desplazamiento
    super.dispose();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty && currentUserId != null) {
      String message = _messageController.text.trim();

      logger.i(
          "Enviando mensaje: '$message' de usuario ID: $currentUserId a receptor ID: ${widget.receiverId}");

      // Crea o inserta el chat antes de enviar el mensaje
      await _chatService.createOrInsertChat(
          currentUserId!, widget.receiverId, message);

      // Envía el mensaje al receptor específico
      bool success = await _chatService.sendMessage(
          currentUserId!, widget.receiverId, message);

      logger.i("Respuesta del servidor: $success");

      if (success) {
        setState(() {
          messages.add({
            'senderId': currentUserId!,
            'message': message,
            'timestamp': DateTime.now().toIso8601String(),
            'isSender': true,
            'receiverName': widget.receiverName,
            'isSeen': false, // Inicialmente se marca como no visto
          });
          _messageController.clear();
        });
        _scrollToBottom();
      } else {
        logger
            .e("Error al enviar el mensaje. Respuesta del servidor: $success");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar el mensaje')),
        );
      }
    } else {
      logger.w("El mensaje está vacío o el ID del usuario actual es nulo.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No puedes enviar un mensaje vacío')),
      );
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      bool success = await _chatService
          .deleteMessage(messageId.toString()); // Convierte a String

      if (success) {
        setState(() {
          messages.removeWhere((message) =>
              message['messageId'].toString() == messageId.toString());
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mensaje eliminado correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el mensaje')),
        );
      }
    } catch (e) {
      print("Error al intentar eliminar el mensaje: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al intentar eliminar el mensaje')),
      );
    }
  }

  Future<void> _updateMessage(String messageId, String newMessage) async {
    try {
      bool success = await _chatService.updateMessage(
          messageId.toString(), newMessage); // Convierte a String

      if (success) {
        setState(() {
          // Actualiza el mensaje en la interfaz
          int messageIndex = messages.indexWhere(
            (message) =>
                message['messageId'].toString() == messageId.toString(),
          );
          if (messageIndex != -1) {
            messages[messageIndex]['message'] = newMessage;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mensaje editado correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al editar el mensaje')),
        );
      }
    } catch (e) {
      print("Error al intentar editar el mensaje: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al intentar editar el mensaje')),
      );
    }
  }

  // Método que maneja el desplazamiento
  void _handleScroll() {
    if (_scrollController.position.atEdge) return;

    // Calcular el índice del mensaje visible
    int firstVisibleIndex =
        (_scrollController.offset / 60).floor(); // Aproximado

    if (firstVisibleIndex >= 0 && firstVisibleIndex < messages.length) {
      DateTime messageDate =
          DateTime.parse(messages[firstVisibleIndex]['timestamp']);
      String formattedDate = DateFormat('yMMMd').format(messageDate);

      // Actualiza el encabezado según la fecha visible y reinicia el temporizador
      setState(() {
        currentDateMarker = _isToday(messageDate)
            ? 'A partir de aquí los mensajes son de hoy'
            : 'A partir de aquí los mensajes son del $formattedDate';
        _dateMarkerOpacity = 1.0; // Mostrar inmediatamente el marcador de fecha
      });

      // Reinicia el temporizador para comenzar el desvanecimiento
      _restartDateMarkerTimer();
    }
  }

  // Función para ocultar el marcador de fecha con desvanecimiento después de un tiempo
  void _restartDateMarkerTimer() {
    // Cancelar el temporizador si ya existe uno
    if (_dateMarkerTimer != null) {
      _dateMarkerTimer!.cancel();
    }

    // Iniciar un nuevo temporizador de 3 segundos
    _dateMarkerTimer = Timer(Duration(seconds: 3), () {
      setState(() {
        _dateMarkerOpacity =
            0.0; // Cambiar la opacidad para iniciar el desvanecimiento
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: Column(
        children: [
          // Mensajes y encabezado flotante
          Expanded(
            child: Stack(
              children: [
                // Lista de mensajes
                Positioned.fill(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index];
                      DateTime timestamp;

                      try {
                        timestamp = DateTime.parse(message['timestamp']);
                      } catch (e) {
                        timestamp = DateTime.now();
                      }

                      return GestureDetector(
                        onTap: () {
                          // Menú contextual
                          showMenu(
                            context: context,
                            position: RelativeRect.fromLTRB(100, 100, 0, 0),
                            items: [
                              PopupMenuItem(
                                child: Text("Editar"),
                                value: "edit",
                              ),
                              PopupMenuItem(
                                child: Text("Reenviar"),
                                value: "forward",
                              ),
                              PopupMenuItem(
                                child: Text("Eliminar"),
                                value: "delete",
                              ),
                            ],
                          ).then((value) {
                            if (value == "delete") {
                              _showDeleteConfirmation(message);
                            } else if (value == "edit") {
                              _editMessage(message);
                            } else if (value == "forward") {
                              _forwardMessage(message);
                            }
                          });
                        },
                        child: Align(
                          alignment: message['isSender']
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 8.0),
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: message['isSender']
                                  ? Colors.blue[200]
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12.0),
                                topRight: Radius.circular(12.0),
                                bottomLeft: message['isSender']
                                    ? Radius.circular(12.0)
                                    : Radius.circular(0),
                                bottomRight: message['isSender']
                                    ? Radius.circular(0)
                                    : Radius.circular(12.0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: message['isSender']
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['message'],
                                  style: TextStyle(color: Colors.black),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat('HH:mm').format(timestamp),
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    SizedBox(width: 4),
                                    if (message['isSender'])
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.check,
                                            color: message['isSeen']
                                                ? Colors.blue[800]
                                                : Colors.grey,
                                            size: 16,
                                          ),
                                          if (message['isSeen'])
                                            Icon(
                                              Icons.check,
                                              color: Colors.blue[800],
                                              size: 16,
                                            ),
                                        ],
                                      )
                                    else if (message['isSeen'])
                                      Icon(Icons.check,
                                          color: Colors.blue[800], size: 16),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Encabezado de fecha flotante
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    opacity: _dateMarkerOpacity, // Controlar opacidad
                    duration: Duration(milliseconds: 500),
                    child: _dateMarkerOpacity > 0.0
                        ? Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Text(
                                currentDateMarker,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
          // Campo de entrada de mensaje
          _buildMessageInput(),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> message) async {
    if (message['messageId'] == null) {
      print("Error: messageId es nulo");
      return; // Salir si messageId es nulo
    }

    // Convertir messageId a String en caso de ser int
    String messageId = message['messageId'].toString();

    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar mensaje'),
          content: Text('¿Estás seguro de que deseas eliminar este mensaje?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await _deleteMessage(messageId); // Usar 'messageId' como String
    }
  }

  void _editMessage(Map<String, dynamic> message) {
    TextEditingController _controller =
        TextEditingController(text: message['message']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Editar mensaje"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: "Editar mensaje"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () async {
                String newMessage = _controller.text.trim();

                if (newMessage.isNotEmpty && newMessage != message['message']) {
                  // Convertir messageId a String en caso de ser int
                  String messageId = message['messageId'].toString();

                  // Llamar al método para actualizar el mensaje en el servidor
                  await _updateMessage(messageId, newMessage);
                  setState(() {
                    // Actualizar el mensaje localmente
                    message['message'] = newMessage;
                  });
                }

                Navigator.of(context).pop(); // Cerrar el diálogo
              },
            ),
          ],
        );
      },
    );
  }

  Future<String?> _selectReceiver(
      List<Map<String, dynamic>> availableUsers) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Seleccionar receptor'),
          content: SingleChildScrollView(
            child: Column(
              children: availableUsers.map((user) {
                return ListTile(
                  title: Text(user['name']),
                  onTap: () {
                    Navigator.of(context)
                        .pop(user['uid'].toString()); // Cambié a 'uid'
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _forwardMessage(Map<String, dynamic> message) async {
    // Obtener la lista de usuarios disponibles desde el chat service
    List<Map<String, dynamic>> availableUsers =
        await _chatService.getAvailableUsers(currentUserId!);

    if (availableUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay usuarios disponibles para reenviar')),
      );
      return;
    }

    // Mostrar el cuadro de diálogo para seleccionar al usuario receptor
    String? selectedReceiverId = await _selectReceiver(availableUsers);
    print("Receptor seleccionado: $selectedReceiverId");

    if (selectedReceiverId == null) {
      print("Ningún receptor seleccionado o cancelado");
      return; // El usuario canceló la selección
    }

    // Usar el chat service para reenviar el mensaje
    print("Intentando reenviar el mensaje al receptor: $selectedReceiverId");
    bool success = await _chatService.sendMessage(
      currentUserId!,
      selectedReceiverId, // Aquí se usa el ID seleccionado del usuario
      message['message'], // Contenido del mensaje original
    );

    if (success) {
      // Registrar o crear un nuevo chat con el receptor seleccionado
      print("Mensaje reenviado con éxito a $selectedReceiverId");
      await _chatService.createOrInsertChat(
          currentUserId!, selectedReceiverId, message['message']);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mensaje reenviado con éxito')),
      );
    } else {
      print("Error al reenviar el mensaje");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al reenviar el mensaje')),
      );
    }
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
