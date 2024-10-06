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
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Photos in SQLite:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: _fetchPhotos, // Llamar a la función para recargar fotos
              ),
            ],
          ),
          SizedBox(height: 10),
          photos.isEmpty
              ? Text('No photos saved.') // Mensaje si no hay fotos
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index]; // Obtener cada foto
                    return ListTile(
                      leading: photo['photo'] != null
                          ? Image.memory(photo['photo'], width: 50, height: 50, fit: BoxFit.cover)
                          : Icon(Icons.photo), // Mostrar la imagen o un icono por defecto
                      title: Text('${photo['name']}'), // Mostrar el nombre
                      subtitle: Text('${photo['description']}'), // Mostrar la descripción
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Mostrar confirmación antes de eliminar
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Eliminar foto'),
                              content: Text('¿Estás seguro de que quieres eliminar esta foto?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _deletePhoto(photo['id']); // Llamar a la función para eliminar la foto
                                  },
                                  child: Text('Eliminar'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
