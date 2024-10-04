import 'package:flutter/material.dart';
import 'package:gallery_photos/screens/home_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gallery_photos/services/photo_service.dart';

class GalleryPhotos extends StatefulWidget {
  const GalleryPhotos({super.key});
  @override
  _GalleryPhotosState createState() => _GalleryPhotosState();
}

class _GalleryPhotosState extends State<GalleryPhotos> {
  PhotoService photoService = PhotoService(); 
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
      var photos = await photoService.fetchPhotos(); // Usa el servicio
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
                        child: Text('Recargar'), // Botón para recargar
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
                    child: Text('Recargar'), // Botón para recargar si no hay conexión
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
