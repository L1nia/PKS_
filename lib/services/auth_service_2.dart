import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_4/models/profile_model.dart';
import 'package:flutter/foundation.dart';

class AuthService2 extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Добавляем метод для создания пользователя
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Создаем профиль пользователя
      await ProfileModel.createProfile(
        userCredential.user!.uid,
        email,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Произошла ошибка при регистрации';
    }
  }

  // Метод для входа
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Произошла ошибка при входе';
    }
  }

  // Метод для получения роли пользователя
  Future<String> getUserRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      
      return userData.get('role') ?? 'user';
    }
    return 'user';
  }

  // Проверка является ли пользователь админом
  Future<bool> isAdmin() async {
    return await getUserRole() == 'admin';
  }

  // Метод для выхода
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Получение текущего пользователя
  User? get currentUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;
} 