import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';
import 'dashboard_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:map_picker/map_picker.dart';

class CuacaPage extends StatefulWidget {
  @override
  _CuacaPageState createState() => _CuacaPageState();
}

class _CuacaPageState extends State<CuacaPage> {
  final mapController = MapController();
  final mapPickerController = MapPickerController();
  LatLng cameraPosition = LatLng(-8.009560, 112.950670);
  double cameraZoom = 13.0;
  final textController = TextEditingController();
  List<Map<String, dynamic>> cuaca = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cuaca Hari Ini', style: TextStyle(color: const Color(0xFF020306))),
        backgroundColor: const Color(0xFFF9C416),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: MapPicker(
                    // iconWidget: Icon(
                    //   Icons.location_on,
                    //   size: 60,
                    //   color: Colors.red,
                    // ),
                    mapPickerController: mapPickerController,
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: cameraPosition,
                        initialZoom: cameraZoom,
                        onPositionChanged: (MapPosition position, bool hasGesture) {
                          if (hasGesture) {
                            mapPickerController.mapMoving!();
                            textController.text = "Memeriksa ...";
                            setState(() {
                              cameraPosition = position.center!;
                              cameraZoom = position.zoom!;
                            });
                          }
                        },
                      ),
                      children: [
                        openStreetMapTileLayer,
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 80.0,
                              height: 80.0,
                              point: cameraPosition,
                              child: GestureDetector(
                                onTap: () {
                                  getWeatherFromMarker(cameraPosition);
                                },
                                child: Icon(
                                  Icons.location_on,
                                  size: 60,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: textController,
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                hintText: 'Koordinat akan ditampilkan di sini',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                textController.text =
                    'Latitude: ${cameraPosition.latitude}, Longitude: ${cameraPosition.longitude}';
              });
              await getWeather(cameraPosition.latitude, cameraPosition.longitude);
            },
            child: Text('Dapatkan Koordinat dan Cuaca'),
            style: ElevatedButton.styleFrom(
              primary: const Color(0xFFF9C416), // Warna latar belakang
              onPrimary: const Color(0xFF020306), // Warna teks
            ),
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: ListView(
              children: [
                Text(
                  'Cuaca Terdekat:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            textController.text =
                'Latitude: ${cameraPosition.latitude}, Longitude: ${cameraPosition.longitude}';
          });
          await getWeather(cameraPosition.latitude, cameraPosition.longitude);
        },
        child: Icon(Icons.gps_fixed),
        backgroundColor: const Color(0xFFF9C416), // Warna latar belakang
      ),
    );
  }

  Future<void> getWeather(double latitude, double longitude) async {
    final url = 'http://192.168.1.30/get_weather.php?lat=$latitude&lon=$longitude';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        cuaca = List<Map<String, dynamic>>.from(data['weather']);
        textController.text =
            'Latitude: $latitude, Longitude: $longitude';
      });
    } else {
      // Error handling
      print('Failed to load weather data');
    }
  }

  // Fungsi untuk mendapatkan informasi cuaca berdasarkan marker yang dipilih
  Future<void> getWeatherFromMarker(LatLng markerPosition) async {
    await getWeather(markerPosition.latitude, markerPosition.longitude);
  }
}

void main() => runApp(MaterialApp(
      home: CuacaPage(),
    ));

