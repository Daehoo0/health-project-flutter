import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:health_project_flutter/pages/admin/addartikel.dart';
import 'package:health_project_flutter/pages/dokter/addartikel.dart';
import 'package:health_project_flutter/pages/login.dart';
import 'package:health_project_flutter/pages/user/artikel.dart';
import 'package:health_project_flutter/pages/user/hitungkalori.dart';
import 'firebase_options.dart'; // Pastikan ini diimpor

void main() async {
  const apiKey = 'AIzaSyByWqlOF0TP5P_n-LdDJOi14JC9O7ipY7k';
  Gemini.init(apiKey: apiKey);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "healthproject-83a51",
    options: DefaultFirebaseOptions.currentPlatform, // Gunakan FirebaseOptions yang dihasilkan
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalorieCounterPage(),
    );
  }
}
