import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excessfood/auth/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class EvaluateFoodPage extends StatefulWidget {
  final Map<String, dynamic> food;

  const EvaluateFoodPage({Key? key, required this.food}) : super(key: key);

  @override
  _EvaluateFoodPageState createState() => _EvaluateFoodPageState();
}

class _EvaluateFoodPageState extends State<EvaluateFoodPage> {
  final user = FirebaseAuth.instance.currentUser!;
  bool _isLoading = false;
  TextEditingController addressController = TextEditingController();

  Future<void> orderFood(String name, String phone, String address) async {
    setState(() {
      _isLoading = true;
    });
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('foods').doc(widget.food['postId']).update({
        'status': 'ordered',
        'orderedBy': user.uid,
        'orderedPhone': phone,
        'orderedName': name,
        'address': address,
      });
      showTopSnackBar(
        Overlay.of(context)!,
        CustomSnackBar.success(
          message: "Success. Food is ordered.",
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showAddressModal(BuildContext context, String name, String phone) {
    Size size = MediaQuery.of(context).size;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: size.height * 0.6,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Enter Your Address',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    hintText: 'Enter your address...',
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (addressController.text.isEmpty) {
                      showTopSnackBar(
                        Overlay.of(context),
                        CustomSnackBar.error(
                          message: "Address need to be filled.",
                        ),
                      );
                      Navigator.of(context).pop();
                    } else {
                      await orderFood(
                        name,
                        phone,
                        addressController.text,
                      );
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userModel = userProvider.userModel;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Food'),
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
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        height: 80,
        child: ElevatedButton(
          onPressed: () async {
            print('modal');
            _showAddressModal(context, userModel!.username, userModel.phone);
            // Navigator.of(context).pop();
          },
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                )
              : Center(
                  child: const Text(
                    'Order Food',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
        ),
      ),
    );
  }
}
