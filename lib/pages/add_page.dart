import 'package:flutter/material.dart';
import 'package:flutter_application_4/models/note.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_4/services/auth_service_2.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key, required this.onAdd});

  final Function(Tovar) onAdd;

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController urlController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    final authService = AuthService2();
    final isAdmin = await authService.isAdmin();
    
    if (!isAdmin && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Доступ запрещен. Только для администраторов.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Добавление товара',
            style: TextStyle(fontSize: 24, color: Color.fromARGB(255, 0, 0, 0)),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(fontSize: 24, color: Color.fromARGB(255, 0, 0, 0)),
              decoration: const InputDecoration(
                labelText: 'Введите Название',
              ),
              maxLines: 2,
            ),
            TextField(
              controller: urlController,
              style: const TextStyle(fontSize: 24, color: Color.fromARGB(255, 0, 0, 0)),
              decoration: const InputDecoration(
                labelText: 'Введите URL',
              ),
              maxLines: 2,
            ),
            TextField(
              controller: priceController,
              style: const TextStyle(fontSize: 24, color: Color.fromARGB(255, 0, 0, 0)),
              decoration: const InputDecoration(
                labelText: 'Введите цену',
              ),
              maxLines: 1,
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: descriptionController,
              style: const TextStyle(fontSize: 24, color: Color.fromARGB(255, 0, 0, 0)),
              decoration: const InputDecoration(
                labelText: 'Введите описание',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: isLoading ? null : () async {
                setState(() {
                  isLoading = true;
                });

                final url = urlController.text;
                final name = nameController.text;
                final price = priceController.text;
                final description = descriptionController.text;

                if (url.isNotEmpty && price.isNotEmpty && description.isNotEmpty && name.isNotEmpty) {
                  Tovar newTovar = Tovar(
                    id: DateTime.now().millisecondsSinceEpoch, // Генерируем уникальный id как int
                    name: name,
                    url: url,
                    price: int.parse(price),
                    description: description,
                  );

                  try {
                    // Добавляем товар в Firestore, используя id как int
                    await FirebaseFirestore.instance.collection('products').doc(newTovar.id.toString()).set(newTovar.toJson());
                    
                    widget.onAdd(newTovar);
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка добавления товара')));
                  }
                }

                setState(() {
                  isLoading = false;
                });
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.black),
              child: isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Добавить товар'),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    );
  }
}