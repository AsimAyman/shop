import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop/ui/screen/glocery_screen.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 146, 230, 247),
          surface: const Color.fromARGB(255, 44, 50, 60),
        ),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color.fromARGB(255, 49, 57, 59),
      ),
      home: GroceryScreen(),
    );
  }
}
