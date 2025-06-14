import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class MyImagePickerInput extends StatefulWidget {
  final String? imageLabel;
  final Uint8List? initialValue;
  final void Function(Uint8List imagebytes)? onImageSelected;
  MyImagePickerInput({
    super.key,
    this.imageLabel,
    this.initialValue,
    this.onImageSelected,
  });
  @override
  MyImagePickerInputState createState() => MyImagePickerInputState();
}

class MyImagePickerInputState extends State<MyImagePickerInput> {
  File? _image;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _image!.readAsBytes().then(
          (bytes) => widget.onImageSelected?.call(bytes),
        );
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
          _image != null
              ? Image.file(_image!, width: 150, height: 150, fit: BoxFit.cover)
              : widget.initialValue != null
              ? Image.memory(widget.initialValue!)
              : SizedBox(height: 0, width: 0),
          ElevatedButton.icon(
            onPressed: _showOptions,
            icon: Icon(Icons.image),
            label: Text(widget.imageLabel ?? 'Seleccionar imagen'),
          ),
        ],
      ),
    );
  }
}

class MyImagePicker extends FormField<Uint8List?> {
  final BuildContext context;
  final void Function(Uint8List imageBytes)? onChanged;
  MyImagePicker({
    super.key,
    super.initialValue,
    super.validator,
    super.onSaved,
    this.onChanged,
    required this.context,
    bool autovalidate = false,
    String label = "Seleccionar imagen",
  }) : super(
         builder: (FormFieldState<Uint8List?> state) {
           return Padding(
             padding: EdgeInsets.all(8),
             child: Column(
               children: [
                 if (state.value != null)
                   Image.memory(
                     state.value!,
                     width: 150,
                     height: 150,
                     fit: BoxFit.cover,
                   ),
                 ElevatedButton.icon(
                   onPressed: () async {
                     var pickedImage = await _showOptions(context);
                     if (pickedImage != null) {
                       state.didChange(pickedImage);
                       onChanged?.call(pickedImage);
                     }
                   },
                   icon: Icon(Icons.image),
                   label: Text(label),
                 ),
                 if (state.hasError)
                   Padding(
                     padding: const EdgeInsets.only(top: 8.0),
                     child: Text(
                       state.errorText!,
                       style: TextStyle(color: Colors.red),
                     ),
                   ),
               ],
             ),
           );
         },
       );
}

Future<Uint8List?> _pickImage(ImageSource source) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: source);

  if (pickedFile != null) {
    var imageFile = File(pickedFile.path);
    return imageFile.readAsBytes();
  }
  return null;
}

Future<Uint8List?> _showOptions(BuildContext context) async {
  return showModalBottomSheet(
    context: context,
    builder:
        (context) => Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Galería'),
              onTap: () async {
                var imagePicked = await _pickImage(ImageSource.gallery);
                Navigator.pop(context, imagePicked);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Cámara'),
              onTap: () async {
                var imagePicked = await _pickImage(ImageSource.camera);
                Navigator.pop(context, imagePicked);
              },
            ),
          ],
        ),
  );
}
