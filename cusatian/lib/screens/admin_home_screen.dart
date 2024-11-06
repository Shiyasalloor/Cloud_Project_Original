import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'profile.dart';
import 'global_chat.dart';
import 'announcements_screen.dart';
import 'events_screen.dart';
import 'clubs_screen.dart';
import 'add_something.dart'; // Import the AddSomething screen

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;
  List<dynamic> announcements = [];
  List<dynamic> events = [];
  List<dynamic> clubs = [];

  @override
  void initState() {
    super.initState();
    _fetchHomepageData();
  }

  Future<void> _fetchHomepageData() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/content/homepage'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Log data to see if we are receiving it correctly
        print("Data received: $data");

        setState(() {
          // Process announcements
          announcements = (data['announcements'] as List<dynamic>?)
                  ?.where((item) => item['date'] != null)
                  .toList() ??
              [];
          announcements.sort((a, b) => b['date'].compareTo(a['date']));
          if (announcements.length > 3) announcements = announcements.sublist(0, 3);

          // Process events
          events = (data['events'] as List<dynamic>?)
                  ?.where((item) => item['date'] != null)
                  .toList() ??
              [];
          events.sort((a, b) => b['date'].compareTo(a['date']));
          if (events.length > 3) events = events.sublist(0, 3);

          // Process clubs
          clubs = (data['clubs'] as List<dynamic>?)
                  ?.where((item) => item['date'] != null)
                  .toList() ??
              [];
          clubs.sort((a, b) => b['date'].compareTo(a['date']));
          if (clubs.length > 3) clubs = clubs.sublist(0, 3);
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
        (Route<dynamic> route) => false,
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GlobalChat()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CUSATIAN - Admin',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEC7063),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Welcome to CUSATIAN Admin Portal!',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Manage announcements, events, and clubs at the Cochin University of Science and Technology.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              _buildSectionHeader(
                context,
                title: 'Announcements',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AnnouncementsScreen()),
                  );
                },
              ),

              const SizedBox(height: 10),
              _buildContentList(announcements),

              const SizedBox(height: 40),

              _buildSectionHeader(
                context,
                title: 'Events',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EventsScreen()),
                  );
                },
              ),

              const SizedBox(height: 10),
              _buildContentList(events),

              const SizedBox(height: 40),

              _buildSectionHeader(
                context,
                title: 'Clubs',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ClubsScreen()),
                  );
                },
              ),

              const SizedBox(height: 10),
              _buildContentList(clubs),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: const Color(0xFFEC7063),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }

  Widget _customBox(String title, String description, String date) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            Text(
              date,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {
    required String title,
    required VoidCallback onPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.add,
                color: Color(0xFFEC7063),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddSomething(contentType: title),
                  ),
                );
              },
            ),
            TextButton(
              onPressed: onPressed,
              child: const Text(
                'See All',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEC7063),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentList(List<dynamic> contentList) {
    if (contentList.isEmpty) {
      return Center(
        child: Text(
          'No content available',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: contentList.length,
        itemBuilder: (context, index) {
          final item = contentList[index];
          return _customBox(
            item['title'] ?? 'Untitled',
            item['description'] ?? 'No description',
            item['date'] ?? 'Unknown date',
          );
        },
      ),
    );
  }
}
