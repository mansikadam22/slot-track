import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/auth_storage.dart';

class ApiService {
  static const baseUrl = 'https://devmindssmartsmsappapi.devminds.co.in';

  static Future<String?> login(String phone, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone_no': phone, 'password': password}),

    );
    print("Response: ${response.body}");
    print("Status: ${response.statusCode}");


    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await AuthStorage.saveToken(data['token']);
      return data['token'];

    } else {
      return null;
    }


  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final token = await AuthStorage.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Your old API returns LIST, so take first user
        if (data is List && data.isNotEmpty) {
          return data[0];
        }
        return null;
      } else {
        print("Failed to load profile: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error in getUserProfile: $e");
      return null;
    }
  }

  static Future<bool> updateUser(String name, String phone, String email, String vehicle) async {
    try {
      final token = await AuthStorage.getToken();
      if (token == null) return false;

      final response = await http.patch(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "name": name,
          "phone_no": phone,
          "email_id": email,
          "vehicle_no": vehicle,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Update error: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/users/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("API Error: $e");
      return null;
    }
  }

  static Future<List> getNotifications() async {
    final url = Uri.parse("$baseUrl/notifications");  // or your real path
    print("CALLING: $url");

    final response = await http.get(url);
    print("STATUS CODE: ${response.statusCode}");
    print("BODY RAW: ${response.body}");

    try {
      final json = jsonDecode(response.body);

      print("DECODED JSON: $json");

      if (json is List) return json;
      if (json is Map && json["data"] is List) return json["data"];

      return [];
    } catch (e) {
      print("ERROR DECODING: $e");
      return [];
    }
  }


  static Future<bool> addNotification({
    required String name,
    required String message,
    required int createdBy,
    required String startDate, // ISO string "2025-12-01T00:00:00Z"
    required String endDate,
  }) async {
    final token = await AuthStorage.getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'message': message,
        'created_by': createdBy,
        'start_date': startDate,
        'end_date': endDate,
      }),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  static Future<bool> updateNotification(int id, Map<String, dynamic> patchBody) async {
    final token = await AuthStorage.getToken();
    if (token == null) return false;

    final response = await http.patch(
      Uri.parse('$baseUrl/notifications/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(patchBody),
    );

    return response.statusCode == 200;
  }

  static Future<bool> deleteNotification(int id) async {
    final token = await AuthStorage.getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }

  static Future<Map?> getNotificationById(int id) async {
    try {
      final token = await AuthStorage.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map) return data;
      }
      return null;
    } catch (e) {
      print('Error getNotificationById: $e');
      return null;
    }
  }
}
