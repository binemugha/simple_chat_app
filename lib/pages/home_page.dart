import 'package:flutter/material.dart';
import 'package:simple_chat_app/components/user_tile.dart';
import 'package:simple_chat_app/pages/chat_page.dart';
import 'package:simple_chat_app/services/auth/auth_service.dart';
import 'package:simple_chat_app/components/my_drawer.dart';
import 'package:simple_chat_app/services/chat/chat_services.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      drawer: MyDrawer(),
      body: _buildUserList(),
    );
  }

  // build a list of users except for the current logged
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUserStreamExcludingBlocked(),
      builder: (context, snapshot) {
        // error
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // loading...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        // return list view
        return ListView(
          children:
              snapshot.data!
                  .map<Widget>(
                    (userData) => _buildUserListItem(userData, context),
                  )
                  .toList(),
        );
      },
    );
  }

  // build individual list tile for user
  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    // display all users except current user
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      return UserTile(
        text: userData["email"],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChatPage(
                    receiverEmail: userData["email"],
                    receiverID: userData["uid"],
                  ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
