import 'package:flutter/material.dart';
import 'package:texasmobiles/pages/home_page.dart';
import 'package:texasmobiles/pages/login_page.dart';
import 'package:texasmobiles/pages/vendor_page.dart';
import 'package:texasmobiles/pages/admin_page.dart';
import 'package:texasmobiles/pages/landing_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TexasMobiles',
      theme: ThemeData(
        backgroundColor: Colors.orangeAccent,
      ),
      home: LandingScreen(),
      routes: {
        '/login': (context) => LoginPage(),
        '/homeScreen': (context) => HomeScreen(),
        '/vendorScreen': (context) => VendorScreen(),
        '/adminScreen': (context) => AdminScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
