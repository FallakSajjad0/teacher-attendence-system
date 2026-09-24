import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  final Map<String, List<Function>> _listeners = {};

  void connect(String token) {
    if (_socket != null && _socket!.connected) return;

    _socket = io.io(
      ApiConfig.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('Socket connected');
      _listeners.forEach((event, callbacks) {
        for (final cb in callbacks) {
          _socket!.on(event, (data) => cb(data));
        }
      });
    });

    _socket!.onDisconnect((_) => debugPrint('Socket disconnected'));
    _socket!.onConnectError((err) => debugPrint('Socket connect error: $err'));
    _socket!.onError((err) => debugPrint('Socket error: $err'));
  }

  void on(String event, Function callback) {
    _listeners.putIfAbsent(event, () => []).add(callback);
    _socket?.on(event, (data) => callback(data));
  }

  void off(String event) {
    _listeners.remove(event);
    _socket?.off(event);
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _listeners.clear();
  }

  bool get isConnected => _socket?.connected ?? false;
}