import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ubook/config/api_config.dart';

class CalendarService {
  static const String baseUrl = "${ApiConfig.baseUrl}/calendar";

  // Add a reminder
  static Future<bool> addReminder(
      int userId, String reminderMessage, String reminderDate) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addreminder.php'),
        body: {
          'user_id': userId.toString(),
          'reminder_message': reminderMessage,
          'reminder_date': reminderDate,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'success';
      } else {
        print('Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error en addReminder: $e');
      return false;
    }
  }

  // Load reminders
  static Future<List<dynamic>> loadReminders(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/loadreminder.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data is List ? data : [];
      } else {
        print('Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error en loadReminders: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getRemindersByDay(
      int userId, String reminderDate) async {
    final response = await http.post(
      Uri.parse('$baseUrl/loadreminderforday.php'),
      body: {'user_id': userId.toString(), 'reminder_date': reminderDate},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar los recordatorios del día.');
    }
  }

  // Edit reminder
  static Future<bool> editReminder(
      int reminderId, String reminderMessage, String reminderDate) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/editreminder.php'),
        body: {
          'reminder_id': reminderId.toString(),
          'reminder_message': reminderMessage,
          'reminder_date': reminderDate,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'success';
      } else {
        print('Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error en editReminder: $e');
      return false;
    }
  }

  // Delete reminder
  static Future<bool> deleteReminder(int reminderId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/deletereminder.php'),
        body: {
          'reminder_id': reminderId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'success';
      } else {
        print('Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error en deleteReminder: $e');
      return false;
    }
  }
}
