import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:ubook/config/api_config.dart';

class ChatService {
  final logger = Logger();
  final String baseUrl = "${ApiConfig.baseUrl}/chat";
  int? _lastMessageId;
  List<Map<String, dynamic>> _previousChats = [];

  Future<List<Map<String, dynamic>>> getChats(String userId) async {
    final String chatUrl = "$baseUrl/get_chatslist.php?uid=$userId";
    final String usersUrl = "$baseUrl/get_available_users.php?uid=$userId";

    try {
      // Llamar a la API de chats
      final chatResponse = await http.get(Uri.parse(chatUrl));
      if (chatResponse.statusCode == 200) {
        final chatData = jsonDecode(chatResponse.body) as List;

        // Extraemos los IDs de los chats (ambos, excluyendo el actual)
        final List<String> chatUserIds = chatData
            .map((chat) {
              return chat["user_id"].toString() == userId
                  ? chat["chat_partner_id"].toString()
                  : chat["user_id"].toString();
            })
            .toSet()
            .toList(); // Asegúrate de usar Set para obtener solo IDs únicos

        // Llamar a la API de usuarios disponibles
        final usersResponse = await http.get(Uri.parse(usersUrl));
        if (usersResponse.statusCode == 200) {
          final usersData = jsonDecode(usersResponse.body) as List;

          // Filtrar los usuarios que coinciden con los IDs de chatUserIds
          final filteredUsers = usersData.where((user) {
            return chatUserIds.contains(user['uid'].toString());
          }).toList();

          // Mapeamos los chats para añadir los nombres de los usuarios filtrados
          List<Map<String, dynamic>> currentChats = chatData.map((chat) {
            final String chatUserId = chat["user_id"].toString() == userId
                ? chat["chat_partner_id"].toString()
                : chat["user_id"].toString();

            // Buscamos el nombre del usuario en los usuarios filtrados
            final userName = filteredUsers.firstWhere(
                (user) => user['uid'].toString() == chatUserId, orElse: () {
              return {"name": "Usuario no disponible"};
            })['name'];

            return {
              "chatlist_id": chat["chatlist_id"],
              "last_message": chat["last_message"],
              "timestamp": chat["timestamp"],
              "user_id": chat["user_id"].toString(),
              "chat_partner_id": chat["chat_partner_id"].toString(),
              "user_name": userName,
            };
          }).toList();

          // Comparar con los chats anteriores para detectar cambios
          if (!_areChatsDifferent(_previousChats, currentChats)) {
            print("No hay cambios en los chats. No es necesario actualizar.");
            return _previousChats; // Devolver los chats anteriores
          }

          // Si hay cambios, actualizamos _previousChats y devolvemos los nuevos
          _previousChats = currentChats;
          return currentChats;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      print("Error al obtener chats: $e");
      return [];
    }
  }

  // Función para comparar si dos listas de chats son diferentes
  bool _areChatsDifferent(List<Map<String, dynamic>> previousChats,
      List<Map<String, dynamic>> currentChats) {
    if (previousChats.length != currentChats.length) {
      return true; // Si la longitud de las listas es diferente, hubo cambios
    }

    // Comparar cada chat en ambas listas (puedes ajustar esto según tus necesidades)
    for (int i = 0; i < previousChats.length; i++) {
      if (previousChats[i]['last_message'] != currentChats[i]['last_message'] ||
          previousChats[i]['timestamp'] != currentChats[i]['timestamp']) {
        return true; // Si un mensaje o timestamp ha cambiado, hay diferencias
      }
    }
    return false; // No hubo cambios
  }

  Future<List<Map<String, dynamic>>> getChatMessages(
      String userId, String partnerId) async {
    final String url =
        "$baseUrl/get_chat_messages.php?uid=$userId&partnerId=$partnerId";

    try {
      final response = await http.get(Uri.parse(url));

      // Imprime la respuesta JSON para ver su estructura real
      print("Respuesta JSON: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;

        if (data.isEmpty) {
          print("No se encontraron mensajes.");
          return [];
        }

        final newLastMessageId = data.last['message_id'];

        if (_lastMessageId != null && _lastMessageId == newLastMessageId) {
          return [];
        }

        _lastMessageId = newLastMessageId;

        return data.map((message) {
          return {
            // Aseguramos que 'message_id' y 'sender_id' se traten como int
            'message_id':
                message['message_id'] as int, // Cambio para asegurarnos
            'sender_id': message['sender_id'] as int, // Tratado como entero

            // El contenido del mensaje puede estar nulo, así que usamos un valor por defecto
            'message': message['message'] ?? 'Mensaje no disponible',

            // Convertimos 'timestamp' a String
            'timestamp': message['timestamp'].toString(),

            // 'is_seenmessages' como booleano
            'is_seenmessages': message['is_seenmessages'] == 1,
          };
        }).toList();
      } else {
        print("Error en la respuesta del servidor: ${response.statusCode}");
        throw Exception(
            'Error al obtener mensajes. Código: ${response.statusCode}');
      }
    } catch (e) {
      print("Error al obtener mensajes: $e");
      throw Exception('Error al obtener mensajes: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableUsers(String userId) async {
    final String availableUsersUrl =
        "$baseUrl/get_available_users.php?uid=$userId";

    try {
      final response = await http.get(Uri.parse(availableUsersUrl));
      logger.i(
          "Respuesta completa del servidor (getAvailableUsers): ${response.body}");

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          return List<Map<String, dynamic>>.from(data);
        } catch (e) {
          logger.e("Error al decodificar JSON en getAvailableUsers: $e");
          return [];
        }
      } else {
        logger.e(
            "Error de servidor en getAvailableUsers: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      logger.e("Error al obtener usuarios disponibles: $e");
      return [];
    }
  }

// Método para enviar un mensaje y registrar el chat
  Future<bool> sendMessage(
      String senderId, String receiverId, String message) async {
    final String sendMessageUrl =
        "$baseUrl/send_message.php"; // Cambia esta URL según tu implementación

    try {
      // Envía el mensaje
      final response = await http.post(
        Uri.parse(sendMessageUrl),
        body: {
          'sender_id': senderId,
          'receiver_id': receiverId,
          'message': message,
        },
      );

      if (response.statusCode == 200) {
        // Si el mensaje se envió correctamente, registrar el chat
        await createOrInsertChat(senderId, receiverId, message);
        return true;
      } else {
        logger.e("Error al enviar el mensaje: ${response.body}");
        return false;
      }
    } catch (e) {
      logger.e("Excepción al enviar el mensaje: $e");
      return false;
    }
  }

// Método para crear o insertar un nuevo chat en la base de datos
  Future<void> createOrInsertChat(
      String userId, String chatPartnerId, String lastMessage) async {
    final String createOrInsertChatUrl =
        "$baseUrl/create_or_insert_chat.php"; // Cambia esta URL según tu implementación

    try {
      final response = await http.post(
        Uri.parse(createOrInsertChatUrl),
        body: {
          'user_id': userId,
          'chat_partner_id': chatPartnerId,
          'last_message': lastMessage,
        },
      );

      // Imprimir la respuesta completa del servidor (ya sea HTML o JSON)
      logger.i("Respuesta completa del servidor: ${response.body}");

      // Manejo de la respuesta solo si es JSON válido
      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          logger.i(
              "Respuesta JSON al intentar crear o insertar el chat: $responseData");
        } catch (e) {
          logger.e(
              "No se pudo decodificar la respuesta como JSON. Probablemente no es un JSON válido.");
        }
      } else {
        logger.e("Error en la respuesta: ${response.body}");
        logger.e("Código de estado: ${response.statusCode}");
      }
    } catch (e) {
      logger.e("Error al intentar crear o insertar el chat: $e");
    }
  }

// Función para eliminar un mensaje
  Future<bool> deleteMessage(String messageId) async {
    final String deleteMessageUrl = "$baseUrl/delete_message.php";

    try {
      final response = await http.post(
        Uri.parse(deleteMessageUrl),
        body: {
          'message_id': messageId.toString(), // Asegúrate de convertir a String
        },
      );

      final responseData = json.decode(response.body);

      if (responseData['status'] == 'success') {
        return true;
      } else {
        print("Error en el servidor: ${responseData['message']}");
        return false;
      }
    } catch (e) {
      print("Excepción al eliminar el mensaje: $e");
      return false;
    }
  }

// Función para actualizar un mensaje
  Future<bool> updateMessage(String messageId, String newMessage) async {
    final String updateMessageUrl =
        "$baseUrl/update_message.php"; // Cambia la URL según tu backend

    try {
      print(
          "Enviando datos: message_id = ${messageId.toString()}, new_message = $newMessage");
      final response = await http.post(
        Uri.parse(updateMessageUrl),
        body: {
          'message_id': messageId.toString(), // Asegúrate de convertir a String
          'new_message': newMessage,
        },
      );

      // Imprimir la respuesta completa del servidor
      print("Respuesta del servidor: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['status'] == 'success';
      } else {
        print("Error al actualizar el mensaje: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error al intentar actualizar el mensaje: $e");
      return false;
    }
  }
}
