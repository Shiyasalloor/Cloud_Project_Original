import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'profile.dart';
import 'global_chat.dart';
import 'announcements_screen.dart';
import 'events_screen.dart';
import 'clubs_screen.dart';
import 'display_content.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        setState(() {
          announcements = data['announcements'] ?? [];
          events = data['events'] ?? [];
          clubs = data['clubs'] ?? [];
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
        MaterialPageRoute(builder: (context) => const HomeScreen()),
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
          'CUSATIAN',
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
                  'Welcome to CUSATIAN!',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Cochin University of Science and Technology (CUSAT) is a premier institution for higher education in India.',
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

  Widget _buildContentList(List<dynamic> contentList) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: contentList.length,
        itemBuilder: (context, index) {
          final item = contentList[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DisplayContentScreen(
                    id: item['_id'] ?? '',
                    title: item['title'] ?? 'No Title',
                    description: item['description'] ?? 'No Description',
                    postedDate: DateTime.tryParse(item['date'] ?? '') ?? DateTime.now(),
                    content: item['contents'] ?? 'No Content Available',
                  ),
                ),
              );
            },
            child: _customBox(
              item['title'] ?? 'No Title',
              item['description'] ?? 'No Description',
              item['date'] ?? 'No Date',
            ),
          );
        },
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
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, required VoidCallback onPressed}) {
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
    );
  }
}
