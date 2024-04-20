import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excessfood/screen/agent/add_proof.dart';
import 'package:excessfood/screen/agent/view_images.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class OrderedFoodDetails extends StatefulWidget {
  final Map<String, dynamic> food;

  const OrderedFoodDetails({Key? key, required this.food}) : super(key: key);

  @override
  _OrderedFoodDetailsState createState() => _OrderedFoodDetailsState();
}

class _OrderedFoodDetailsState extends State<OrderedFoodDetails> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    print("widget.food['pickupBy']");
    print(widget.food['pickupBy']);
    print("widget.food['pickupBy']");

    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Order'),
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
                const SizedBox(height: 16),
                Text(
                  widget.food['foodName'],
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.food['location'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.food['description'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 215, 215, 215),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: widget.food['pickupBy'] != ''
                      ? FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.food['pickupBy'])
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else {
                              print(widget.food['pickupBy']);
                              final snap =
                                  snapshot.data!.data() as Map<String, dynamic>;

                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CircleAvatar(
                                              radius: 20,
                                              child: ClipOval(
                                                child:
                                                    FadeInImage.memoryNetwork(
                                                  placeholder:
                                                      kTransparentImage,
                                                  image: snap['photourl'],
                                                  fit: BoxFit.cover,
                                                  width: 36,
                                                  height: 36,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(snap['username']),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 100,
                                    child: Image(
                                        image:
                                            AssetImage('assets/delivery.gif')),
                                  ),
                                  widget.food['verified'] == "rejected"
                                      ? const Text(
                                          'Food failed quality test. Check other foods.')
                                      : const Text(
                                          'Picked your order. It will reach you shortly.'),
                                  const SizedBox(height: 5),
                                  Text('📞+91 ${snap["phone"]}'),
                                ],
                              );
                            }
                          })
                      : const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                                '⏳waiting for someone to pickup your order'),
                          ),
                        ),
                ),
                widget.food.containsKey('mainFoodimageUrl')
                    ? ViewImages(
                        image1: widget.food['mainFoodimageUrl'],
                        image2: widget.food['subPics'],
                      )
                    : Container(
                        child: const Text(''),
                      )
              ],
            ),
          ),
        ),
        bottomNavigationBar: !widget.food.containsKey('mainFoodimageUrl')
            ? widget.food['verified'] == "rejected"
                ? const SizedBox(
                    height: 20,
                    child: Center(child: Text('')),
                  )
                : Container(
                    padding: const EdgeInsets.all(10),
                    height: 80,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddProof(
                              foodId: widget.food['postId'],
                            ),
                          ),
                        );
                      },
                      child: const Center(
                        child: Text(
                          'Add photos',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  )
            : const SizedBox(
                height: 20,
                child: Center(child: Text('')),
              ));
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
