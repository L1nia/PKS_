import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Управление пользователями',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Произошла ошибка'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(user['email'] ?? 'Нет email'),
                  subtitle: Text('Роль: ${user['role'] ?? 'user'}'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'admin',
                        child: Text('Сделать админом'),
                      ),
                      const PopupMenuItem(
                        value: 'user',
                        child: Text('Сделать пользователем'),
                      ),
                    ],
                    onSelected: (String value) {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(users[index].id)
                          .update({'role': value});
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 