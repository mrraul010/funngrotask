import 'package:flutter/material.dart';
import 'package:funngroapp/earnings/earnings_screen.dart';
import 'package:funngroapp/earnings/model/earnings_viewmodel.dart';
import 'package:funngroapp/homescreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Funngro Assessment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AssessmentHome(),
    );
  }
}
