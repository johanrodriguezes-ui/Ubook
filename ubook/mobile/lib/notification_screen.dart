import 'package:flutter/material.dart';
import 'package:ubook/services/notificationservice.dart';
import 'package:ubook/notificationModel.dart';

class NotificationScreen extends StatefulWidget {
  final int userId; // Recibe el userId como parámetro

  const NotificationScreen({super.key, required this.userId});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<NotificationModel>> _notificationsFuture;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadNotifications(); // Cargar las notificaciones al iniciar la pantalla
  }

  // Método para cargar las notificaciones usando el servicio
  void _loadNotifications() {
    print('Cargando notificaciones para el usuario: ${widget.userId}');
    _notificationsFuture =
        _notificationService.fetchNotifications(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(28, 0, 77, 64),
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF004D40),
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child:
                  Text('Error al cargar las notificaciones: ${snapshot.error}'),
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No tienes notificaciones nuevas.'));
          } else if (snapshot.hasData) {
            // Mostrar la lista de notificaciones
            List<NotificationModel> notifications = snapshot.data!;

            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                NotificationModel notification = notifications[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    title: Text(
                      notification.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(notification.message),
                    leading: Icon(
                      Icons.notifications,
                      color: notification.isRead ? Colors.grey : Colors.green,
                    ),
                    trailing: Text(
                      notification.createdAt,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () {
                      // Lógica para manejar lo que ocurre al tocar una notificación
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(
                child: Text('No se pudieron cargar las notificaciones.'));
          }
        },
      ),
    );
  }
}
