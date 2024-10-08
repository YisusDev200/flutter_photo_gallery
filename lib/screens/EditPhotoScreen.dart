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
        title: Text('Editar Foto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre'),
                onSaved: (value) {
                  _name = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Descripción'),
                onSaved: (value) {
                  _description = value ?? '';
                },
              ),
              SizedBox(height: 20),
              _imageFile != null
                  ? Image.file(
                      _imageFile!,
                      height: 200,
                    )
                  : TextButton.icon(
                      icon: Icon(Icons.photo),
                      label: Text('Seleccionar imagen'),
                      onPressed: _pickImage,
                    ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Guardar'),
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
