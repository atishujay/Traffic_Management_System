import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_police_traffic_management_app/database.dart';
import 'package:flutter_police_traffic_management_app/network_service.dart';
import 'package:flutter_police_traffic_management_app/login.dart';
import 'package:flutter_police_traffic_management_app/auth.dart';

class DashboardScreen extends StatefulWidget{
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}
class _DashboardScreenState extends State<DashboardScreen> {
  final db = DatabaseHelper.instance;
  final net = NetworkService();
  String? user;
  int points = 0;
  List<Map<String, dynamic>> violations = [];

  @override
  void initState() {
    super.initState();
    _init();
  }
  Future<void> _init() async{
    user = await AuthService.instance.getCurrentUser();
    await _loadData();
    await _loadData();
    await net.connect('192.168.1.41', 9000, _loadData);
  }
  Future<void> _loadData() async {
    if (user == null) return;

    final pts = await db.getUserPoints(user!);
    final viols = await db.getViolations(user!);

    setState(() {
      points = pts;
      violations = viols;
    });

    // Show message if available
    final message = net.latestMessage;
    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: Duration(seconds: 4)),
      );
      net.latestMessage = null; // Clear after showing
    }
  }
  @override
  void dispose(){
    net.dispose();
    super.dispose();
  }
  void _logout() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [IconButton(icon: Icon(Icons.logout),onPressed: _logout)],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Points: $points',style: TextStyle(fontSize: 24)),
            subtitle: points < 300
            ? Text('Low points! Pay fine.', style: TextStyle(color: Colors.red))
            : null,
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: violations.length,
              itemBuilder: (_, i) {
                final v = violations[i];
                return ListTile(
                  title: Text('${v['plate']} @ ${v['place']}'),
                  subtitle: Text(v['timestamp']),
                  trailing: Text('-${v['points']}'),
                );
              },
            ),
          ),
        ],
      ),
      );
  }
}