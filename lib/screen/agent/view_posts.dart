import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excessfood/screen/agent/orders_box.dart';
import 'package:flutter/material.dart';

class ViewAvailableFoods extends StatelessWidget {
  const ViewAvailableFoods({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('foods')
            .where('status', isEqualTo: 'available')
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
              child: Text('No Foods available.'),
            );
          } else {
            print(snapshot.data!.docs);
            final bookings = snapshot.data!.docs;
            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (BuildContext context, int index) {
                final booking = bookings[index].data();
                return OrdersBox(
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
