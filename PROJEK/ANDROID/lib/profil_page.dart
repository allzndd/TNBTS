import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool isLoading = true;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      fetchUserData();
    });
  }

  Future<int?> getUserIdFromSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_pengguna');
  }

  Future<void> fetchUserData() async {
    try {
      // Mendapatkan ID pengguna dari sesi
      final userId = await getUserIdFromSession();
      print('User ID: $userId');

      if (userId == null) {
        throw Exception('User ID is null');
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.30/profil.php?id=$userId'),
      );

      // Print respons body untuk debug
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final namaPengguna = data['nama_pengguna'];
        final surel = data['surel'];

        setState(() {
          nameController.text = namaPengguna ?? '';
          emailController.text = surel ?? '';
          isLoading = false;
        });

        print('Nama: $namaPengguna');
        print('Surel: $surel');
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> saveUserData() async {
  final userId = await getUserIdFromSession();

  final response = await http.post(
    Uri.parse('http://10.10.183.32/profil.php'),
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded', // Atur content type di sini
    },
    body: {
      'id_pengguna': userId.toString(),
      'nama_pengguna': nameController.text,
      'surel': emailController.text,
    },
  );

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data pengguna berhasil diperbarui')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal memperbarui data pengguna')),
    );
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/your_illustration.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                Padding(
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
                              controller: nameController,
                              enabled: isEditing,
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: emailController,
                              enabled: isEditing,
                            ),
                            SizedBox(height: 32.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isEditing = true;
                                    });
                                  },
                                  child: Text('Edit'),
                                ),
                                ElevatedButton(
                                  onPressed: isEditing ? saveUserData : null,
                                  child: Text('Simpan'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      isEditing = false;
                                    });
                                  },
                                  child: Text('Batal'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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