import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'dart:io';
import '../services/update_photo.dart'; 

class EditPhotoScreen extends StatefulWidget {
  final int photoId; 
  const EditPhotoScreen({Key? key, required this.photoId}) : super(key: key);

  @override
  _EditPhotoScreenState createState() => _EditPhotoScreenState();
}

class _EditPhotoScreenState extends State<EditPhotoScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  File? _imageFile; 
  final ImagePicker _picker = ImagePicker(); 

  final UpdatePhotoService _updatePhotoService =
      UpdatePhotoService(); 

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Foto'),
        backgroundColor: Color(0xFF1A5276),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Editar detalles de la foto",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A5276),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre', 
                labelStyle: TextStyle(fontSize: 18), border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1A5276)),
                ),
                ),
                onSaved: (value) {
                  _name = value ?? '';
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Descripción', 
                labelStyle: TextStyle(fontSize: 18),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1A5276)),
                ),
                ),
                onSaved: (value) {
                  _description = value ?? '';
                },
              ),
              const SizedBox(height: 20),
              Center(
               child:_imageFile != null
               ?ClipRRect(
                borderRadius:BorderRadius.circular(10),
                child: Image.file(
                      _imageFile!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
               )
                  : TextButton.icon(
                      icon: const Icon(Icons.photo, color: Color(0xFF1A5276)),
                      label: const Text('Seleccionar imagen'),
                      onPressed: _pickImage,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF1A5276), textStyle: const TextStyle(fontSize: 18),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 20.0
                        ),
                        backgroundColor: const Color(0xFFE3F2FD),                        
                      ),
                    ),
              ),
              const SizedBox(height: 30),
              Center(
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A5276),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 80.0
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text('Guardar', 
                style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      List<int>? imageBytes =
          _imageFile != null ? await _imageFile!.readAsBytes() : null;

      try {
        await _updatePhotoService.updatePhoto(
            widget.photoId, _name, _description, imageBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foto actualizada con éxito')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar la foto: $e')),
        );
      }
    }
  }
}
