import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_4/models/note.dart';
import 'package:flutter_application_4/pages/update_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_4/services/auth_service_2.dart';

class NotePage extends StatelessWidget {
  const NotePage({
    super.key,
    required this.tovar,
    required this.onRemove,
  });

  final Tovar tovar;
  final VoidCallback onRemove;

  Future<void> _addToFavorites(BuildContext context) async {
    final authService = Provider.of<AuthService2>(context, listen: false);
    
    if (!authService.isLoggedIn) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Требуется авторизация'),
            content: const Text('Чтобы добавить товар в избранное, необходимо войти в аккаунт'),
            actions: <Widget>[
              TextButton(
                child: const Text('Отмена'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Войти'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/login_page_2');
                },
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('favorites')
          .doc(tovar.id.toString())
          .set(tovar.toJson(), SetOptions(merge: true));

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Товар добавлен в избранное')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка добавления в избранное: $e')),
      );
    }
  }

  Future<void> _addToCart(BuildContext context) async {
    final authService = Provider.of<AuthService2>(context, listen: false);
    
    if (!authService.isLoggedIn) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Требуется авторизация'),
            content: const Text('Чтобы добавить товар в корзину, необходимо войти в аккаунт'),
            actions: <Widget>[
              TextButton(
                child: const Text('Отмена'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Войти'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/login_page_2');
                },
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      final cartRef = FirebaseFirestore.instance.collection('cart');
      final docRef = cartRef.doc(tovar.id.toString());

      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final currentCount = docSnapshot.data()?['quantity'] ?? 0;
        await docRef.update({
          'quantity': currentCount + 1,
        });
      } else {
        await docRef.set({
          'id': tovar.id,
          'image_url': tovar.url.trim(),
          'price': tovar.price,
          'quantity': 1,
        });
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Товар добавлен в корзину')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка добавления в корзину: $e')),
      );
    }
  }

  Future<void> _updateTovar(BuildContext context, Tovar updatedTovar) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(updatedTovar.id.toString())
          .update(updatedTovar.toJson());

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Товар успешно обновлен')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при обновлении товара: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService2>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Изображение товара
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    tovar.url,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Название товара
                      Text(
                        tovar.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Описание
                      Text(
                        tovar.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Цена
                      Text(
                        '${tovar.price} ₽',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Кнопки админа
                      FutureBuilder<bool>(
                        future: authService.isAdmin(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data == true) {
                            return Row(
                              children: [
                                Expanded(
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: const BorderSide(color: Colors.black, width: 1),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                    ),
                                    onPressed: onRemove,
                                    child: const Text(
                                      'Удалить товар',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: const BorderSide(color: Colors.black, width: 1),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                    ),
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UpdatePage(
                                          onUpdate: (updatedTovar) => _updateTovar(context, updatedTovar),
                                          tovar: tovar,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Редактировать',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink(); // Скрываем кнопки для не-админов
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Кнопки избранное и корзина
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () => _addToFavorites(context),
                              icon: const Icon(
                                Icons.favorite,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () => _addToCart(context),
                              icon: const Icon(
                                Icons.shopping_cart,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}