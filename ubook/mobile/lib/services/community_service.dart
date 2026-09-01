import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:ubook/config/api_config.dart';

class CommunityService {
  final logger = Logger();
  final String baseUrl = "${ApiConfig.baseUrl}/community";

  // Obtener lista de comunidades
  Future<List<Map<String, dynamic>>> getCommunities(String userId) async {
    final String url = "$baseUrl/get_community_list.php?uid=$userId";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;

        if (data.isEmpty) {
          logger.w("No se encontraron comunidades.");
          return [];
        }

        return data.map((community) {
          return {
            'community_id': community['community_id'],
            'community_name': community['community_name'],
            'community_image': community['community_image'],
            'lastMessage': community['lastmessage'],
            'created_by': community['created_by'],
          };
        }).toList();
      } else {
        logger.e("Error al obtener comunidades: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      logger.e("Error: $e");
      return [];
    }
  }

// Obtener lista de grupos para una comunidad
  Future<List<Map<String, dynamic>>> getCommunityGroups(
      String communityId) async {
    final String url = "$baseUrl/communitygroups.php?community_id=$communityId";

    try {
      final response = await http.get(Uri.parse(url));

      // Imprimir el cuerpo de la respuesta completa del servidor
      print("Respuesta del servidor: ${response.body}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body) as List;

        if (data.isEmpty) {
          logger.w("No se encontraron grupos.");
          return [];
        }

        return data.map((group) {
          return {
            'community_group_id': group['community_group_id'],
            'group_id': group['group_id'], // Añadir el verdadero group_id aquí
            'group_name': group['group_name'],
            'group_image': group['group_image'], // Puede ser null
            'lastMessage': group['lastmessage'],
            'creator_id': group['created_by'], // Obtener el creador del grupo
          };
        }).toList();
      } else {
        logger.e("Error al obtener grupos: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      logger.e("Error: $e");
      return [];
    }
  }

  Future<bool> addCommunityGroup(String communityId, String groupId,
      String groupName, String groupImage, String createdBy) async {
    final String addGroupUrl = "$baseUrl/add_communitygroups.php";

    try {
      // Imprimir los datos que se van a enviar
      print(
          "Sending data: community_id: $communityId, group_id: $groupId, group_name: $groupName, group_image: $groupImage, created_by: $createdBy");

      final response = await http.post(
        Uri.parse(addGroupUrl),
        headers: {
          'Content-Type':
              'application/json', // Especificar que se envían datos JSON
        },
        body: jsonEncode({
          'community_id': communityId,
          'group_id': groupId,
          'group_name': groupName,
          'group_image': groupImage,
          'created_by': createdBy,
        }),
      );

      // Verificar la respuesta del servidor
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          print('Server response: ${response.body}');
          return true;
        } else {
          print('Server response: ${response.body}');
          return false;
        }
      } else {
        print('Server response: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<List> getAvailableGroups(int communityId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_available_groups.php?community_id=$communityId'),
    );

    if (response.statusCode == 200) {
      final List availableGroups = json.decode(response.body);
      return availableGroups;
    } else {
      throw Exception('Error al cargar los grupos disponibles');
    }
  }

// Crear una nueva comunidad
  Future<bool> createCommunity(
      String communityName, String communityImage, String createdBy) async {
    final String createCommunityUrl = "$baseUrl/create_community.php";

    try {
      final response = await http.post(
        Uri.parse(createCommunityUrl),
        body: {
          'community_name': communityName,
          'community_image': communityImage,
          'created_by': createdBy,
        },
      );

      logger.i("Respuesta del servidor (createCommunity): ${response.body}");

      final responseData = json.decode(response.body);

      // Cambia de responseData['status'] == 'success' a responseData['success'] == true
      return responseData['success'] == true;
    } catch (e) {
      logger.e("Error al crear comunidad: $e");
      return false;
    }
  }

  // Obtener usuarios disponibles para añadir a la comunidad
  Future<List<Map<String, dynamic>>> getAvailableUsersForCommunity(
      String userId, String communityId) async {
    final String availableUsersUrl =
        "$baseUrl/get_available_user_community.php?uid=$userId&community_id=$communityId";

    try {
      final response = await http.get(Uri.parse(availableUsersUrl));
      logger.i(
          "Respuesta completa del servidor (getAvailableUsersForCommunity): ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        logger.e(
            "Error de servidor en getAvailableUsersForCommunity: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      logger.e("Error al obtener usuarios disponibles: $e");
      return [];
    }
  }

  // Añadir miembros a la comunidad
  Future<bool> addCommunityMember(int communityId, String userId) async {
    final String addMemberUrl = "$baseUrl/add_community_member.php";

    try {
      final response = await http.post(
        Uri.parse(addMemberUrl),
        body: {
          'community_id': communityId.toString(),
          'user_id': userId,
        },
      );

      logger.i("Respuesta del servidor (addCommunityMember): ${response.body}");

      final responseData = json.decode(response.body);
      return responseData['status'] == 'success';
    } catch (e) {
      logger.e("Error al añadir miembro a la comunidad: $e");
      return false;
    }
  }

  // Obtener los miembros de la comunidad
  Future<List<Map<String, dynamic>>> getCommunityMembers(
      String communityId) async {
    try {
      // Construir la URI para la solicitud HTTP
      final response = await http.get(
        Uri.parse('$baseUrl/communitymembers.php?community_id=$communityId'),
      );

      // Imprimir la respuesta del servidor para depuración
      logger
          .i("Respuesta del servidor (getCommunityMembers): ${response.body}");

      // Verificar si la solicitud fue exitosa (código de respuesta 200)
      if (response.statusCode == 200) {
        // Decodificar la respuesta JSON
        List<dynamic> jsonResponse = json.decode(response.body);

        // Retornar la lista de mapas convertida desde la respuesta JSON
        return List<Map<String, dynamic>>.from(jsonResponse);
      } else {
        // Registrar un error si el código de respuesta no es 200
        logger.e("Error al cargar miembros: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      // Manejo de errores, como problemas de conexión
      logger.e("Error al obtener miembros de la comunidad: $e");
      return [];
    }
  }

  // Eliminar un miembro de la comunidad
  Future<bool> removeCommunityMember(String communityId, String userId) async {
    final String removeMemberUrl = "$baseUrl/remove_community_member.php";

    try {
      final response = await http.post(
        Uri.parse(removeMemberUrl),
        body: {
          'community_id': communityId,
          'user_id': userId,
        },
      );

      final responseData = json.decode(response.body);
      return responseData['status'] == 'success';
    } catch (e) {
      logger.e("Error al salir de la comunidad: $e");
      return false;
    }
  }
}
