// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excessfood/screen/safety/evaluate_post.dart';
import 'package:excessfood/utils/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class OrdersBoxDeliveryDetails extends StatelessWidget {
  OrdersBoxDeliveryDetails({super.key, required this.food});

  final Map<String, dynamic> food;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    String name = food['userId'];
    String location = food['location'];
    String imageurl = food['imageUrl'];
    String description = food['description'];
    CollectionReference users = _firestore.collection('users');
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(name).get(),
      builder: (((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center();
        }
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> snap =
              snapshot.data!.data() as Map<String, dynamic>;

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EvaluateFoodPage(
                    food: food,
                  ),
                ),
              );
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(255, 236, 236, 236),
                        spreadRadius: 3,
                        blurRadius: 4,
                      )
                    ]),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                child: ClipOval(
                                  child: FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: snap['photourl'],
                                    fit: BoxFit.cover,
                                    width: 36,
                                    height: 36,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(snap['username']),
                                  Text(
                                    location,
                                    style: TextStyle(
                                      color: Colors.black38,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        height: 400,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            image: imageurl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(food['foodName']),
                              Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: food['verified'] == 'verified'
                                      ? Image(
                                          image:
                                              AssetImage('assets/shield.png'),
                                        )
                                      : food['verified'] == 'rejected'
                                          ? Container(
                                              height: 30,
                                              child: Image(
                                                image: AssetImage(
                                                    'assets/reject.png'),
                                              ),
                                            )
                                          : Image(
                                              image: AssetImage(
                                                  'assets/warning.png'),
                                            )),
                              Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: food['verified'] == 'rejected'
                                        ? Colors.redAccent[700]
                                        : Colors.greenAccent[700],
                                  ),
                                  margin: const EdgeInsets.only(left: 8.0),
                                  child: food['verified'] == 'rejected'
                                      ? Text(food['verified'])
                                      : Text(food['status'])),
                            ],
                          ),
                          ExpandableShowMoreWidget(
                            text: description,
                            height: 80,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Address'),
                      Text("${food['address']}"),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Ordered By 🛒'),
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(food['orderedBy'])
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData ||
                              snapshot.data == null) {
                            return Text('No data found');
                          } else {
                            final userData = snapshot.data!;
                            final phoneNumber =
                                userData['phone'] ?? 'No phone number';
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
                            .doc(food['userId'])
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData ||
                              snapshot.data == null) {
                            return Text('No data found');
                          } else {
                            final userData = snapshot.data!;
                            final phoneNumber =
                                userData['phone'] ?? 'No phone number';
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
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return CircularProgressIndicator();
      })),
    );
  }
}
