import 'package:flutter/material.dart';
import 'package:gallery_photos/screens/home_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gallery_photos/services/photo_service.dart';
import 'package:gallery_photos/services/delete_photo_service.dart';
import 'package:gallery_photos/screens/EditPhotoScreen.dart'; 

class GalleryPhotos extends StatefulWidget {
  const GalleryPhotos({super.key});
  @override
  _GalleryPhotosState createState() => _GalleryPhotosState();
}

class _GalleryPhotosState extends State<GalleryPhotos> {
  PhotoService photoService = PhotoService();
  DeletePhotoService deletePhotoService = DeletePhotoService();
  List<dynamic> _photos = [];
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    fetchPhotos();
  }

  Future<void> fetchPhotos() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isConnected = false;
      });
      return;
    }

    try {
      var photos = await photoService.fetchPhotos();
      setState(() {
        _photos = photos;
        _isConnected = true;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
      });
    }
  }

  Future<void> deletePhoto(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar esta foto?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await deletePhotoService.deletePhoto(id);
        setState(() {
          _photos.removeWhere((photo) => photo['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foto eliminada con éxito')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar la foto')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery Photos'),
      ),
      body: _isConnected
          ? _photos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sin fotos'),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchPhotos,
                        child: Text('Recargar'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchPhotos,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    padding: EdgeInsets.all(10),
                    itemCount: _photos.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Image.network(
                                  _photos[index]['photo'],
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                _photos[index]['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _photos[index]['description'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditPhotoScreen(
                                            photoId: _photos[index]['id'],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      deletePhoto(_photos[index]['id']);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No Internet connection'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: fetchPhotos,
                    child: Text('Recargar'),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
