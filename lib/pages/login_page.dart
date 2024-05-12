import 'package:flutter/material.dart';
import 'package:texasmobiles/api/auth_api.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    var result = await AuthApi.login(email, password);

    if (result['success']) {
      switch (result['role']) {
        case 'user':
          Navigator.pushReplacementNamed(context, '/homeScreen');
          break;
        case 'vendor':
          Navigator.pushReplacementNamed(context, '/vendorScreen');
          break;
        case 'admin':
          Navigator.pushReplacementNamed(context, '/adminScreen');
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Unexpected user role received.'),
            backgroundColor: Colors.orangeAccent,
          ));
          break;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['error']),
        backgroundColor: Colors.orangeAccent,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: Colors.black,
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 28, color: Colors.green, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            TextField(
              controller: _emailController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.green),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              style: TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.green),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: handleLogin,
              child: Text('Login', style: TextStyle(color: Colors.white),),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green),
                padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0)),
                textStyle: MaterialStateProperty.all(TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
