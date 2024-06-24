import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class _WebSocketClient {
  final TextEditingController _controller = TextEditingController();
  final _channel = WebSocketChannel.connect(
    Uri.parse('ws://localhost:9000'),
  );

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _channel.sink.add(_controller.text);
    }
  }

  void startListening() {
    while (true) {
      var heared = false;
      if (heared == true) {
        //
      }
    }
  }
}
