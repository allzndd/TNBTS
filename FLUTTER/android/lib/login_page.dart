import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'register_page.dart';
import 'dashboard_page.dart';

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

    // if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['message'] == 'Login successful') {
//         // Login berhasil, lanjutkan ke dashboard atau halaman berikutnya
//         print('Login successful');
//         print('User: ${data['user']}');
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => DashboardPage()),
//         );
//       } else {
//         // Login gagal, tampilkan pesan kesalahan
//         print('Login failed: ${data['message']}');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Incorrect username/email or password. Please try again.'),
//             duration: Duration(seconds: 3),
//             action: SnackBarAction(
//               label: 'OK',
//               onPressed: () {},
//             ),
//           ),
//         );
//       }
//     } else {
//       // Gagal terhubung ke server, tampilkan pesan kesalahan
//       print('Failed to connect to server');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to connect to the server. Please try again later.'),
//           duration: Duration(seconds: 3),
//           action: SnackBarAction(
//             label: 'OK',
//             onPressed: () {},
//           ),
//         ),
//       );
//     }
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
            // Gambar/logo di bagian atas
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Image.asset(
                'assets/logo.png', 
                height: 200,
                width: 200,
                // Sesuaikan dengan ukuran gambar/logo kamu
              ),
            ),
            // TextField untuk username atau email
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username or Email'),
            ),
            SizedBox(height: 12.0),
            // TextField untuk password
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
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}