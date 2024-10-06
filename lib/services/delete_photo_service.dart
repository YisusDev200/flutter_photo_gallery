import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DeletePhotoService {
  final String apiUrl = dotenv.env['API_URL'] ?? "";

  Future<void> deletePhoto(int id) async {
    try {
      // Asegúrate de que la URL base este correcta 
      final url = Uri.parse('$apiUrl/$id'); // 

      final response = await http.delete(url);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 204) { // 204 es el código de respuesta para eliminación exitosa sin contenido
        throw Exception('Failed to delete photo: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Failed to delete photo: $e');
    }
  }
}
