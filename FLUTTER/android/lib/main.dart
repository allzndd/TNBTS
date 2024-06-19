import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'dashboard_page.dart';
import 'history_page.dart';
import 'report_page.dart';
import 'profil_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menghilangkan tulisan "Debug" di pojok kanan atas
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/dashboard' : (context) => DashboardPage(),
        '/history' : (context) => HistoryPage(),
        '/report' : (context) => ReportPage(),
        '/profil' : (context) => ProfilePage(),
      },
    );
  }
}