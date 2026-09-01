import 'package:flutter/material.dart';
import 'package:ubook/chat.dart';
import 'package:ubook/comunity.dart';
import 'package:ubook/group.dart';
import 'package:ubook/settings.dart';
import 'package:ubook/home.dart'; // Asegúrate de importar tu archivo home.dart

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  Future<bool> _onWillPop(BuildContext context) async {
    // Navegar hacia HomeScreen al presionar el botón de retroceso
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
    return false; // Retorna false para que no haga el comportamiento por defecto
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Mensajería',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF004D40),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                color: Colors.white,
                onPressed: () {
                  print('Buscar icono presionado');
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: Container(
                color: Colors.teal,
                child: const TabBar(
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black54,
                  tabs: [
                    Tab(text: 'Chats'),
                    Tab(text: 'Grupos'),
                    Tab(text: 'Comunidad'),
                    Tab(text: 'Ajustes'),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              ChatScreen(),
              GroupScreen(),
              CommunityScreen(),
              SettingsScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
