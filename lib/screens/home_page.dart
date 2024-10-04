import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gallery_photos/screens/user_list_widget.dart';
import 'package:image_picker/image_picker.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImage; // Aquí almacenaremos la imagen seleccionada

  final SyncService _syncService = SyncService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  // Controladores de los campos de texto
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  // Función para seleccionar una imagen
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes(); // Convertir la imagen en bytes
      final compressedBytes = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 800,
        minHeight: 800,
        quality: 80,
      );

      setState(() {
        _selectedImage = compressedBytes; // Guardar la imagen comprimida
      });
    }
  }

  // Función para guardar los datos en SQLite
  Future<void> _savePhoto() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage != null) {
        // Insertar en SQLite
        await _dbHelper.insertPhoto({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'photo': _selectedImage, // Agregar la imagen en bytes
        });

        // Limpiar los campos del formulario
        _nameController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedImage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo saved locally with image')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select an image')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Synchronization'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mostrar imagen seleccionada
            if (_selectedImage != null)
              Image.memory(_selectedImage!, height: 100, width: 100),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Select Image'),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  PhotoListWidget(),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _savePhoto,
                    child: Text('Save to SQLite'),
                  ),
                ],
              ),
            ),
            // Botón de sincronización con MySQL
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                await _syncService.syncWithMySQL(context);
              },
              child: Text('Sync with MySQL'),
            ),
          ],
        ),
      ),
    );
  }
}