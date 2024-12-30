import 'package:flutter/material.dart';
import 'package:flutter_application_4/pages/login_page_2.dart';
import 'package:flutter_application_4/pages/register_page_2.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  //initialy show login
  bool showLoginPage = true;

  //toggle
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage2(onTap: togglePages,);
    }
    else {
      return RegisterPage2(onTap: togglePages,);
    }
  }
}