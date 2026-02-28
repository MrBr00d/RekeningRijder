import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

Future<void> main() async {
  // Ensure .env is loaded from the root (where pubspec.yaml lives)
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FuelForm(),
    );
  }
}

class FuelForm extends StatefulWidget {
  const FuelForm({super.key});

  @override
  _FuelFormState createState() => _FuelFormState();
}

class _FuelFormState extends State<FuelForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _litersController = TextEditingController();

  Future<void> sendData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final url = Uri.parse('https://tankenbackend.nvvliet.nl/tanken');
    final String apiKey = dotenv.env['APIKEY'] ?? '';

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          'km': double.parse(_kmController.text), // Convert to number
          'liters': double.parse(_litersController.text),
        }),
      );

      if (response.statusCode == 200) {
        // THIS IS THE "POPUP" MESSAGE
        if (mounted) { // Check if the widget is still in the tree
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Success! Fuel data saved.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Optional: Clear the fields after success
          _kmController.clear();
          _litersController.clear();
        }
      } else {
        _showErrorSnackBar('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('Connection failed: $e');
    }
  }

// Helper to show errors
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fuel Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _kmController,
                decoration: const InputDecoration(labelText: 'Kilometers'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  // Using your specific Regex here
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*\.?[0-9]*$')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _litersController,
                decoration: const InputDecoration(labelText: 'Liters'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  // Using your specific Regex here
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*\.?[0-9]*$')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: sendData,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}