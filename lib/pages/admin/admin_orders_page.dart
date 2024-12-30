import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: unused_import
import 'package:flutter_application_4/models/order.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Управление заказами',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Произошла ошибка'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Заказ #${orders[index].id}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Статус: ${order['status']}'),
                      Text('Сумма: ${order['total']} ₽'),
                      Text('Email: ${order['userEmail']}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'processing',
                        child: Text('В обработке'),
                      ),
                      const PopupMenuItem(
                        value: 'completed',
                        child: Text('Завершен'),
                      ),
                      const PopupMenuItem(
                        value: 'cancelled',
                        child: Text('Отменен'),
                      ),
                    ],
                    onSelected: (String value) {
                      FirebaseFirestore.instance
                          .collection('orders')
                          .doc(orders[index].id)
                          .update({'status': value});
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