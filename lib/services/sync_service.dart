import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'database_helper.dart';
import 'package:flutter/material.dart';

class SyncService {
  final String apiUrl = "http://192.168.1.65:3000/api/photos";

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
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['name'] = photo['name'];
      request.fields['description'] = photo['description'];

      // Añadir la imagen como archivo en la solicitud multipart/form-data
      if (photo['photo'] != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'photo',
          photo['photo'],
          filename: 'photo_${photo['id']}.png',
        ));
      }

      try {
        final response = await request.send();

        if (response.statusCode == 201) {
          print('Photo synchronized: ${photo['name']}');
        } else {
          print('Error synchronizing: ${response.statusCode}');
          syncSuccess = false; // Si falla la sincronización, marcamos syncSuccess como falso
        }
      } catch (e) {
        print('Network error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error while trying to synchronize')),
        );
        syncSuccess = false; // Si hay un error de red, también marcamos syncSuccess como falso
      }
    }

    // Solo eliminar los datos locales si la sincronización fue exitosa para todas las fotos
    if (syncSuccess && photos.isNotEmpty) {
      await dbHelper.deleteAllPhotos();
      print('All photos have been deleted from SQLite.');
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