import 'dart:convert';
import 'package:http/http.dart' as http;

class RouteService {
  static Future<List<Map<String, dynamic>>> fetchWaypoints() async {
    final url = Uri.parse('http://10.85.82.166:8000/get-route/?city=Sibiu');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load waypoints');
    }
  }
}
