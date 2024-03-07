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

class PreviewPage extends StatefulWidget {
  final Map<String, dynamic> food;

  const PreviewPage({super.key, required this.food});

  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final user = FirebaseAuth.instance.currentUser!;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  UploadTask? task;
  String urlDownload = '';

  Future<void> _getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  bool _isloading = false;

  Future PreviewPage() async {
    setState(() {
      _isloading = true;
    });
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    if (_image != null) {
      final fileMain = File(_image!.path);
      String postId = const Uuid().v1();
      final destination = 'foods/$postId';

      task = FirebaseApi.uploadFile(destination, fileMain);
      setState(() {});

      final snapshot = await task!.whenComplete(() {});
      urlDownload = await snapshot.ref.getDownloadURL();
    }
    try {
      print("_titleController.text");
      print(_titleController.text);
      print("_titleController.text");
      await firestore.collection('foods').doc(widget.food['postId']).update({
        'postId': widget.food['postId'],
        'imageUrl': urlDownload != '' ? urlDownload : widget.food['imageUrl'],
        'userId': user.uid,
        'foodName': _titleController.text != ''
            ? _titleController.text
            : widget.food['foodName'],
        'location': _locationController.text != ''
            ? _locationController.text
            : widget.food['location'],
        'description': _descriptionController.text != ''
            ? _descriptionController.text
            : widget.food['description'],
        // 'time': DateTime.now(),
        'status': 'Not verified',
      });
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      _isloading = false;
    });
  }

  Future<void> _deleteFood() async {
    setState(() {
      _isloading = true;
    });

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('foods').doc(widget.food['postId']).delete();
    } catch (e) {
      print(e.toString());
      setState(() {
        _isloading = false;
      });
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: "Error. Unable to delete food",
        ),
      );
      return;
    }

    setState(() {
      _isloading = false;
    });

    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(
        message: "Success. Food is deleted",
      ),
    );
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
                      ? Image.file(
                          _image!,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          widget.food['imageUrl'],
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        )),
              SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: widget.food['foodName'],
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(hintText: widget.food['location']),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration:
                    InputDecoration(hintText: widget.food['description']),
                maxLines: 3,
              ),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await PreviewPage();
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.success(
                          message: "Success. Food is uploaded",
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    child: _isloading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          )
                        : Center(
                            child: const Text(
                              'Update food',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _deleteFood();
                    },
                    child: _isloading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          )
                        : Center(
                            child: const Text(
                              'Delete Food',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                  ),
                ],
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
