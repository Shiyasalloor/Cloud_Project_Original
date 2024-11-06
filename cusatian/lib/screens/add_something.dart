import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddSomething extends StatefulWidget {
  final String contentType;

  const AddSomething({super.key, required this.contentType});

  @override
  _AddSomethingState createState() => _AddSomethingState();
}

class _AddSomethingState extends State<AddSomething> {
  final TextEditingController headlineController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  Future<void> _uploadSomething() async {
  String headline = headlineController.text;
  String description = descriptionController.text;
  String content = contentController.text;

  // Ensure contentType matches exactly the expected values in the backend
  String contentType;
  switch (widget.contentType.toLowerCase()) {
    case 'announcements':
    case 'announcement':
      contentType = 'announcement';
      break;
    case 'events':
    case 'event':
      contentType = 'event';
      break;
    case 'clubs':
    case 'club':
      contentType = 'club';
      break;
    default:
      contentType = widget.contentType.toLowerCase();
  }

  // Print the content type for debugging
  print('Content type (adjusted): $contentType');

  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/api/content/add'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': headline,
        'description': description,
        'contents': content,
        'type': contentType,
      }),
    );

    // Print response status and body for debugging
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploaded successfully!')),
      );
      headlineController.clear();
      descriptionController.clear();
      contentController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: ${response.statusCode} ${response.body}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $e')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.contentType}'),
        backgroundColor: const Color(0xFFEC7063),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: headlineController,
              decoration: InputDecoration(
                labelText: 'Headline',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: contentController,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _uploadSomething,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC7063),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'UPLOAD',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
