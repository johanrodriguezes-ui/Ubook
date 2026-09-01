import 'package:flutter/material.dart';
import 'package:ubook/calendar.dart';
import 'package:ubook/services/postservice.dart';
import 'package:ubook/services/auth_service.dart';
import 'package:ubook/notification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Para borrar la caché

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> posts = [];
  final PostService _postService = PostService();
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  void _loadUserId() async {
    AuthService authService = AuthService();
    userId = await authService.getUserId();
    if (userId != null) {
      _loadPosts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo recuperar el ID de usuario.')),
      );
    }
  }

  void _loadPosts() async {
    try {
      List<Map<String, dynamic>> loadedPosts = await _postService.getPosts();
      setState(() {
        posts = loadedPosts;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar publicaciones: $e')),
      );
    }
  }

  void _addPost(String content) async {
    if (userId != null) {
      try {
        await _postService.addPost(int.parse(userId!), content);
        _loadPosts();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al añadir publicación: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: ID de usuario no disponible')),
      );
    }
  }

  void _showAddPostDialog() {
    String newPostContent = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Añadir Publicación'),
          content: TextField(
            onChanged: (value) {
              newPostContent = value;
            },
            decoration:
                const InputDecoration(hintText: "Escribe tu publicación"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newPostContent.isNotEmpty) {
                  _addPost(newPostContent);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Publicar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    AuthService authService = AuthService();
    await authService.logout(); // Lógica para cerrar sesión

    // Limpiar caché de SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Borra toda la caché almacenada

    // Navegar al login
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _toggleLike(int index) async {
    try {
      bool isLiked = posts[index]['liked'] ?? false;
      final response = await _postService.toggleLike(
          int.parse(posts[index]['post_id'].toString()), isLiked);
      setState(() {
        posts[index]['likes'] = response['likes'];
        posts[index]['liked'] = !isLiked;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar likes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(28, 0, 77, 64),
      appBar: AppBar(
        title: const Text('Ubook', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF004D40),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            color: Colors.white,
            onPressed: () {
              if (userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NotificationScreen(userId: int.parse(userId!)),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('No se pudo recuperar el ID de usuario')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.people),
            color: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/users');
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            onPressed: _logout, // Llamada al método de logout
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return Card(
            color: Color.fromARGB(255, 255, 255, 255),
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 0, 89, 79),
                        child: Icon(Icons.person,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          posts[index]['author'] ?? 'Autor desconocido',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ),
                      Text(
                        posts[index]['date'] ?? '',
                        style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0)),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    posts[index]['content'] ?? '',
                    style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          (posts[index]['liked'] ?? false)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: (posts[index]['liked'] ?? false)
                              ? Colors.red
                              : Color.fromARGB(255, 0, 89, 79),
                        ),
                        onPressed: () {
                          _toggleLike(index);
                        },
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${posts[index]['likes']} likes',
                        style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.share,
                            color: Color.fromARGB(255, 0, 89, 79)),
                        label: const Text(
                          'COMPARTIR',
                          style:
                              TextStyle(color: Color.fromARGB(255, 0, 89, 79)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostDialog,
        backgroundColor: Color.fromARGB(255, 0, 77, 64),
        child: const Icon(Icons.add),
      ),
    );
  }
}
