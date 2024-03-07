import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excessfood/screen/safety/orders_box.dart';
import 'package:excessfood/utils/post_box.dart';
import 'package:flutter/material.dart';

class ViewUnverifiedFoodOrders extends StatelessWidget {
  const ViewUnverifiedFoodOrders({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final userProvider = Provider.of<UserProvider>(context);
    // final userModel = userProvider.userModel;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('foods')
            .where('verified', isEqualTo: 'not verified')
            .snapshots(),
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
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No orders found.'),
            );
          } else {
            final bookings = snapshot.data!.docs;
            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (BuildContext context, int index) {
                final booking = bookings[index].data();
                return SafetyOrdersBox(
                  food: booking,
                );
              },
            );
          }
        },
      ),
    );
  }
}
