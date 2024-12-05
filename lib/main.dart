import 'package:aplikasi_todo/firebase_options.dart';
import 'package:aplikasi_todo/view/todo_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo-List Task',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor:
              Colors.lightBlue[800]!, // Set primary color using colorScheme
        ),
      ),
      home: const TodoPage(), // Set TodoPage as the home widget
    );
  }
}
