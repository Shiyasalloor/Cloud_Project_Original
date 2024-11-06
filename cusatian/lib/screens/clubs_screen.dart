import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'display_content.dart'; // Import DisplayContentScreen

class Club {
  final String id;
  final String title;
  final String description;
  final DateTime postedDate;
  final String content;

  Club({
    required this.id,
    required this.title,
    required this.description,
    required this.postedDate,
    required this.content,
  });
}

class ClubsScreen extends StatefulWidget {
  @override
  _ClubsScreenState createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  List<Club> clubs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClubs();
  }

  Future<void> fetchClubs() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/content/club'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        print("Fetched data: $data");  // Debug print to verify API response

        setState(() {
          clubs = data.map((item) {
            try {
              return Club(
                id: item['_id'] ?? '',
                title: item['title'] ?? 'No Title',
                description: item['description'] ?? 'No Description',
                postedDate: DateTime.parse(item['date']),
                content: item['contents'] ?? 'No Content',
              );
            } catch (e) {
              print("Error parsing club: $e");
              return Club(
                id: '',
                title: 'Invalid Data',
                description: 'Invalid Data',
                postedDate: DateTime.now(),
                content: 'Invalid Data',
              );
            }
          }).toList();

          clubs.sort((a, b) => b.postedDate.compareTo(a.postedDate)); // Sort by date if applicable
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load clubs');
      }
    } catch (error) {
      print('Error fetching clubs: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToDisplayContent(Club club) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayContentScreen(
          id: club.id,
          title: club.title,
          description: club.description,
          postedDate: club.postedDate,
          content: club.content,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clubs'),
        backgroundColor: const Color(0xFFEC7063),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: clubs.length,
              itemBuilder: (context, index) {
                final club = clubs[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => navigateToDisplayContent(club),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          club.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(club.description),
                        trailing: Text(
                          '${club.postedDate.day}/${club.postedDate.month}/${club.postedDate.year}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
