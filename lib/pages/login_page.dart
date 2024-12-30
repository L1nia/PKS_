// import 'package:flutter/material.dart';
// import 'package:flutter_application_4/authorization/auth_service.dart';
// import 'package:flutter_application_4/pages/register_page.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _MyWidgetState();
// }

// class _MyWidgetState extends State<LoginPage> {

//   final authService = AuthService();

//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   void login() async {
//     final email = _emailController.text;
//     final password = _passwordController.text;

//     try {
//       await authService.signInWithEmailPassword(email, password);
//     }
    
//     catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login'),),
//       body: ListView(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 50),
//         children: [
//           TextField(
//             controller: _emailController,
//             decoration: const InputDecoration(labelText: 'Email'),
//           ),
//           TextField(
//             controller: _passwordController,
//             decoration: const InputDecoration(labelText: 'Password'),
//           ),

//           const SizedBox(height: 12,),

//           ElevatedButton(
//             onPressed: login,
//             child: const Text('Login'),
//           ),

//           const SizedBox(height: 12,),

//           GestureDetector(
//             onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
//             child: const Center(child: Text('Don`t have an account? Sign Up'),),
//           ),

//         ],
//       ),
//     );
//   }
// }