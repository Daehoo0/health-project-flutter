import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:health_project_flutter/AuthProvider.dart';
import 'package:health_project_flutter/pages/dokter/profile.dart';
import 'package:health_project_flutter/pages/login.dart';
import 'package:health_project_flutter/pages/user/hitungkalori.dart';
import 'package:health_project_flutter/pages/user/program.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  const apiKey = 'AIzaSyByWqlOF0TP5P_n-LdDJOi14JC9O7ipY7k';
  Gemini.init(apiKey: apiKey);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // name: "healthproject-83a51",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => DataLogin(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ProgramListPage(),
      ),
    );
  }
}
