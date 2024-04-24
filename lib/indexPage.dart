import 'package:excessfood/admin_page.dart';
import 'package:excessfood/agent_page.dart';
import 'package:excessfood/delivery_page.dart';
import 'package:excessfood/foodsecurity_page.dart';
import 'package:excessfood/event_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import 'auth/user_provider.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userModel = userProvider.userModel;

    if (!mounted) return Container();

    if (userModel!.type == "admin") {
      return const AdminIndexPage();
    } else {
      if (userModel.type == "foodsecurity") {
        return const FoodSecIndexPage();
      } else {
        if (userModel.type == "delivery") {
          return const DeliveryIndexPage();
        } else {
          if (userModel.type == "agent") {
            return const AgentIndexPage();
          }
          return const UserIndexPage();
        }
      }
    }
  }
}
