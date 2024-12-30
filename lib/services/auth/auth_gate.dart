// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_4/pages/chats.dart';
// import 'package:flutter_application_4/services/auth/login_or_register.dart';

// class AuthGate2 extends StatelessWidget {
//   const AuthGate2({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           //user is logged in
//           if (snapshot.hasData) {
//             return const Chats();
//           }

//           //user is NOT logged in
//           else {
//             return const LoginOrRegister();
//           }
//         }
//       ),
//     );
//   }
// }