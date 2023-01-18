import 'package:attendancerecords/page/introduction_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'setting/firebase_options.dart';
import 'page/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp(
      name: 'attendance-record---flutter',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool doneIntro = true;

  @override
  void initState() {
    _loadUserOptions();
    super.initState();
  }

  void _loadUserOptions() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      doneIntro = (prefs.getBool('introduction') ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (doneIntro) {
      return const StartHome();
    }
    return const StartIntroductionPage();
  }
}
