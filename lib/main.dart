flutterimport 'package:flutter/material.dart';
import 'package:flutter_police_traffic_management_app/auth.dart';
import 'package:flutter_police_traffic_management_app/login.dart';
import 'package:flutter_police_traffic_management_app/dashboard.dart';

void main() async {
  print("✅ App is starting...");
  WidgetsFlutterBinding.ensureInitialized();
  final username = await AuthService.instance.getCurrentUser();
  runApp(MyApp(initialUser: username));
}

class MyApp extends StatelessWidget {
  final String? initialUser;
  const MyApp({this.initialUser, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traffic Violation',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: initialUser != null ? DashboardScreen() : LoginScreen(),
      routes:{
        '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
}
