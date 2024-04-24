// ignore_for_file: prefer_const_constructors, body_might_complete_normally_nullable, prefer_const_literals_to_create_immutables

import 'package:excessfood/screen/event/upload_food.dart';
import 'package:excessfood/screen/event/view_posts.dart';
import 'package:excessfood/screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quds_popup_menu/quds_popup_menu.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

class UserIndexPage extends StatefulWidget {
  const UserIndexPage({super.key});

  @override
  State<UserIndexPage> createState() => _UserIndexPageState();
}

class _UserIndexPageState extends State<UserIndexPage> {
  int index = 0;
  List<dynamic> tabs = [
    UploadFood(),
    ViewFoodOrders(),
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
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => loginscreen()));
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
            filledIcon: Icons.add,
            outlinedIcon: Icons.add,
          ),
          BarItem(
              filledIcon: Icons.fastfood,
              outlinedIcon: Icons.fastfood_outlined),
        ],
      ),
      appBar: AppBar(
        title: const Text('Hello Event👋'),
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
