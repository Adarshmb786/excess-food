import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:excessfood/auth/storage_methods.dart';
import 'package:uuid/uuid.dart';

class fireStoreMethods {
  final FirebaseFirestore _firebasefirestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!;

  Future<String> uploadPost(
    String discription,
    Uint8List file,
    String uid,
    String username,
    String profileimage,
  ) async {
    String res = "someerror occured";
    try {
      String postID = const Uuid().v1();
      print(postID);
      String posturl =
          await StorageMethods().uploadImageStorage('posts', file, true);

      res = 'succes';
    } catch (error) {
      res = error.toString();
    }
    return res;
  }

  Future<void> deletepost(String postID) async {
    try {
      await _firebasefirestore.collection('post').doc(postID).delete();
    } catch (e) {}
  }
}
