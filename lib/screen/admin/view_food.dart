import 'package:excessfood/screen/agent/view_images.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminEvaluateFoodPage extends StatefulWidget {
  final Map<String, dynamic> food;

  const AdminEvaluateFoodPage({Key? key, required this.food}) : super(key: key);

  @override
  _AdminEvaluateFoodPageState createState() => _AdminEvaluateFoodPageState();
}

class _AdminEvaluateFoodPageState extends State<AdminEvaluateFoodPage> {
  final user = FirebaseAuth.instance.currentUser!;

  bool _isloading = false;

  Future<void> orderFood() async {
    setState(() {
      _isloading = true;
    });
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('foods').doc(widget.food['postId']).update({
        'status': 'ordered',
        'orderedBy': user.uid,
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
        title: Text('View Food'),
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
              SizedBox(height: 10),
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
                        SizedBox(
                          height: 10,
                        ),
                        widget.food.containsKey('mainFoodimageUrl')
                            ? Text(
                                'Proof',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : Text(''),
                        widget.food.containsKey('mainFoodimageUrl')
                            ? ViewImages(
                                image1: widget.food['mainFoodimageUrl'],
                                image2: widget.food['subPics'],
                              )
                            : Container(
                                child: const Text(''),
                              )
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
