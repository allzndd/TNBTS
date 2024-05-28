import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';
import 'profil_page.dart';
import 'report_page.dart';
import 'history_page.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as Img;
import 'package:mime/mime.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Marker> _markers = [];

  // Fungsi untuk mengonversi base64 string ke Uint8List

  // String _detectImageFormat(String base64String) {
  //   try {
  //     Uint8List bytes = base64Decode(base64String);
  //     String? mimeType = lookupMimeType('unknown', headerBytes: bytes);
  //     String format = mimeType?.split('/').last ?? "Unknown";
  //     return format;
  //   } catch (e) {
  //     print("An error occurred: $e");
  //     return "Unknown";
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost/get_locations.php'));

      if (response.statusCode == 200) {
        final List<dynamic> locations = json.decode(response.body);

        setState(() {
          _markers = locations.map((location) {
            double lintang = double.parse(location['lintang'].toString());
            double bujur = double.parse(location['bujur'].toString());

            IconData iconData;
            Color iconColor;

            switch (location['jenis_bencana']) {
              case 'banjir':
                iconData = Icons.invert_colors;
                iconColor = Colors.blue;
                break;
              case 'longsor':
                iconData = Icons.terrain;
                iconColor = Colors.brown;
                break;
              case 'erupsi':
                iconData = Icons.whatshot;
                iconColor = Colors.red;
                break;
              case 'lahar panas':
                iconData = Icons.local_fire_department;
                iconColor = Colors.orange;
                break;
              case 'lahar dingin':
                iconData = Icons.ac_unit;
                iconColor = Colors.cyan;
                break;
              case 'gempa':
                iconData = Icons.vibration;
                iconColor = Colors.grey;
                break;
              case 'angin topan':
                iconData = Icons.air;
                iconColor = Colors.lightBlue;
                break;
              default:
                iconData = Icons.location_pin;
                iconColor = Colors.red;
            }

            Uint8List _decodeBase64String(String base64String) {
              return base64Decode(base64String);
            }

            Uint8List imageData = _decodeBase64String(location['photo']);

            return Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(lintang, bujur),
              child: IconButton(
                icon: Icon(iconData),
                color: iconColor,
                iconSize: 45.0,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Deskripsi Bencana',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 20, // Atur ukuran font judul
                            fontWeight:
                                FontWeight.bold, // Atur tebal font judul
                          ),
                        ),
                        content: Column(
                          children: [
                            Text(
                              'Jenis Bencana:\n${location['jenis_bencana'] ?? ''}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16, // Atur ukuran font konten
                                fontWeight:
                                    FontWeight.bold, // Atur tebal font konten
                              ),
                            ),
                            location['photo'] != null
                                ? Image.memory(
                                    imageData,
                                    height: 100,
                                  )
                                : Container(),
                            SizedBox(height: 10),
                            Text(
                              'Deskripsi Bencana:\n${location['deskripsi'] ?? ''}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16, // Atur ukuran font konten
                                fontWeight:
                                    FontWeight.bold, // Atur tebal font konten
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.white,
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Tutup',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18, // Atur ukuran font tombol
                                fontWeight:
                                    FontWeight.bold, // Atur tebal font tombol
                              ),
                            ),
                          ),
                        ],
                        elevation: 8,
                      );
                    },
                  );
                },
              ),
            );
          }).toList();
        });
      } else {
        throw Exception('Failed to load locations');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Dashboard'),
        backgroundColor: Color(0xFFFFFFFF),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.account_circle, color: Color(0xFF636363)),
            onSelected: (value) {
              if (value == 'akun_saya') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              } else if (value == 'logout') {
                _showLogoutDialog(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'akun_saya',
                child: Text('Akun Saya'),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(-8.009560, 112.950670),
              initialZoom: 13.0,
              initialCameraFit: CameraFit.bounds(
                bounds: LatLngBounds(
                  LatLng(-7.8880636984028945,
                      112.8124997303773), // Pojok atas kiri
                  LatLng(-8.235421235273524,
                      113.14326131375316), // Pojok bawah kanan
                ),
              ),
              interactiveFlags: InteractiveFlag.all,
            ),
            children: [
              openStreetMapTileLayer,
              MarkerLayer(markers: _markers),
            ],
          ),
          Center(
            child: Text(
              '',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF020306),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFFFFFFFF),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.dashboard, color: Color(0xFF636363)),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.add_alert, color: Color(0xFF636363)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.history, color: Color(0xFF636363)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text(
            'Konfirmasi Logout',
            style: TextStyle(
              color: Color(0xFF020306),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin logout?',
            style: TextStyle(color: Color(0xFF020306)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF00BFF3),
              ),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF00BFF3),
              ),
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
    );
