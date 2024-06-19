import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool isLoading = true;
  List<dynamic> historyData = [];

  @override
  void initState() {
    super.initState();
    fetchHistoryData();
  }

  Future<void> fetchHistoryData() async {
    final response = await http.get(Uri.parse('http://192.168.1.30/history.php'));
    if (response.statusCode == 200) {
      setState(() {
        historyData = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load history data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Laporan Bencana',
          style: TextStyle(color: const Color(0xFF020306)),
        ),
        backgroundColor: const Color(0xFFF9C416), // Warna primer
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/your_illustration.png'), // Ganti dengan path gambar Anda
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay untuk Opacity
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          // Konten
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: historyData.length,
                    itemBuilder: (context, index) {
                      var item = historyData[index];
                      return _buildHistoryItem(
                        title: item['jenis_bencana'],
                        date: item['dibuat_pada'],
                        location: '${item['latitude']}, ${item['longitude']}',
                        description: item['deskripsi'],
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required String title,
    required String date,
    required String location,
    required String description,
  }) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              date,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8.0),
            Text(
              location,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.0),
            Text(description),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HistoryPage(),
  ));
}
