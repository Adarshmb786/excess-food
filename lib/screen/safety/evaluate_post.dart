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
        'verified': 'verified',
      });
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      _isloading = false;
    });
  }

  Future RejectFood() async {
    setState(() {
      _isloading = true;
    });
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('foods').doc(widget.food['postId']).update({
        'verified': 'rejected',
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
        title: Text('Food Verification Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
              SizedBox(height: 10),
              SizedBox(
                height: 10,
              ),
              Text('Address'),
              Text("${widget.food['address']}"),
              SizedBox(
                height: 10,
              ),
              Text('Ordered By 🛒'),
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.food['orderedBy'])
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Text('No data found');
                  } else {
                    final userData = snapshot.data!;
                    final phoneNumber = userData['phone'] ?? 'No phone number';
                    final username = userData['username'] ?? 'No Name';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: $username'),
                        Text(
                          '📞 ${phoneNumber}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              SizedBox(
                height: 10,
              ),
              Text('Cooked By 🧑‍🍳'),
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.food['userId'])
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Text('No data found');
                  } else {
                    final userData = snapshot.data!;
                    final phoneNumber = userData['phone'] ?? 'No phone number';
                    final username = userData['username'] ?? 'No Name';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: $username'),
                        Text(
                          '📞 ${phoneNumber}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
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
                              'Approve ✔️',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await RejectFood();
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.error(
                          message: "Success. Food is Rejected",
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
                              'Reject ❌',
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
