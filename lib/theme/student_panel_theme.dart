import 'package:flutter/material.dart';

class StudentPanelTheme {
  static const Color indigo = Color(0xFF3F51B5);
  static const Color indigoDark = Color(0xFF303F9F);
  static const Color indigoLight = Color(0xFFC5CAE9);
  static const Color accent = Color(0xFF5C6BC0);

  static AppBarTheme appBar() => const AppBarTheme(
        backgroundColor: indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      );

  static ThemeData panelTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: indigo,
        primary: indigo,
        secondary: accent,
      ),
      appBarTheme: appBar(),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Color(0xB3FFFFFF),
        indicatorColor: Colors.white,
      ),
    );
  }
}
