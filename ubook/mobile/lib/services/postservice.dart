import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ubook/config/api_config.dart';

class PostService {
  // URLs separadas para cada operación
  final String getPostsUrl = "${ApiConfig.baseUrl}/post/get_post.php";
  final String addPostUrl = "${ApiConfig.baseUrl}/post/add_post.php";
  final String toggleLikeUrl = "${ApiConfig.baseUrl}/post/update_likes.php";

  // Obtener todas las publicaciones
  Future<List<Map<String, dynamic>>> getPosts() async {
    try {
      final response = await http.get(Uri.parse(getPostsUrl));
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Error al cargar publicaciones: ${response.body}');
      }
    } catch (e) {
      print("Error en getPosts: $e");
      rethrow;
    }
  }

  // Añadir una nueva publicación
  Future<void> addPost(int userId, String content) async {
    try {
      final response = await http.post(
        Uri.parse(addPostUrl),
        body: {
          'user_id': userId.toString(),
          'content': content,
        },
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception('Error al añadir publicación: ${response.body}');
      }
    } catch (e) {
      print("Error en addPost: $e");
      rethrow;
    }
  }

// Actualizar likes
  Future<Map<String, dynamic>> toggleLike(int postId, bool isLiked) async {
    try {
      final response = await http.put(
        Uri.parse(toggleLikeUrl),
        body: {
          'post_id': postId.toString(), // Convertir a String
          'action': isLiked ? 'unlike' : 'like',
        },
      );

      if (response.statusCode == 200) {
        // Decodificar el cuerpo de la respuesta como JSON
        final data = jsonDecode(response.body);
        return data; // Devolver los datos decodificados
      } else {
        throw Exception('Error al actualizar likes: ${response.body}');
      }
    } catch (e) {
      print("Error en toggleLike: $e");
      rethrow;
    }
  }
}
