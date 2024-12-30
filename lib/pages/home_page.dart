import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_4/components/item_note.dart';
import 'package:flutter_application_4/pages/add_page.dart';
import 'package:flutter_application_4/models/note.dart';
import 'package:flutter_application_4/pages/note_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  bool _isAscendingPrice = true;
  bool _isAscendingName = true;

  // Метод для добавления товара
  void _addTovar(Tovar tovar) {
    _firestore.collection('products').doc(tovar.id.toString()).set(tovar.toJson());
  }

  // Метод для удаления товара
  void _removeTovar(int id) async {
    try {
      await _firestore.collection('products').doc(id.toString()).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка удаления товара')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('ТОВАРЫ', style: TextStyle(fontSize: 24, color: Colors.white))),
        backgroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Поиск по названию',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: PopupMenuButton(
                      icon: const Icon(Icons.filter_list),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: ListTile(
                            leading: Icon(_isAscendingPrice ? Icons.arrow_upward : Icons.arrow_downward),
                            title: Text(_isAscendingPrice ? 'Сортировать по цене ↑' : 'Сортировать по цене ↓'),
                            onTap: () {
                              setState(() {
                                _isAscendingPrice = !_isAscendingPrice;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        PopupMenuItem(
                          child: ListTile(
                            leading: Icon(_isAscendingName ? Icons.sort_by_alpha : Icons.sort_by_alpha_rounded),
                            title: Text(_isAscendingName ? 'Сортировать A-Z' : 'Сортировать Z-A'),
                            onTap: () {
                              setState(() {
                                _isAscendingName = !_isAscendingName;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Ошибка: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Нет доступных продуктов'));
            }

            // Преобразуем документы в список товаров
            List<Tovar> products = [];
            for (var doc in snapshot.data!.docs) {
              try {
                final tovar = Tovar.fromJson(doc.data() as Map<String, dynamic>);
                products.add(tovar);
              } catch (e) {
                print('Ошибка при преобразовании данных: $e');
              }
            }

            // Фильтрация по поисковому запросу
            if (_searchQuery.isNotEmpty) {
              products = products.where((product) => product.name.toLowerCase().contains(_searchQuery)).toList();
            }

            // Сортировка
            if (_isAscendingPrice) {
              products.sort((a, b) => a.price.compareTo(b.price));
            } else {
              products.sort((a, b) => b.price.compareTo(a.price));
            }

            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotePage(
                          tovar: product,
                          onRemove: () => _removeTovar(product.id),
                        ),
                      ),
                    );
                  },
                  child: ItemNote(
                    tovar: product,
                    onRemove: () => _removeTovar(product.id),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddPage(onAdd: _addTovar)));
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}