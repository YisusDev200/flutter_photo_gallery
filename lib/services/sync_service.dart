import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert'; 
import 'database_helper.dart';
import 'package:flutter/material.dart';

class SyncService {
  final String apiUrl = dotenv.env['API_URL'] ?? "";

  Future<void> syncWithMySQL(BuildContext context) async {
    final dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> photos = await dbHelper.getPhotos();

    // Verificar conexión a internet
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // No hay conexión a internet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo sincronizar porque no tienes conexión a Internet')),
      );
      return; // Salir de la función para evitar la sincronización
    }

    // Variable para rastrear si la sincronización fue exitosa para todas las fotos
    bool syncSuccess = true;

    // Si hay conexión, procedemos con la sincronización
    for (var photo in photos) {
      try {
        final checkUrl = Uri.parse('$apiUrl/${photo['id']}');
        final checkResponse = await http.get(checkUrl);

        if (checkResponse.statusCode == 200) {
          var request = http.MultipartRequest('PUT', checkUrl);
          request.fields['name'] = photo['name'];
          request.fields['description'] = photo['description'];

          if (photo['photo'] != null) {
            request.files.add(http.MultipartFile.fromBytes(
              'photo',
              photo['photo'],
              filename: 'photo_${photo['id']}.png',
            ));
          }

          final updateResponse = await request.send();

          if (updateResponse.statusCode == 200) {
            print('Photo updated: ${photo['name']}');
          } else {
            print('Error updating photo: ${updateResponse.statusCode}');
            syncSuccess = false;
          }
        } else if (checkResponse.statusCode == 404) {
          var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
          request.fields['name'] = photo['name'];
          request.fields['description'] = photo['description'];

          if (photo['photo'] != null) {
            request.files.add(http.MultipartFile.fromBytes(
              'photo',
              photo['photo'],
              filename: 'photo_${photo['id']}.png',
            ));
          }

          final response = await request.send();

          if (response.statusCode == 201) {
            print('Photo synchronized: ${photo['name']}');
          } else {
            print('Error synchronizing: ${response.statusCode}');
            syncSuccess = false;
          }
        } else {
          print('Error checking photo existence: ${checkResponse.statusCode}');
          syncSuccess = false;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error while trying to synchronize')),
        );
        syncSuccess = false;
      }
    }

    // Solo eliminar los datos locales si la sincronización fue exitosa para todas las fotos
    if (syncSuccess && photos.isNotEmpty) {
      await dbHelper.deleteAllPhotos();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Synchronization successful and local data deleted.')),
      );
    } else if (!syncSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Synchronization failed. Please try again.')),
      );
    }
  }
}