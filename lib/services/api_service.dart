import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String _baseUrl = 'https://newsapi.org/v2/top-headlines';
  static const String _apiKey = '0438d44879d74d84b9621ce8685a2d5d'; // استبدل بمفتاحك

  Future<List<dynamic>> fetchNews() async {
    final response = await http.get(Uri.parse('$_baseUrl?country=us&apiKey=$_apiKey'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['articles'];
    } else {
      throw Exception('Failed to load news');
    }
  }
}