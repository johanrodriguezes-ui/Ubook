import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ubook/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File? _profileImage;
  File? _coverImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();

  final AuthService _authService = AuthService();

  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickCoverImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickProfileImage,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : const AssetImage('assets/person_icon.png') as ImageProvider,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Usuario',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text('Programa: Derecho'),
          const Text('Fecha de nacimiento: 31/12/2000'),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickCoverImage,
            child: Container(
              width: double.infinity,
              height: 150,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                image: _coverImage != null
                    ? DecorationImage(
                        image: FileImage(_coverImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _coverImage == null
                  ? const Center(child: Text("Cambiar foto de portada"))
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          const Card(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.lock),
                    title: Text('Privacidad'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                  ListTile(
                    leading: Icon(Icons.help),
                    title: Text('Ayuda'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                TextField(
                  controller: _facebookController,
                  decoration: const InputDecoration(
                    labelText: 'Link de Facebook',
                    prefixIcon: FaIcon(FontAwesomeIcons.facebook),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _instagramController,
                  decoration: const InputDecoration(
                    labelText: 'Link de Instagram',
                    prefixIcon: FaIcon(FontAwesomeIcons.instagram),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await _authService.submitData(
                profileImage: _profileImage,
                coverImage: _coverImage,
                facebook: _facebookController.text,
                instagram: _instagramController.text,
              );
            },
            child: const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }
}
