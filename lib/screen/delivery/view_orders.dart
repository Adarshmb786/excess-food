import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excessfood/auth/user_provider.dart';
import 'package:excessfood/screen/delivery/view_orders_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewFoodOrdersDelivery extends StatelessWidget {
  const ViewFoodOrdersDelivery({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userModel = userProvider.userModel;
    print(userModel!.uid);
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('foods')
            .where('pickupBy', isEqualTo: userModel.uid)
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
                print(booking);
                return OrdersBoxDeliveryDetails(
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
