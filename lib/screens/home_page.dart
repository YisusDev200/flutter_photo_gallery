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
        title: const Text('Synchronization', style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF1A5276),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView( // Envolver el contenido en un SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mostrar imagen seleccionada
              if (_selectedImage != null)
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        _selectedImage!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image, color: Colors.white,),
                  label: const Text('Select Image', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Color(0xFF2C3E50)),
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    PhotoListWidget(),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name', prefixIcon: const Icon(Icons.person),
                      filled: true,
                      fillColor: Color(0xFFBDC3C7).withOpacity(0.5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                      ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description', 
                      prefixIcon:const Icon(Icons.description),
                      filled: true,
                      fillColor: Color(0xFFBDC3C7).withOpacity(0.5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                      ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _savePhoto,
                      icon: const Icon(Icons.save, color: Colors.white,),
                      label:const Text("Save to SQLite",style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
                      backgroundColor: Colors.green),
                    ),
                  ],
                ),
              ),
              // Botón de sincronización con MySQL
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await _syncService.syncWithMySQL(context);
                  },
                  child: const Text('Sync with MySQL', style: TextStyle(color:Colors.white)),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
                backgroundColor: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
