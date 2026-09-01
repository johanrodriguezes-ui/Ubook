import 'package:flutter/material.dart';
import 'package:ubook/modelUser.dart';

class UserAdapter extends StatelessWidget {
  final List<User> users;
  final Function(User) onUserSelected;

  const UserAdapter(BuildContext context,
      {super.key, required this.users, required this.onUserSelected});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.profileUrl),
            radius: 25,
          ),
          title: Text(user.name),
          subtitle: Text(user.status),
          onTap: () => onUserSelected(user),
        );
      },
    );
  }
}
