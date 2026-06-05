import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shiksha_darpan/screens/auth/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ShikshaDarpanApp());
}

class ShikshaDarpanApp extends StatelessWidget {
  const ShikshaDarpanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShikshaDarpan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto', // Modern typography
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white, 
            fontSize: 20, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
