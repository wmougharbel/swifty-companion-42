import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({ super.key });

  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }

}