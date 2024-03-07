// ignore_for_file: prefer_const_constructors, prefer_final_fields, use_key_in_widget_constructors, avoid_print, library_private_types_in_public_api

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class EvaluateFoodPage extends StatefulWidget {
  final Map<String, dynamic> food;

  const EvaluateFoodPage({super.key, required this.food});

  @override
  _EvaluateFoodPageState createState() => _EvaluateFoodPageState();
}

class _EvaluateFoodPageState extends State<EvaluateFoodPage> {
  final user = FirebaseAuth.instance.currentUser!;

  bool _isloading = false;

  Future ApproveFood() async {
    setState(() {
      _isloading = true;
    });
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('foods').doc(widget.food['postId']).update({
        'status': 'pickup',
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
        title: Text('Delivery Pickup Confirmation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                widget.food['imageUrl'],
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),
            Text(
              widget.food['foodName'],
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              widget.food['location'],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            Text(
              widget.food['description'],
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await ApproveFood();
                showTopSnackBar(
                  Overlay.of(context),
                  CustomSnackBar.success(
                    message: "Success. Food is approved",
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
                        'Take Order',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
            ),
          ],
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
