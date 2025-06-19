// Add these dependencies to your pubspec.yaml:
// dependencies:
//   web_socket_channel: ^2.4.0
//   http: ^1.1.0

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class HandGestureWidget extends StatefulWidget {
  @override
  _HandGestureWidgetState createState() => _HandGestureWidgetState();
}

class _HandGestureWidgetState extends State<HandGestureWidget> {
  final String serverIp = "192.168.1.3"; // Replace with your server IP address
  final int serverPort = 8000;

  WebSocketChannel? _channel;
  Map<String, dynamic> _gestureData = {};
  bool _isConnected = false;
  bool _isRecognitionRunning = false;

  @override
  void initState() {
    super.initState();
    _checkRecognitionStatus();
  }

  Future<void> _startRecognition() async {
    final response = await http.get(Uri.parse('http://$serverIp:$serverPort/start'));
    if (response.statusCode == 200) {
      setState(() {
        _isRecognitionRunning = true;
      });
      _connectWebSocket();
    }
  }

  Future<void> _stopRecognition() async {
    await http.get(Uri.parse('http://$serverIp:$serverPort/stop'));
    setState(() {
      _isRecognitionRunning = false;
    });
    _disconnectWebSocket();
  }

  Future<void> _checkRecognitionStatus() async {
    try {
      final response = await http.get(Uri.parse('http://$serverIp:$serverPort/status'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isRecognitionRunning = data['status'] == 'running';
        });

        if (_isRecognitionRunning) {
          _connectWebSocket();
        }
      }
    } catch (e) {
      print('Error checking status: $e');
    }
  }

  void _connectWebSocket() {
    _disconnectWebSocket(); // Close existing connection if any

    _channel = WebSocketChannel.connect(
      Uri.parse('ws://$serverIp:$serverPort/ws'),
    );

    setState(() {
      _isConnected = true;
    });

    _channel!.stream.listen(
          (message) {
        setState(() {
          _gestureData = jsonDecode(message);
        });
      },
      onError: (error) {
        print('WebSocket error: $error');
        _disconnectWebSocket();
      },
      onDone: () {
        print('WebSocket connection closed');
        _disconnectWebSocket();
      },
    );
  }

  void _disconnectWebSocket() {
    _channel?.sink.close();
    setState(() {
      _isConnected = false;
    });
  }

  @override
  void dispose() {
    _disconnectWebSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hand Gesture Recognition'),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: Text('Recognition Status'),
            value: _isRecognitionRunning,
            onChanged: (value) {
              if (value) {
                _startRecognition();
              } else {
                _stopRecognition();
              }
            },
          ),
          Divider(),
          Expanded(
            child: _isConnected
                ? ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                ListTile(
                  title: Text('Connection Status'),
                  trailing: Text(_isConnected ? 'Connected' : 'Disconnected'),
                ),
                ListTile(
                  title: Text('Hand Sign'),
                  trailing: Text(_gestureData['hand_sign'] ?? 'None'),
                ),
                ListTile(
                  title: Text('Finger Gesture'),
                  trailing: Text(_gestureData['finger_gesture'] ?? 'None'),
                ),
                ListTile(
                  title: Text('Handedness'),
                  trailing: Text(_gestureData['handedness'] ?? 'None'),
                ),
                ListTile(
                  title: Text('FPS'),
                  trailing: Text('${_gestureData['fps'] ?? 0}'),
                ),
                if (_gestureData['hand_position'] != null &&
                    _gestureData['hand_position'].isNotEmpty)
                  Container(
                    height: 300,
                    child: CustomPaint(
                      painter: HandPainter(_gestureData['hand_position']),
                      size: Size.infinite,
                    ),
                  ),
              ],
            )
                : Center(
              child: Text('Not connected to the recognition server'),
            ),
          ),
        ],
      ),
    );
  }
}

// A simple custom painter to visualize the hand landmarks
class HandPainter extends CustomPainter {
  final List<dynamic> landmarks;

  HandPainter(this.landmarks);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Scale landmarks to fit the canvas
    double maxX = 0;
    double maxY = 0;
    for (var point in landmarks) {
      maxX = point[0] > maxX ? point[0].toDouble() : maxX;
      maxY = point[1] > maxY ? point[1].toDouble() : maxY;
    }

    double scaleX = size.width / (maxX > 0 ? maxX : 1);
    double scaleY = size.height / (maxY > 0 ? maxY : 1);
    double scale = scaleX < scaleY ? scaleX : scaleY;

    // Draw the landmarks
    for (var point in landmarks) {
      double x = point[0].toDouble() * scale;
      double y = point[1].toDouble() * scale;
      canvas.drawCircle(Offset(x, y), 5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}