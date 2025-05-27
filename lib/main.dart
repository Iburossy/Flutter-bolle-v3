import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'injection_container.dart' as di; // di for dependency injection

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');
  
  // Initialize dependency injection
  await di.init();
  
  runApp(const App());
}
