// ignore_for_file: avoid_print, deprecated_member_use

import 'package:flutter/material.dart';
import 'screens/loading_screen.dart';
import 'package:flutter/foundation.dart';

void main() {
  // Filtrar logs no deseados
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoadingScreen(),
    );
  }
}
