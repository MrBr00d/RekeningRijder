import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FuelForm(),
    );
  }
}

class FuelForm extends StatefulWidget {
  @override
  _FuelFormState createState() => _FuelFormState();
}

class _FuelFormState extends State<FuelForm> {
  // Controllers to retrieve the text values
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _litersController = TextEditingController();

  Future<void> sendData() async {
    final url = Uri.parse('http://127.0.0.1:8000/tanken'); // Replace with your URL

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json",
                  "Authorization": "Bearer nick1234"},
        body: jsonEncode({
          'km': _kmController.text,
          'liters': _litersController.text,
        }),
      );

      if (response.statusCode == 200) {
        print('Data sent successfully!');
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fuel Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _kmController,
              decoration: const InputDecoration(labelText: 'Kilometers'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _litersController,
              decoration: const InputDecoration(labelText: 'Liters'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendData,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}