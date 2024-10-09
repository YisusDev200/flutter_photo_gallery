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
        title: Text('Gallery Photos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF1A5276),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.search), color: Colors.white,),
          IconButton(onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        }, icon: Icon(Icons.add, color: Colors.white),),
        ],
      ),
      body: _isConnected
          ? _photos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sin fotos', style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fetchPhotos,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1A5276),
                        ),
                        child: Text('Recargar', style: TextStyle(color: Colors.white),),
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
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  _photos[index]['photo'],
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
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
                                    icon: Icon(Icons.edit, color: Colors.blue),
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
                                    icon: Icon(Icons.delete, color: Colors.red),
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
                  Text('No Internet connection', 
                  style: TextStyle(fontSize: 18, color: Colors.redAccent),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: fetchPhotos,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1A5276),
                    ),
                    child: Text('Recargar', style: TextStyle(color: Colors.white),),
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
        backgroundColor: Color(0xFF1A5276),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
