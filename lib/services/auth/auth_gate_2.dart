import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_application_4/pages/chats.dart';
import 'package:flutter_application_4/services/auth/login_or_register.dart';
//import 'package:provider/provider.dart';
//import 'auth_service_2.dart'; 
import 'package:flutter_application_4/main.dart';


class AuthGate2 extends StatelessWidget {
  const AuthGate2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Если пользователь авторизован
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return const MyHomePage(); // Показываем основной интерфейс
            } else {
              return const LoginOrRegister(); // Показываем экран входа/регистрации
            }
          }
          // Пока происходит загрузка состояния аутентификации
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
