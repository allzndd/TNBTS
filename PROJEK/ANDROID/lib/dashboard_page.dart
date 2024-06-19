import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';
import 'profil_page.dart';
import 'report_page.dart';
import 'history_page.dart';
import 'cuaca_page.dart';
import 'dart:typed_data';


class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
  try {
    final response = await http.get(Uri.parse('http://192.168.1.30/get_locations.php'));

    if (response.statusCode == 200) {
      final List<dynamic> locations = json.decode(response.body);

      for (var location in locations) {
        double? lintang, bujur; // Menggunakan nullable double

        lintang = double.parse(location['lintang'].toString());
        bujur = double.parse(location['bujur'].toString());

        // Memastikan lintang dan bujur tidak null sebelum menambahkan marker
        if (lintang != null && bujur != null) {
          _addMarker(
            lintang,
            bujur,
            location['jenis_bencana'],
            location['deskripsi'],
            location['photo'],
            location['cuaca'],
            "", // Nama lokasi dikosongkan
          );
        }
      }
    } else {
      throw Exception('Failed to load locations');
    }
  } catch (e) {
    print('Error: $e');
  }
}


  Future<Map<String, double>> _getCoordinatesFromAddress(String address) async {
    final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?q=$address&format=json'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        return {
          'lat': double.parse(data[0]['lat']),
          'lon': double.parse(data[0]['lon']),
        };
      } else {
        throw Exception('No coordinates found for the address');
      }
    } else {
      throw Exception('Failed to load coordinates');
    }
  }

  void _addMarker(double lintang, double bujur, String jenisBencana, String deskripsi, String photo, List<dynamic> cuaca, String namaLokasi) {
    IconData iconData;
    Color iconColor;

    switch (jenisBencana) {
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

    Uint8List imageData = _decodeBase64String(photo);

    setState(() {
      _markers.add(Marker(
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Nama Lokasi:\n$namaLokasi',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Jenis Bencana:\n$jenisBencana',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Deskripsi Bencana:\n$deskripsi',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Cuaca Terdekat:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ...cuaca.map((cuaca) {
                          return ListTile(
                            leading: Image.network(
                              'https://ibnux.github.io/BMKG-importer/icon/${cuaca['kodeCuaca']}.png',
                              width: 32,
                              height: 32,
                            ),
                            title: Text(cuaca['cuaca']),
                            subtitle: Text(cuaca['jamCuaca']),
                          );
                        }).toList(),
                      ],
                    ),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
      ));
    });
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
                  LatLng(-7.8880636984028945, 112.8124997303773),
                  LatLng(-8.235421235273524, 113.14326131375316),
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
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardPage()),
                );
              },
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
            IconButton(
              icon: Icon(Icons.cloud, color: Color(0xFF636363)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CuacaPage()),
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
