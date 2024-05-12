import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final response = await http.post(
      Uri.parse('http://localhost/login.php'), // Ganti dengan URL endpoint login Anda
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['message'] == 'Login successful') {
        // Login berhasil, lanjutkan ke dashboard atau halaman berikutnya
        print('Login successful');
        print('User: ${data['user']}');
      } else {
        // Login gagal, tampilkan pesan kesalahan
        print('Login failed: ${data['message']}');
      }
    } else {
      // Gagal terhubung ke server, tampilkan pesan kesalahan
      print('Failed to connect to server');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username or Email'),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
            SizedBox(height: 12.0),
            TextButton(
              onPressed: () {
                // Navigasi ke halaman registrasi
                print('Go to registration page');
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}