import 'package:flutter/material.dart';
import 'package:gallery_photos/screens/gallery_photos.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
