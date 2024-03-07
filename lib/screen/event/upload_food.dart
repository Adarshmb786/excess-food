// ignore_for_file: prefer_const_constructors, prefer_final_fields, use_key_in_widget_constructors, avoid_print, library_private_types_in_public_api

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:uuid/uuid.dart';

class UploadFood extends StatefulWidget {
  @override
  _UploadFoodState createState() => _UploadFoodState();
}

class _UploadFoodState extends State<UploadFood> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final user = FirebaseAuth.instance.currentUser!;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  UploadTask? task;

  Future<void> _getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  bool _isloading = false;

  Future uploadFood() async {
    setState(() {
      _isloading = true;
    });
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final fileMain = File(_image!.path);
    String postId = const Uuid().v1();
    final destination = 'foods/$postId';

    task = FirebaseApi.uploadFile(destination, fileMain);
    setState(() {});

    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    try {
      await firestore.collection('foods').doc(postId).set({
        'postId': postId,
        'imageUrl': urlDownload,
        'userId': user.uid,
        'foodName': _titleController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'time': DateTime.now(),
        'verified': 'not verified',
        'status': 'available',
        'orderedBy': '',
      });
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _getImage,
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _image!,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[300],
                        ),
                        height: 250,
                        width: double.infinity,
                        child: Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                    border: InputBorder.none, labelText: 'Title'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                    border: InputBorder.none, labelText: 'Location'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                    border: InputBorder.none, labelText: 'Description'),
                maxLines: 3,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  await uploadFood();
                  showTopSnackBar(
                    Overlay.of(context),
                    CustomSnackBar.success(
                      message: "Success. Food is uploaded",
                    ),
                  );
                },
                child: _isloading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : Center(
                        child: const Text(
                          'Add food 🍉',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FirebaseApi {
  static UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putFile(file);
    } on FirebaseException catch (e) {
      print(e);
    }
    return null;
  }
}
