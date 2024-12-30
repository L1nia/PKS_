import 'package:flutter/material.dart';
import 'package:flutter_application_4/models/order.dart' as models;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_4/pages/login_page_2.dart';
import 'package:flutter_application_4/services/auth_service_2.dart';
import 'package:flutter_application_4/pages/user_info_page.dart';
import 'package:flutter_application_4/pages/order_details_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService2 _authService = AuthService2();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    if (_auth.currentUser != null) {
      _isAdmin = await _authService.isAdmin();
      setState(() {});
    }
  }

  Future<List<models.Order>> _fetchOrders() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('orders')
          .where('user_id', isEqualTo: user.uid) // Используем uid пользователя
         // .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) => models.Order.fromJson(doc.data())).toList();
    }
  return [];
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage2(),
      ),
    );
  }

  Widget _buildAuthenticatedContent() {
    return Column(
      children: [
        if (_isAdmin) 
          _buildAdminPanel()
        else 
          _buildUserContent(),
      ],
    );
  }

  Widget _buildAdminPanel() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Панель администратора',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 200,
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/admin/orders');
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.black),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Управление заказами',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Container(
            width: 200,
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/admin/users');
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Colors.black),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Управление\nпользователями',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Центрированная кнопка профиля
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserInfoPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Мой профиль',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            const Text(
              'Мои заказы',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Список заказов
            FutureBuilder<List<models.Order>>(
              future: _fetchOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'У вас пока нет заказов',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return Column(
                  children: snapshot.data!.map((order) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsPage(order: order),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Заказ #${order.id}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  order.status,
                                  style: TextStyle(
                                    color: _getStatusColor(order.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Сумма: ${order.total} ₽'),
                            if (order.items != null && order.items!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              const Text(
                                'Товары:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              ...order.items!.map((item) => Text(
                                '• ${item.name} - ${item.quantity} шт.',
                                style: const TextStyle(fontSize: 14),
                              )),
                            ],
                          ],
                        ),
                      ),
                    ),
                  )).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'в обработке':
        return Colors.orange;
      case 'отправлен':
        return Colors.blue;
      case 'доставлен':
        return Colors.green;
      case 'отменен':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildUnauthenticatedContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Для просмотра профиля необходимо войти',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/login_page_2');
            },
            child: const Text(
              'Войти',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'ПРОФИЛЬ',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: _auth.currentUser != null
            ? [
                IconButton(
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  onPressed: _navigateToLogin,
                )
              ]
            : null,
      ),
      body: _auth.currentUser != null
          ? _buildAuthenticatedContent()
          : _buildUnauthenticatedContent(),
    );
  }
}