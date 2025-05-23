import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class _ImageWrapper {
  Uint8List bytes = Uint8List(0);
  bool imageLoaded = false;
}

class MyImagePicker extends StatefulWidget {
  final _ImageWrapper _valueWrapper = _ImageWrapper();
  Future<Uint8List> get getImageBytes async => _valueWrapper.bytes;

  @override
  MyImagePickerState createState() => MyImagePickerState();
}

class MyImagePickerState extends State<MyImagePicker> {
  File? _image;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() async {
        _image = File(pickedFile.path);
        widget._valueWrapper.bytes = await _image!.readAsBytes();
        widget._valueWrapper.imageLoaded = true;
      });
    }
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Cámara'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          if (_image != null)
            Image.file(_image!, width: 150, height: 150, fit: BoxFit.cover),
          ElevatedButton.icon(
            onPressed: _showOptions,
            icon: Icon(Icons.image),
            label: Text('Seleccionar imagen'),
          ),
        ],
      ),
    );
  }
}
