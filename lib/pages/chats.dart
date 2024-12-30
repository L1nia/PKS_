import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/pages/chat_page.dart';
import 'package:flutter_application_4/services/chat/chat_service.dart';

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> with SingleTickerProviderStateMixin {
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TabController? _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) return const CircularProgressIndicator();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Чаты', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController!,
          tabs: const [
            Tab(text: 'Админы'),
            Tab(text: 'Пользователи'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Поиск пользователей...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Вкладка админов
                _buildUserList(_chatService.getAdmins()),
                // Вкладка пользователей
                _buildUserList(_chatService.getUsers()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(Stream<QuerySnapshot> usersStream) {
    return StreamBuilder<QuerySnapshot>(
      stream: usersStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Произошла ошибка'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Фильтрация пользователей по поисковому запросу
        final users = snapshot.data!.docs.where((doc) {
          final userData = doc.data() as Map<String, dynamic>;
          final email = userData['email'].toString().toLowerCase();
          return email.contains(_searchQuery);
        }).toList();

        if (users.isEmpty) {
          return const Center(child: Text('Пользователи не найдены'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userData = users[index].data() as Map<String, dynamic>;
            final userEmail = userData['email'] ?? 'Нет email';
            final userId = users[index].id;

            // Не показываем текущего пользователя в списке
            if (userId != _auth.currentUser?.uid) {
              return ListTile(
                title: Text(userEmail),
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        receiverUserEmail: userEmail,
                        receiverUserId: userId,
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}