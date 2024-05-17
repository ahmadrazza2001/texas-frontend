import 'package:flutter/material.dart';
import 'package:texasmobiles/api/register_api.dart';
import 'package:texasmobiles/pages/login_page.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _shopAddressController = TextEditingController();

  void handleSignup() async {
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String shopAddress = _shopAddressController.text.trim();

    var result = await SignupApi.sigup(
        firstName, lastName, username, email, password, shopAddress);

    if (result['success']) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
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
        title: Text(
          'Texas Signup',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Container(
        color: Colors.black,
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Texas Mobiles',
              style: TextStyle(
                  fontSize: 28,
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _firstNameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'First Name',
                labelStyle: TextStyle(color: Colors.orangeAccent),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orangeAccent),
                ),
              ),
            ),
            TextField(
              controller: _lastNameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Last Name',
                labelStyle: TextStyle(color: Colors.orangeAccent),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orangeAccent),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.orangeAccent),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orangeAccent),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.orangeAccent),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orangeAccent),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              style: TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.orangeAccent),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orangeAccent),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _shopAddressController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Shop Address',
                labelStyle: TextStyle(color: Colors.orangeAccent),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orangeAccent),
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: handleSignup,
              child: Text(
                'Signup',
                style: TextStyle(color: Colors.white),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.orangeAccent),
                padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0)),
                textStyle: MaterialStateProperty.all(TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
