import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excessfood/auth/user_provider.dart';
import 'package:excessfood/screen/agent/ordered_food_details.dart';
import 'package:excessfood/utils/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class ViewFoodOrders extends StatelessWidget {
  const ViewFoodOrders({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userModel = userProvider.userModel;

    return Scaffold(
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('foods')
            .where('orderedBy', isEqualTo: userModel!.uid)
            .get(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final bookings = snapshot.data!.docs;
            List<Map<String, dynamic>> sortedBookings = [];

            for (var doc in bookings) {
              sortedBookings.add(doc.data());
            }

            sortedBookings.sort((a, b) {
              // Assuming 'time' is a timestamp field
              Timestamp aTime = a['time'];
              Timestamp bTime = b['time'];
              return bTime.compareTo(aTime); // Descending order
            });

            return SingleChildScrollView(
              child: ListView.builder(
                key: UniqueKey(),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: sortedBookings.length,
                itemBuilder: (BuildContext context, int index) {
                  final booking = sortedBookings[index];
                  return ViewOrdersPage(
                    food: booking,
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}

class ViewOrdersPage extends StatelessWidget {
  ViewOrdersPage({Key? key, required this.food}) : super(key: key);

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
              print(food);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => OrderedFoodDetails(
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
                  ],
                ),
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
                                        image: AssetImage('assets/shield.png'),
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
                                          ),
                              ),
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
                                    : Text(food['status']),
                              ),
                            ],
                          ),
                          ExpandableShowMoreWidget(
                            text: description,
                            height: 80,
                          ),
                        ],
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
