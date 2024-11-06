import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'display_content.dart'; // Import DisplayContentScreen file

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String content;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.content,
  });
}

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Event> events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/content/event'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        print("Fetched data: $data");  // Debug print to check API response

        setState(() {
          events = data.map((item) {
            try {
              return Event(
                id: item['_id'] ?? '',
                title: item['title'] ?? 'No Title',
                description: item['description'] ?? 'No Description',
                eventDate: DateTime.parse(item['date']),
                content: item['contents'] ?? 'No Content',
              );
            } catch (e) {
              print("Error parsing event: $e");
              return Event(
                id: '',
                title: 'Invalid Data',
                description: 'Invalid Data',
                eventDate: DateTime.now(),
                content: 'Invalid Data',
              );
            }
          }).toList();

          events.sort((a, b) => b.eventDate.compareTo(a.eventDate));
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load events');
      }
    } catch (error) {
      print('Error fetching events: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToDisplayContent(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayContentScreen(
          id: event.id,
          title: event.title,
          postedDate: event.eventDate,
          description: event.description,
          content: event.content,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Events',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFEC7063),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => navigateToDisplayContent(event),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          event.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(event.description),
                        trailing: Text(
                          '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}',
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
