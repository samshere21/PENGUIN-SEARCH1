import 'package:flutter/material.dart';
import 'screen/demo_entry_screen.dart';
import 'screen/home_screen.dart';

void main() => runApp(const PenguinApp());

class PenguinApp extends StatelessWidget {
  const PenguinApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Penguin Search', debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFBD263C)),
      scaffoldBackgroundColor: const Color(0xFFF8F7F5),
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder())),
    home: const DemoEntry(),
  );
}

class DemoEntry extends StatelessWidget {
  const DemoEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoEntryScreen(
      onOpenDemo: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const HomePage(),
          ),
        );
      },
    );
  }
}
