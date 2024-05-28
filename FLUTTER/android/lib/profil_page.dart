import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class User {
  final int? id; // Make id nullable
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'], // This might be null
      name: json['nama_pengguna'] ?? '', // Provide a default value if null
      email: json['surel'] ?? '', // Provide a default value if null
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<User?> _userDataFuture;
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
  }

  Future<User?> _fetchUserData() async {
    final response = await http.get(Uri.parse('http://localhost/profil.php'));

    if (response.statusCode == 200) {
      Map<String, dynamic> userData = json.decode(response.body);
      print('GET result: $userData');
      return User.fromJson(userData);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  void _updateUser(String name, String email) async {
    final response = await http.post(
      Uri.parse('http://localhost/profil.php'),
      body: {'nama_pengguna': name, 'surel': email},
    );

    if (response.statusCode == 200) {
      print('User data updated successfully');
      print('POST result: ${response.body}');
    } else {
      throw Exception('Failed to update user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: TextStyle(color: const Color(0xFF020306)),
        ),
        backgroundColor: const Color(0xFFFFFFFF),
      ),
      body: FutureBuilder<User?>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            User user = snapshot.data!;
            _nameController.text = user.name;
            _emailController.text = user.email;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Pengguna',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: 'Nama Pengguna'),
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(labelText: 'Surel'),
                        ),
                        SizedBox(height: 32.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _updateUser(_nameController.text, _emailController.text);
                              },
                              child: Text('Perbarui'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Container(); // Return an empty container or handle differently
          }
        },
      ),
      backgroundColor: const Color(0xFFFFFFFF),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ProfilePage(),
  ));
}