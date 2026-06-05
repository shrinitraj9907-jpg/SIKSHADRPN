import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shiksha_darpan/screens/auth/login_screen.dart';
import 'firebase_options.dart';

// Global notifier for theme changes
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'ShikshaDarpan',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'Roboto', // Modern typography
            brightness: Brightness.light,
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
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.blueGrey,
            colorScheme: const ColorScheme.dark(
              primary: Colors.blueGrey,
              secondary: Colors.tealAccent,
            ),
            appBarTheme: AppBarTheme(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Colors.grey[900],
              iconTheme: const IconThemeData(color: Colors.white),
              titleTextStyle: const TextStyle(
                color: Colors.white, 
                fontSize: 20, 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}
