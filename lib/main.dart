import 'package:checkbox_grouped/checkbox_grouped.dart';
import 'package:flutter/material.dart';
import 'view/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // await firebase.initializeApp();
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const LoginPage()
    },
  ));
}

class VMApp extends StatelessWidget {
  const VMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginPage(),
    );
  }
}
