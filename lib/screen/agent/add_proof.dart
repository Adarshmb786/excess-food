// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:uuid/uuid.dart';

class AddProof extends StatefulWidget {
  const AddProof({super.key, required this.foodId});
  final String foodId;

  @override
  State<AddProof> createState() => _AddProofState();
}

class _AddProofState extends State<AddProof> {
  PlatformFile? pickedFile;
  UploadTask? task;
  PlatformFile? pickedFileMain;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.first;

    setState(() {
      pickedFile = path;
      subImagesArray.add(
        pickedFile!.path!,
      );
    });
  }

  void showProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.4,
          child: AlertDialog(
            title: Text('Posting...'),
            content: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  void hideProgressDialog(
    VoidCallback hideCallback,
  ) {
    hideCallback();
  }

  bool _isloading = false;

  Future uploadHostel() async {
    setState(() {
      _isloading = true;
    });
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser!;
    final fileMain = File(pickedFileMain!.path!);
    String imageId = const Uuid().v1();
    final destination = 'photos/$imageId';

    task = FirebaseApi.uploadFile(destination, fileMain);
    setState(() {});

    final snapshot = await task!.whenComplete(() {});
    final urlDownloadMain = await snapshot.ref.getDownloadURL();
    print(urlDownloadMain);

    try {
      await firestore.collection('foods').doc(widget.foodId).update(
          {'mainFoodimageUrl': urlDownloadMain, 'time': DateTime.now()});
    } catch (e) {
      print(e.toString());
    }

    try {
      int count = 0;
      for (var x in subImagesArray) {
        final destination = 'photos/$imageId/$count';
        var file = File(x);
        task = FirebaseApi.uploadFile(destination, file);
        setState(() {});

        final snapshot = await task!.whenComplete(() {});
        final urlDownload = await snapshot.ref.getDownloadURL();
        print(urlDownload);
        try {
          await firestore.collection('foods').doc(widget.foodId).update({
            'subPics': FieldValue.arrayUnion([urlDownload])
          });
        } catch (e) {
          print(e.toString());
        }
        count += 1;
      }
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      _isloading = false;
    });
  }

  Future selectFileMain() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.first;

    setState(() {
      pickedFileMain = path;
    });
  }

  List<String> subImagesArray = [];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add photos'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: width * 0.9,
                  height: height * 0.5,
                  child: Stack(
                    children: [
                      Positioned(
                        left: width * 0.02,
                        child: Container(
                          color: const Color.fromARGB(255, 222, 222, 222),
                          width: width * 0.85,
                          height: height * 0.5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(80),
                            child: (pickedFileMain == null)
                                ? GestureDetector(
                                    onTap: selectFileMain,
                                    child: Image(
                                      fit: BoxFit.cover,
                                      image: AssetImage("assets/add_photo.png"),
                                    ),
                                  )
                                : Image.file(
                                    fit: BoxFit.cover,
                                    File(
                                      pickedFileMain!.path!,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: height * 0.15,
                          child: ListView.builder(
                            itemCount: subImagesArray.length + 1,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              print(index);
                              // print(subImagesArray[index]);
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  color:
                                      const Color.fromARGB(255, 222, 222, 222),
                                  width: width * 0.3,
                                  height: height * 0.15,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: index == subImagesArray.length
                                        ? GestureDetector(
                                            onTap: selectFile,
                                            child: Image(
                                              fit: BoxFit.cover,
                                              image: AssetImage(
                                                  'assets/add_photo.png'),
                                            ),
                                          )
                                        : Image.file(
                                            fit: BoxFit.cover,
                                            File(subImagesArray[index]),
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 10,
                  ),
                  color: Colors.white,
                  height: 80,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await uploadHostel();
                            showTopSnackBar(
                              Overlay.of(context),
                              CustomSnackBar.success(
                                message: "Success. Food is uploaded",
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.black,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: _isloading
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Add photos',
                                        style: TextStyle(color: Colors.white),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
