import 'package:flutter/material.dart';
import 'package:flutter_police_traffic_management_app/auth.dart';

class LoginScreen extends StatefulWidget {
    const LoginScreen({super.key}); // Added key parameter

    @override
    _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> { // Corrected class name and extends State
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final AuthService _authService = AuthService.instance;

    void _login() async {
        BuildContext currentContext = context; // Store context locally

        bool success = await _authService.loginUser(
            _usernameController.text, _passwordController.text);
        if (mounted && currentContext == context) { // Check if context is still valid
            if (success) {
                Navigator.pushReplacementNamed(currentContext, '/dashboard'); // Use local context
            } else {
                ScaffoldMessenger.of(currentContext).showSnackBar(
                    const SnackBar(content: Text('Invalid Credentials'))); // Use local context
            }
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text('Login')),
            body: Padding( // Corrected to Padding widget
                padding: const EdgeInsets.all(16.0), // Corrected to EdgeInsets
                child: Column( // Corrected to Column widget
                    children: [
                        TextField(
                            controller: _usernameController,
                            decoration: const InputDecoration(labelText: 'Username')),
                        TextField(
                            controller: _passwordController,
                            decoration: const InputDecoration(labelText: 'Password'),
                            obscureText: true),
                        ElevatedButton(onPressed: _login, child: const Text('Login')),
                    ],
                ),
            ),
        );
    }
}