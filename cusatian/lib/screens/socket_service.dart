// socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket _socket;

  factory SocketService() => _instance;

  SocketService._internal() {
    _initializeSocket();
  }

  void _initializeSocket() {
    _socket = IO.io('http://10.0.2.2:5000', IO.OptionBuilder()
        .setTransports(['websocket'])
        .build());
    _socket.onConnect((_) {
      print('Connected to the server');
      // Request previous messages after connecting
      _socket.emit('requestPreviousMessages');
    });
    _socket.onReconnect((_) {
      print('Reconnected to the server');
      _socket.emit('requestPreviousMessages');
    });

  }

  IO.Socket get socket => _socket;
}
