import 'package:flutter/material.dart';
import 'package:flutter_application_4/components/cart_item.dart';
import 'package:flutter_application_4/models/cart_model.dart';
import 'package:flutter_application_4/models/order.dart' as models;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Метод для преобразования данных из Firestore в CartModel
  List<CartModel> _cartFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      try {
        return CartModel.fromJson({
          ...data,
          'id': int.parse(doc.id), // Преобразуем id документа в int
        });
      } catch (e) {
        print('Ошибка при преобразовании данных: $e');
        return CartModel(
          id: 0,
          url: '',
          price: 0,
          count: 0,
        );
      }
    }).toList();
  }

  // Метод для увеличения количества товара
  void _add(CartModel cartItem) {
    _firestore.collection('cart').doc(cartItem.id.toString()).update({
      'quantity': cartItem.count + 1,
    });
  }

  // Метод для уменьшения количества товара
  void _delete(CartModel cartItem) {
    if (cartItem.count > 1) {
      _firestore.collection('cart').doc(cartItem.id.toString()).update({
        'quantity': cartItem.count - 1,
      });
    } else {
      _firestore.collection('cart').doc(cartItem.id.toString()).delete();
    }
  }

  // Метод для удаления товара из корзины
  void _removeAll(int id) {
    _firestore.collection('cart').doc(id.toString()).delete();
  }

  // Метод для подсчёта общей суммы
  int _calculateTotal(List<CartModel> cart) {
    return cart.fold(0, (total, item) => total + item.price * item.count);
  }

  // Метод для создания заказа
  Future<void> _createOrder(models.Order order) async {
    final user = _auth.currentUser;
    if (user != null) {
      // Добавляем заказ в коллекцию orders
      final docRef = await _firestore.collection('orders').add(order.toJson());

      // Очищаем корзину
      final cartSnapshot = await _firestore.collection('cart').get();
      for (final doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }

      // Показываем уведомление об успешном оформлении заказа
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Заказ успешно оформлен! ID: ${docRef.id}'),
        ),
      );

      // Возвращаемся на главный экран с профилем
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home', 
        (route) => false,
        arguments: 3, // Индекс для профиля в BottomNavigationBar
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'КОРЗИНА',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('cart').snapshots(), // Слушаем изменения в Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          final cart = _cartFromSnapshot(snapshot.data!);
          final total = _calculateTotal(cart); // Вычисляем общую сумму

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: cart.length,
                    itemBuilder: (BuildContext context, int index) {
                      final cartItem = cart[index];
                      return Dismissible(
                        key: Key(cartItem.url),
                        background: Container(color: Colors.red),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (DismissDirection direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Подтверждение"),
                                content: const Text("Хотите удалить товар из корзины?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text("УДАЛИТЬ"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text("ОТМЕНИТЬ"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          _removeAll(cartItem.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${cartItem.url} удален из корзины')),
                          );
                        },
                        child: CartItem(
                          cart: cartItem,
                          onAdd: () => _add(cartItem),
                          onDeleate: () => _delete(cartItem),
                          onRemove: () => _removeAll(cartItem.id),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Итого:',
                          style: TextStyle(fontSize: 24, color: Colors.black),
                        ),
                        Text(
                          '$total ₽', // Отображаем общую сумму
                          style: const TextStyle(fontSize: 24, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        final user = _auth.currentUser;
                        if (user != null) {
                          final order = models.Order(
                            id: DateTime.now().millisecondsSinceEpoch,
                            user: user.uid,
                            total: total,
                            status: "В обработке",
                            timestamp: Timestamp.now(),
                            userId: user.uid,
                          );
                          await _createOrder(order);
                        }
                      },
                      child: const Text(
                        'Оформить заказ',
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}