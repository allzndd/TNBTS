import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:file_picker/file_picker.dart';
import 'dashboard_page.dart';
import 'package:http/http.dart' as http;

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  double? _latitude;
  double? _longitude;
  Uint8List? _imageData;
  String? _selectedDisasterType;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _locationController.text = 'Lat: $_latitude, Lng: $_longitude';
    });
  }

  Future<void> _pickImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _imageData = result.files.first.bytes;
      });
    }
  }

  Future<void> _submitReport() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  final String description = _descriptionController.text;
  final String disasterType = _selectedDisasterType ?? '';
  final String status = 'menunggu';

  final String? base64Image =
      _imageData != null ? base64Encode(_imageData!) : null;

  // Mendapatkan nilai latitude dan longitude dari lokasi saat ini
  String? latitude = _latitude?.toString();
  String? longitude = _longitude?.toString();

  // Batas peta
  const double topLeftLat = -7.8880636984028945;
  const double bottomRightLat = -8.235421235273524;
  const double topLeftLng = 112.8124997303773;
  const double bottomRightLng = 113.14326131375316;

  // Memeriksa apakah koordinat berada dalam batas peta
  if (_latitude != null && _longitude != null) {
    if (_latitude! >= bottomRightLat && _latitude! <= topLeftLat &&
        _longitude! >= topLeftLng && _longitude! <= bottomRightLng) {
      _locationController.text = 'Lat: $_latitude, Lng: $_longitude';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Koordinat berada di luar batas peta'),
        backgroundColor: Colors.red,
      ));
      return;
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Koordinat tidak tersedia'),
      backgroundColor: Colors.red,
    ));
    return;
  }

  const String apiUrl = 'http://localhost/report.php';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'description': description,
        'disasterType': disasterType,
        'status': status,
        'latitude': latitude ?? '',
        'longitude': longitude ?? '',
        'image': base64Image ?? '',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = response.body;
      if (responseBody.contains('success=')) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => DashboardPage()),
          (Route<dynamic> route) => false,
        );
      } else if (responseBody.contains('error=')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal mengirim laporan: ${responseBody.split('=')[1]}'),
          backgroundColor: Colors.red,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal mengirim laporan: Respons tidak dikenali'),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal mengirim laporan: ${response.reasonPhrase}'),
        backgroundColor: Colors.red,
      ));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Terjadi kesalahan: $e'),
      backgroundColor: Colors.red,
    ));
  }
}

//   void main() {
//   // Koordinat yang akan diperiksa
//   double latitude = -8.0;
//   double longitude = 113.0;

//   // Batas peta
//   double topLeftLat = -7.8880636984028945;
//   double topLeftLng = 112.8124997303773;
//   double bottomRightLat = -8.235421235273524;
//   double bottomRightLng = 113.14326131375316;

//   // Memeriksa apakah koordinat berada di dalam batas peta
//   if (latitude <= topLeftLat && latitude >= bottomRightLat && longitude >= topLeftLng && longitude <= bottomRightLng) {
//     print("Koordinat berada di dalam batas peta.");
//   } else {
//     print("Koordinat berada di luar batas peta.");
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Laporkan Bencana Alam',
          style: TextStyle(color: const Color(0xFF020306)),
        ),
        backgroundColor: const Color(0xFFF9C416),
      ),
      body: Stack(
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
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.7,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Judul Laporan',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8.0),
                          _buildDisasterTypeDropdown(),
                          SizedBox(height: 16.0),
                          Text(
                            'Pilih Lokasi',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8.0),
                          _buildLocationSelection(),
                          SizedBox(height: 16.0),
                          TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              labelText: 'Lokasi',
                              border: OutlineInputBorder(),
                            ),
                            readOnly: true,
                          ),
                          SizedBox(height: 16.0),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Deskripsi Singkat',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a description';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.0),
                          if (_imageData != null) ...[
                            Image.memory(_imageData!),
                            SizedBox(height: 8.0),
                            Text(
                                'Gambar di atas akan digunakan sebagai foto laporan.')
                          ],
                          SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: () {
                              _showConfirmationDialog(context);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: const Color(0xFF00BFF3),
                            ),
                            child: Text('Laporkan'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisasterTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDisasterType,
      onChanged: (String? newValue) {
        setState(() {
          _selectedDisasterType = newValue;
        });
      },
      decoration: InputDecoration(
        labelText: 'Jenis Bencana',
        border: OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem(
          value: 'Banjir',
          child: Row(
            children: [
              Icon(Icons.invert_colors, color: Colors.blue),
              SizedBox(width: 8.0),
              Text('Banjir'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'Longsor',
          child: Row(
            children: [
              Icon(Icons.terrain, color: Colors.brown),
              SizedBox(width: 8.0),
              Text('Longsor'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'Erupsi',
          child: Row(
            children: [
              Icon(Icons.whatshot, color: Colors.red),
              SizedBox(width: 8.0),
              Text('Erupsi'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'Lahar Panas',
          child: Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.orange),
              SizedBox(width: 8.0),
              Text('Lahar Panas'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'Lahar Dingin',
          child: Row(
            children: [
              Icon(Icons.ac_unit, color: Colors.cyan),
              SizedBox(width: 8.0),
              Text('Lahar Dingin'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'Gempa',
          child: Row(
            children: [
              Icon(Icons.vibration, color: Colors.grey),
              SizedBox(width: 8.0),
              Text('Gempa'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'Angin Topan',
          child: Row(
            children: [
              Icon(Icons.air, color: Colors.lightBlue),
              SizedBox(width: 8.0),
              Text('Angin Topan'),
            ],
          ),
        ),
      ],
      hint: Text('Pilih Jenis Bencana'),
    );
  }

  Widget _buildLocationSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            _pickImage();
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: const Color(0xFFF9C416),
            backgroundColor: const Color(0xFF020306),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 5.0,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
          child: Text(
            'Ambil Foto',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        SizedBox(height: 16.0),
        ElevatedButton.icon(
          onPressed: () {
            _getCurrentLocation();
          },
          icon: Icon(Icons.my_location, color: const Color(0xFF020306)),
          label: Text(
            'Pilih Lokasi Anda Sekarang',
            style: TextStyle(fontSize: 16.0, color: const Color(0xFF020306)),
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor: const Color(0xFFF9C416),
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ],
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Laporkan'),
          content: Text('Data Anda akan segera dikonfirmasi oleh admin.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                _submitReport(); // Memanggil fungsi untuk mengirim laporan
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xFF00BFF3),
              ),
              child: Text('Laporkan'),
            ),
          ],
        );
      },
    );
  }
}
