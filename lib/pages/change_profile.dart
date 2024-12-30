import 'package:flutter/material.dart';
import 'package:flutter_application_4/models/profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangeProfile extends StatelessWidget {
  const ChangeProfile({super.key, required this.profile, required this.onChange});

  final ProfileModel profile;
  final Function(ProfileModel) onChange;

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController(text: profile.email);

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Редактирование профиля',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              style: const TextStyle(fontSize: 24, color: Color.fromARGB(255, 0, 0, 0)),
              decoration: const InputDecoration(labelText: 'Введите новую почту'),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                final email = emailController.text;

                if (email.isNotEmpty) {
                  // Обновляем профиль в Firestore
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                      'email': email, // Обновляем только почту
                    });
                    // Обновляем профиль в приложении
                    onChange(ProfileModel(email: email, uid: profile.uid));

                    // Закрываем страницу редактирования профиля 
                    Navigator.pop(context);
                  }
                }
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.black),
              child: const Text('Сохранить изменения'),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    );
  }
}