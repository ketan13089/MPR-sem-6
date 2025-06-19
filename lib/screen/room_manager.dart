// room_manager.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoomManager {
  static const String _baseUrl = "http://192.168.236.166:8000";
  static Future<String> createRoom() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/create-room'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['room_id'];
      }
      throw Exception('Failed to create room: ${response.statusCode}');
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  static Future<bool> validateRoom(String roomId) async {
    try {
      // Add your room validation logic here if needed
      return true; // For now assuming all room IDs are valid
    } catch (e) {
      throw Exception('Validation error: $e');
    }
  }
}