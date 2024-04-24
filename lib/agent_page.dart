// ignore_for_file: prefer_const_constructors

import 'package:excessfood/screen/agent/view_orders.dart';
import 'package:excessfood/screen/agent/view_posts.dart';
import 'package:excessfood/screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quds_popup_menu/quds_popup_menu.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';

class AgentIndexPage extends StatefulWidget {
  const AgentIndexPage({super.key});

  @override
  State<AgentIndexPage> createState() => _AgentIndexPageState();
}

class _AgentIndexPageState extends State<AgentIndexPage> {
  int index = 0;
  List<dynamic> tabs = [
    ViewAvailableFoods(),
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
              filledIcon: Icons.fastfood,
              outlinedIcon: Icons.fastfood_outlined),
          BarItem(
            filledIcon: CupertinoIcons.bag_fill,
            outlinedIcon: CupertinoIcons.bag,
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text('Hello Agent👋'),
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
