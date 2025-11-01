import 'package:flutter/material.dart';
import 'package:simple_chat_app/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    final user = _authService.getCurrentUser();

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Profile')),
        body: Center(child: Text('Not logged in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('Users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User data not found.'));
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Icon(
                    Icons.account_circle,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Username:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(data['username'] ?? 'N/A', style: TextStyle(fontSize: 18)),
                SizedBox(height: 16),
                Text('Email:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(data['email'] ?? 'N/A', style: TextStyle(fontSize: 18)),
                SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
