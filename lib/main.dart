import 'package:flutter/material.dart';
import 'package:flutter_application_4/pages/cart_page.dart';
import 'package:flutter_application_4/pages/home_page.dart';
import 'package:flutter_application_4/pages/favorite_page.dart';
import 'package:flutter_application_4/pages/login_page_2.dart';
import 'package:flutter_application_4/pages/profile.dart';
import 'package:flutter_application_4/pages/chats.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_4/pages/register_page_2.dart';
import 'package:flutter_application_4/services/auth_service_2.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_4/pages/admin/admin_orders_page.dart';
import 'package:flutter_application_4/pages/admin/admin_users_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyBT6vQ0LNjzF7uq6DIERStZewITDg4qe3Y',
          appId: '611626702788',
          messagingSenderId: '611626702788',
          projectId: 'l1nia-16f8c'));

  runApp(ChangeNotifierProvider(
    create: (_) => AuthService2(),
    child: const MyApp(),
  ));
}

class AdminRouteGuard extends StatelessWidget {
  final Widget child;
  final AuthService2 authService;

  const AdminRouteGuard({
    required this.child,
    required this.authService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: authService.isAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.data == true) {
          return child;
        }

        return const Scaffold(
          body: Center(
            child: Text('Доступ запрещен. Только для администраторов.'),
          ),
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ЮMarket',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
      routes: {
        '/login_page_2': (context) => const LoginPage2(),
        '/register_page_2': (context) => const RegisterPage2(),
        '/home': (context) => const MyHomePage(),
        '/admin/orders': (context) => AdminRouteGuard(
          authService: AuthService2(),
          child: const AdminOrdersPage(),
        ),
        '/admin/users': (context) => AdminRouteGuard(
          authService: AuthService2(),
          child: const AdminUsersPage(),
        ),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    FavoritePage(),
    ProfilePage(),
    CartPage(),
    Chats(),
  ];

  void _onItemTapped(int index) {
    final authService = Provider.of<AuthService2>(context, listen: false);
    
    // Проверяем, авторизован ли пользователь для доступа к определенным страницам
    if (!authService.isLoggedIn && (index == 1 || index == 3 || index == 4)) {
      // Показываем диалоговое окно с предложением войти
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Требуется авторизация'),
            content: const Text('Для доступа к этому разделу необходимо войти в аккаунт'),
            actions: <Widget>[
              TextButton(
                child: const Text('Отмена'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Войти'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/login_page_2');
                },
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService2>(context);
    
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.white,
            ),
            label: 'Главная',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite,
              color: authService.isLoggedIn ? Colors.white : Colors.grey,
            ),
            label: 'Избранное',
            backgroundColor: Colors.black,
          ),
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: Colors.white,
            ),
            label: 'Профиль',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.shopping_cart,
              color: authService.isLoggedIn ? Colors.white : Colors.grey,
            ),
            label: 'Корзина',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat,
              color: authService.isLoggedIn ? Colors.white : Colors.grey,
            ),
            label: 'Чаты',
            backgroundColor: Colors.black,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 224, 137, 23),
        unselectedItemColor: Colors.white,
        selectedLabelStyle: const TextStyle(color: Colors.white),
        unselectedLabelStyle: const TextStyle(color: Colors.white),
        onTap: _onItemTapped,
      ),
    );
  }
}
