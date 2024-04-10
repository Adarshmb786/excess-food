// ignore_for_file: prefer_const_constructors

import 'package:excessfood/screen/delivery/view_orders.dart';
import 'package:excessfood/screen/delivery/view_posts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quds_popup_menu/quds_popup_menu.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

class DeliveryIndexPage extends StatefulWidget {
  const DeliveryIndexPage({super.key});

  @override
  State<DeliveryIndexPage> createState() => _DeliveryIndexPageState();
}

class _DeliveryIndexPageState extends State<DeliveryIndexPage> {
  int index = 0;
  List<dynamic> tabs = [
    ViewFoodOrdersForDelivery(),
    ViewFoodOrdersDelivery(),
  ];

  List<QudsPopupMenuBase> getMenuItems() {
    return [
      QudsPopupMenuSection(
          titleText: 'settings',
          leading: Icon(
            Icons.settings,
            size: 40,
          ),
          subItems: [
            QudsPopupMenuItem(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                })
          ]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: WaterDropNavBar(
        backgroundColor: Colors.white,
        onItemSelected: (value) {
          setState(() {
            index = value;
          });
        },
        selectedIndex: index,
        barItems: [
          BarItem(
              filledIcon: Icons.pending_actions,
              outlinedIcon: Icons.pending_actions_outlined),
          BarItem(
            filledIcon: Icons.directions_bike_rounded,
            outlinedIcon: Icons.directions_bike_outlined,
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text('Hello Delivery👋'),
        actions: [
          QudsPopupButton(
              tooltip: 'T', items: getMenuItems(), child: Icon(Icons.menu)),
        ],
      ),
      body: SafeArea(
        child: tabs[index],
      ),
    );
  }
}
