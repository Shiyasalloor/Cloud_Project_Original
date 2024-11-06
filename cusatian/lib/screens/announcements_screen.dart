import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'display_content.dart'; // Import DisplayContentScreen file

class Announcement {
  final String id;
  final String title;
  final String description;
  final DateTime postedDate;
  final String content;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.postedDate,
    required this.content,
  });
}

class AnnouncementsScreen extends StatefulWidget {
  @override
  _AnnouncementsScreenState createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  List<Announcement> announcements = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/content/announcement'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        setState(() {
          announcements = data.map((item) {
            return Announcement(
              id: item['_id'],
              title: item['title'],
              description: item['description'],
              postedDate: DateTime.parse(item['date']),
              content:item['contents']
            );
          }).toList();

          announcements.sort((a, b) => b.postedDate.compareTo(a.postedDate));
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load announcements');
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToDisplayContent(Announcement announcement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayContentScreen(
          id: announcement.id,
          title: announcement.title,
          postedDate: announcement.postedDate,
          description: announcement.description,
          content: announcement.content
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Announcements',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFEC7063),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => navigateToDisplayContent(announcement),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          announcement.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(announcement.description),
                        trailing: Text(
                          '${announcement.postedDate.day}/${announcement.postedDate.month}/${announcement.postedDate.year}',
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
