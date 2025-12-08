import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/auth_storage.dart';

class ApiService {
  static const baseUrl = 'https://devmindssmartsmsappapi.devminds.co.in';

  static Future<String?> login(String phone, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone_number': phone, 'password': password}),

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

  static Future<bool> updateUser(
      String name, String phone, String email, String vehicle) async {
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

}
