import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PhotoService {
  final String apiUrl = dotenv.env['API_URL'] ?? "";

  Future<List<dynamic>> fetchPhotos() async {
    try {
      var result = await http.get(Uri.parse(apiUrl));
      if (result.statusCode == 200) {
        return json.decode(result.body);
      } else {
        throw Exception('Error al cargar fotos');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
