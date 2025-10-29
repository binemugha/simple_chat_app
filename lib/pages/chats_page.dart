import 'package:flutter/material.dart';
import 'package:simple_chat_app/services/chat/chat_services.dart';
import 'package:simple_chat_app/services/auth/auth_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_chat_app/pages/chat_page.dart';

class ChatsPage extends StatelessWidget {
  ChatsPage({super.key});

  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.getCurrentUser();
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Chats')),
        body: Center(child: Text('Not logged in.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Chats')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.getUserChats(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading chats'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final chats = snapshot.data ?? [];
          if (chats.isEmpty) {
            return Center(child: Text('No chats yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 16),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherUserId = chat['otherUserId'] ?? '';
              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('Users')
                        .doc(otherUserId)
                        .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(title: Text('Loading...'));
                  }
                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return ListTile(title: Text('Unknown user'));
                  }
                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final otherUserEmail = userData['email'] ?? 'Unknown';
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.person, color: Colors.black),
                      title: Text(
                        otherUserEmail,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ChatPage(
                                  receiverEmail: otherUserEmail,
                                  receiverID: otherUserId,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
