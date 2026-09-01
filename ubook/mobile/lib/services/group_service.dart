import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:ubook/config/api_config.dart';

class GroupService {
  final logger = Logger();
  final String baseUrl = "${ApiConfig.baseUrl}/group";

  Future<List<Map<String, dynamic>>> getGroups(String userId) async {
    final String url = "$baseUrl/get_group_list.php?uid=$userId";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;

        if (data.isEmpty) {
          print("No se encontraron grupos.");
          return [];
        }

        return data.map((group) {
          return {
            'group_id': group['group_id'],
            'group_name': group['group_name'],
            'group_image': group['group_image'],
            'lastMessage': group['lastmessage'],
            'created_by': group['created_by'], // Asegúrate de incluir esto
          };
        }).toList();
      } else {
        print("Error al obtener grupos: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

// Crear un nuevo grupo
  Future<bool> createGroup(String groupName, String groupImage,
      String createdBy, String initialMessage) async {
    final String createGroupUrl = "$baseUrl/create_group.php";

    try {
      final response = await http.post(
        Uri.parse(createGroupUrl),
        body: {
          'group_name': groupName,
          'group_image': groupImage,
          'created_by': createdBy,
          'initial_message': initialMessage, // Pasamos el mensaje inicial
        },
      );

      // Imprimir la respuesta completa del servidor
      print("Respuesta del servidor: ${response.body}");

      final responseData = json.decode(response.body);
      return responseData['status'] == 'success';
    } catch (e) {
      print("Error al crear grupo: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableUsers(
      String userId, String groupId) async {
    final String availableUsersUrl =
        "$baseUrl/get_available_user_group.php?uid=$userId&group_id=$groupId";

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

  // Añadir miembros al grupo
  Future<bool> addGroupMember(String groupId, String userId) async {
    final String addMemberUrl = "$baseUrl/add_group_member.php";

    try {
      final response = await http.post(
        Uri.parse(addMemberUrl),
        body: {
          'group_id': groupId,
          'user_id': userId,
        },
      );

      logger.i("Respuesta del servidor (addGroupMember): ${response.body}");

      final responseData = json.decode(response.body);
      return responseData['status'] == 'success';
    } catch (e) {
      logger.e("Error al añadir miembro al grupo: $e");
      return false;
    }
  }

  // Obtener mensajes del grupo
  Future<List<Map<String, dynamic>>> getGroupMessages(String groupId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/groupmessages.php?group_id=$groupId'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return List<Map<String, dynamic>>.from(jsonResponse);
    } else {
      logger.e("Error al cargar mensajes: ${response.statusCode}");
      // No lanzar excepción, solo registrar el error
      return [];
    }
  }

// Obtener los miembros del grupo
  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/groupmembers.php?group_id=$groupId'));

    logger.i("Respuesta del servidor (getGroupMembers): ${response.body}");

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return List<Map<String, dynamic>>.from(jsonResponse);
    } else {
      logger.e("Error al cargar miembros: ${response.statusCode}");
      // No lanzar excepción, solo registrar el error
      return [];
    }
  }

  // Enviar un mensaje al grupo
  Future<void> sendMessageToGroup(
      String groupId, String senderId, String message, String? url) async {
    final response = await http.post(
      Uri.parse('$baseUrl/send_group_message.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(<String, String>{
        'group_id': groupId,
        'sender_id': senderId,
        'message': message,
        'url': url ?? '',
      }),
    );

    logger.i("Respuesta del servidor (sendMessageToGroup): ${response.body}");

    if (response.statusCode != 200) {
      logger.e("Error al enviar el mensaje: ${response.statusCode}");
      throw Exception('Error al enviar el mensaje');
    }
  }

  Future<void> deleteGroupMessage(String messageId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete_message_group.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(<String, String>{
        'message_id': messageId,
      }),
    );

    if (response.statusCode == 200) {
      logger.i("Mensaje eliminado exitosamente");
    } else {
      logger.e("Error al eliminar el mensaje: ${response.statusCode}");
      throw Exception('Error al eliminar el mensaje');
    }
  }

  Future<void> editGroupMessage(String messageId, String newMessage) async {
    final response = await http.post(
      Uri.parse('$baseUrl/edit_message.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(<String, String>{
        'message_id': messageId,
        'message': newMessage,
      }),
    );

    if (response.statusCode == 200) {
      logger.i("Mensaje actualizado exitosamente");
    } else {
      logger.e("Error al actualizar el mensaje: ${response.statusCode}");
      throw Exception('Error al actualizar el mensaje');
    }
  }

  Future<void> removeGroupMember(String groupId, String memberId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/remove_group_member.php'),
      headers: <String, String>{
        'Content-Type':
            'application/x-www-form-urlencoded', // Cambiado a form-urlencoded
      },
      body: {
        'group_id':
            groupId, // Asegúrate de que los valores se envíen como cadenas
        'member_id': memberId,
      },
    );

    // Imprimir la respuesta completa del servidor
    print('Respuesta del servidor: ${response.body}');

    // Manejar la respuesta si es necesario
    if (response.statusCode == 200) {
      print('Miembro eliminado con éxito');
    } else {
      print('Error al eliminar miembro: ${response.statusCode}');
    }
  }
}
