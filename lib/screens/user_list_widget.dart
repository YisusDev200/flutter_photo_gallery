import 'package:flutter/material.dart';
import 'package:gallery_photos/services/database_helper.dart';

class PhotoListWidget extends StatefulWidget {
  @override
  _PhotoListWidgetState createState() => _PhotoListWidgetState();
}

class _PhotoListWidgetState extends State<PhotoListWidget> {
  final DatabaseHelper dbHelper = DatabaseHelper(); // Crear una instancia del helper de base de datos
  List<Map<String, dynamic>> photos = []; // Lista para almacenar las fotos

  @override
  void initState() {
    super.initState();
    _fetchPhotos(); // Llamar a la función para obtener fotos al inicio
  }

  Future<void> _fetchPhotos() async {
    // Obtener fotos desde SQLite
    List<Map<String, dynamic>> photoList = await dbHelper.getPhotos();
    setState(() {
      photos = photoList; // Actualizar la lista de fotos
    });
  }

  Future<void> _deletePhoto(int id) async {
    await dbHelper.deletePhoto(id); // Eliminar la foto de la base de datos
    _fetchPhotos(); // Recargar las fotos después de la eliminación
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFBDC3C7).withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Photos in SQLite:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchPhotos,
                color: Colors.black, // Llamar a la función para recargar fotos
              ),
            ],
          ),
          const SizedBox(height: 10),
          photos.isEmpty
              ? Center(child: Text('No photos saved.', style: TextStyle(color: Colors.grey[600]))) // Mensaje si no hay fotos
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index]; // Obtener cada foto
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      child: ListTile(
                      leading: photo['photo'] != null
                      ?ClipOval(
                           child: Image.memory(photo['photo'], width: 50, height: 50, fit: BoxFit.cover),)
                          : const Icon(Icons.photo, color: Colors.grey), // Mostrar la imagen o un icono por defecto
                      title: Text('${photo['name']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ), // Mostrar el nombre
                      subtitle: Text('${photo['description']}', style: TextStyle(color: Colors.grey[700],),
                      ), // Mostrar la descripción
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Mostrar confirmación antes de eliminar
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Eliminar foto'),
                              content: const Text('¿Estás seguro de que quieres eliminar esta foto?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _deletePhoto(photo['id']); // Llamar a la función para eliminar la foto
                                  },
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                      );
                  },
                ),
        ],
      ),
    );
  }
}
