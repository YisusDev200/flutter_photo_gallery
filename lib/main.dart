import 'package:flutter/material.dart';
import 'package:gallery_photos/screens/gallery_photos.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sincronización SQLite & MySQL',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GalleryPhotos(),
    );
  }
}
