import 'package:flutter/material.dart';
import 'package:flutter_application_4/components/favourite_item_note.dart';
import 'package:flutter_application_4/models/note.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_4/pages/note_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late Future<List<Tovar>> _favorites;

  @override
  void initState() {
    super.initState();
    _favorites = _fetchFavorites();
  }

  Future<List<Tovar>> _fetchFavorites() async {
    final snapshot = await FirebaseFirestore.instance.collection('favorites').get();
    return snapshot.docs.map((doc) => Tovar.fromJson(doc.data())).toList();
  }

  Future<void> _removeTovarFromFavorite(int id) async { // Изменяем тип id на int
    try {
      await FirebaseFirestore.instance.collection('favorites').doc(id.toString()).delete();
      setState(() {
        _favorites = _fetchFavorites();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка удаления товара')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'ИЗБРАННОЕ',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Tovar>>(
        future: _favorites,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет избранных товаров'));
          }

          final favorites = snapshot.data!;
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotePage(
                        tovar: favorite,
                        onRemove: () => _removeTovarFromFavorite(favorite.id),
                      ),
                    ),
                  );
                },
                child: FavItemNote(
                  tovar: favorite,
                  onRemove: () => _removeTovarFromFavorite(favorite.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}