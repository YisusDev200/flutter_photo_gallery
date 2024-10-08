import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert'; 

class UpdatePhotoService {
  final String apiUrl = dotenv.env['API_URL'] ?? "";

  Future<void> updatePhoto(int id, String name, String description, List<int>? photoFileBytes) async {
    try {
      final url = Uri.parse('$apiUrl/$id');

      var request = http.MultipartRequest('PUT', url);
      
      request.fields['name'] = name;
      request.fields['description'] = description;

      if (photoFileBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'photo', 
          photoFileBytes, 
          filename: 'updated_photo_$id.png',
        ));
      }

      final response = await request.send();

      if (response.statusCode != 200) { // 200 es éxito
        throw Exception('Failed to update photo: ${response.statusCode}');
      }

      print('Photo updated successfully: $id');
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Failed to update photo: $e');
    }
  }
}
