import 'package:flutter/material.dart';
import 'package:flutter_application_4/components/my_button.dart';
import 'package:flutter_application_4/components/my_text_field.dart';
import 'package:flutter_application_4/services/auth_service_2.dart';
import 'package:provider/provider.dart';

class LoginPage2 extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage2({super.key, this.onTap});

  @override
  State<LoginPage2> createState() => _LoginPage2State();
}

class _LoginPage2State extends State<LoginPage2> {

  //controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  //sign in
  void signIn() async{
    final authService = Provider.of<AuthService2>(context, listen:false);
    try {
      await authService.signInWithEmailAndPassword(emailController.text.trim(), passwordController.text.trim());
      Navigator.pushReplacementNamed(context, '/home'); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
        Text(e.toString()),
      ));
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50,),
              // logo
              Image.network('https://img.icons8.com/?size=100&id=x6i6xezEsG_E&format=png&color=000000', width: 150, height: 150,),

              const SizedBox(height: 50,),

              // welcome back
              const Text(
                'Войти',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25,),

              //email
              MyTextField(controller: emailController, hintText: 'Email', obscureText: false),

              const SizedBox(height: 10,),

              //password
              MyTextField(controller: passwordController, hintText: 'Пароль', obscureText: true),

              const SizedBox(height: 25,),

              //button
              MyButton(onTap: signIn, text: 'Войти'),

              const SizedBox(height: 50,),
          
              //register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Нет аккаунта?'),
                  const SizedBox(width: 4,),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/register_page_2');
                    },
                    child: const Text('Зарегистрироваться', style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}