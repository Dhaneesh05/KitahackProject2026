import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:js' as js;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Firebase using platform defaults
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  if (kIsWeb) {
    // The web/index.html is now fetching the .env directly to inject the maps script.
    // js.context['GOOGLE_MAPS_API_KEY'] = dotenv.env['GOOGLE_MAPS_API_KEY'];
  }
  
  runApp(const HydroVisionApp());
}

class HydroVisionApp extends StatelessWidget {
  const HydroVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HydroVision',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const LoginScreen(),
    );
  }
}
