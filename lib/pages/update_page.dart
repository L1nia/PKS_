import 'package:flutter/material.dart';
import 'package:flutter_application_4/models/note.dart';

class UpdatePage extends StatefulWidget {
  final Function(Tovar) onUpdate;
  final Tovar tovar;

  const UpdatePage({
    super.key,
    required this.onUpdate,
    required this.tovar,
  });

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tovar.name);
    _urlController = TextEditingController(text: widget.tovar.url);
    _priceController = TextEditingController(text: widget.tovar.price.toString());
    _descriptionController = TextEditingController(text: widget.tovar.description);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать товар'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Название товара'),
            ),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'URL изображения'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Цена'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Описание'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final updatedTovar = Tovar(
                  id: widget.tovar.id,
                  name: _nameController.text,
                  url: _urlController.text,
                  price: int.parse(_priceController.text),
                  description: _descriptionController.text,
                );
                widget.onUpdate(updatedTovar);
                Navigator.pop(context);
              },
              child: const Text('Сохранить изменения'),
            ),
          ],
        ),
      ),
    );
  }
}