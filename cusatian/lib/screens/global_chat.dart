import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GlobalChat extends StatefulWidget {
  const GlobalChat({super.key});

  @override
  _GlobalChatState createState() => _GlobalChatState();
}

class _GlobalChatState extends State<GlobalChat> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late IO.Socket _socket;
  String? _username;

  @override
  void initState() {
    super.initState();
    _socket = SocketService().socket;
    _initializeSocketListeners();
    _getUsername();
    _fetchPreviousMessages(); // Fetch previous messages when initializing
  }

  void _initializeSocketListeners() {
    _socket.on('newMessage', (data) {
      print('New message received: $data');
      setState(() {
        _messages.add({
          'text': data['text'],
          'username': data['username'],
          'timestamp': data['timestamp'],
          'isMe': data['username'] == _username,
        });
      });
    });
  }

  Future<void> _getUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userInfo = prefs.getString('userInfo');

    if (userInfo != null) {
      final Map<String, dynamic> responseData = jsonDecode(userInfo);
      setState(() {
        _username = responseData['username'];
      });
    } else {
      print('User not found in SharedPreferences');
    }
  }

  Future<void> _fetchPreviousMessages() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/messages')); // Replace with your API URL

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _messages.clear();
        _messages.addAll(data.map((message) => {
          'text': message['text'],
          'username': message['username'],
          'timestamp': message['timestamp'],
          'isMe': message['username'] == _username, // Determine if the message is from the current user
        }).toList());
      });
    } else {
      print('Failed to load previous messages');
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _username == null) return;

    final messageData = {
      'text': _messageController.text.trim(),
      'username': _username,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (_socket.connected) {
      _socket.emit('sendMessage', messageData);
      _messageController.clear();
    } else {
      print('Socket is not connected.');
    }
  }

  @override
  void dispose() {
    _socket.off('newMessage');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Chat'),
        backgroundColor: const Color(0xFFEC7063),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(
                  message['text'],
                  message['username'],
                  message['timestamp'],
                  message['isMe'], // Pass the isMe status
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    String message,
    String username,
    String timestamp,
    bool isMe,
  ) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.lightBlueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: TextStyle(fontWeight: FontWeight.bold, color: isMe ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 5),
            Text(
              message,
              style: TextStyle(color: isMe ? Colors.white : Colors.black, fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              timestamp,
              style: TextStyle(fontSize: 12, color: isMe ? Colors.white70 : Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: const Color(0xFFEC7063),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
