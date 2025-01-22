import 'dart:convert';

import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/screens/chat_screen.dart';
import 'package:chatapp/screens/login_screen.dart';
import 'package:chatapp/services/auth_service.dart';
import 'package:chatapp/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatelessWidget {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  void _showUserProfile(UserModel user, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: user.profileImage != null
                    ? NetworkImage(user.profileImage!)
                    : null,
                child: user.profileImage == null
                    ? Text(user.username[0].toUpperCase())
                    : null,
              ),
              SizedBox(height: 16),
              Text(
                user.username,
              ),
              Text(user.email),
              if (user.about != null) ...[
                SizedBox(height: 8),
                Text(user.about!),
              ],
              if (user.phoneNumber != null) ...[
                SizedBox(height: 8),
                Text(user.phoneNumber!),
              ],
              Text(
                user.isOnline
                    ? 'Online'
                    : 'Last seen: ${timeago.format(user.lastSeen)}',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chats'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await _authService.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
            ),
          ],
        ),
        body: StreamBuilder<List<UserModel>>(
          stream: _userService.getAllUsers(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                if (user.uid == _authService.currentUser?.uid)
                  return SizedBox();

                return ListTile(
                  leading: GestureDetector(
                    onTap: () => _showUserProfile(user, context),
                    child: CircleAvatar(
                      backgroundImage: user.profileImage != null
                          ? MemoryImage(base64Decode(user.profileImage!))
                          : null,
                      child: user.profileImage == null
                          ? Text(user.username[0].toUpperCase())
                          : null,
                    ),
                  ),
                  title: Text(user.username),
                  subtitle: Text(
                    user.isOnline
                        ? 'Online'
                        : 'Last seen: ${timeago.format(user.lastSeen)}',
                  ),
                  trailing: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: user.isOnline ? Colors.green : Colors.grey,
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(receiverUser: user),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
