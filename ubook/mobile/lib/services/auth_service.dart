import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ubook/config/api_config.dart';

class AuthService {
  // Inicializar el logger
  final logger = Logger();

  // URL base de la API
  final String baseUrl = ApiConfig.baseUrl;

  // Método para registrar un usuario
  Future<void> registerUser(String identy, String name, String email,
      String password, String birthDate, String program) async {
    final String registerUrl =
        "$baseUrl/register.php"; // Ruta completa para el registro

    try {
      final response = await http.post(
        Uri.parse(registerUrl),
        body: {
          'identy': identy,
          'name': name,
          'email': email,
          'password': password,
          'birthdate': birthDate,
          'program': program,
        },
      );
      // Imprimir la respuesta completa del servidor
      logger.i("Respuesta del servidor: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['success']) {
            logger.i("Usuario registrado con éxito: ${data['message']}");
          } else {
            logger.w("Error al registrar usuario: ${data['message']}");
          }
        } catch (e) {
          logger.e("La respuesta no es un JSON válido: ${response.body}");
        }
      } else {
        logger
            .e("Error de servidor: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      logger.e("Error al registrar usuario", e);
    }
  }

  Future<String> loginUser(String email, String password) async {
    final String loginUrl =
        "$baseUrl/login.php"; // Ruta completa para el inicio de sesión

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        body: {
          'email': email,
          'password': password,
        },
      );

      logger.i(
          "Respuesta del servidor: ${response.body}"); // Verifica la respuesta

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['success']) {
            // No imprimir el uid, solo guardarlo
            String uid = data['uid']
                .toString(); // Asegúrate de convertir a String si es necesario

            // Guardar el uid
            await saveUserId(uid);

            return 'success'; // Retorna un string que indica éxito
          } else {
            logger.w("Error de inicio de sesión: ${data['message']}");
            return data['message']; // Mensaje de error
          }
        } catch (e) {
          logger.e("Error al decodificar JSON: $e");
          return 'Error procesando la respuesta del servidor';
        }
      } else {
        logger
            .e("Error de servidor: ${response.statusCode} - ${response.body}");
        return 'Error de servidor: ${response.statusCode}';
      }
    } catch (e) {
      logger.e("Error al iniciar sesión: $e");
      return 'Error de conexión al servidor';
    }
  }
  // Método para cerrar sesión (logout)
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Borra todos los datos guardados
  }
  Future<void> saveUserId(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid); // Guardar usando 'uid'
  }

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid'); // Recuperar usando 'uid'
  }

  // Método para verificar si el correo ya está registrado
  Future<bool> checkEmailExists(String email) async {
    final String checkEmailUrl =
        "$baseUrl/check_email.php"; // URL del script que verifica el correo

    try {
      final response = await http.post(
        Uri.parse(checkEmailUrl),
        body: {
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['exists'] ?? false;
      } else {
        logger
            .e("Error de servidor: ${response.statusCode} - ${response.body}");
        return false; // En caso de error de servidor, retorna false
      }
    } catch (e) {
      logger.e("Error al verificar el correo: $e");
      return false; // En caso de error de red, retornar false
    }
  }

  Future<void> submitData({
    required File? profileImage,
    required File? coverImage,
    required String facebook,
    required String instagram,
  }) async {
    final uri = Uri.parse("$baseUrl/settings.php");
    var request = http.MultipartRequest('POST', uri);

    // Adjuntar la imagen de perfil si está disponible
    if (profileImage != null) {
      request.files.add(
          await http.MultipartFile.fromPath('profileImage', profileImage.path));
    }

    // Adjuntar la imagen de portada si está disponible
    if (coverImage != null) {
      request.files.add(
          await http.MultipartFile.fromPath('coverImage', coverImage.path));
    }

    // Añadir los campos de texto (Facebook e Instagram)
    request.fields['facebook'] = facebook;
    request.fields['instagram'] = instagram;

    // Enviar la solicitud
    var response = await request.send();

    // Verificar el estado de la respuesta
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);
      // Manejar la respuesta del servidor
      print(jsonResponse);
    } else {
      print('Error al enviar los datos: ${response.statusCode}');
    }
  }
}

