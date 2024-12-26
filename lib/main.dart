// ignore_for_file: avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'screens/virtual_assistant_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asistente Virtual',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const VirtualAssistantScreen(),
    );
  }
}
