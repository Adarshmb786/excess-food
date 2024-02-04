import 'package:excessfood/admin_page.dart';
import 'package:excessfood/delivery_page.dart';
import 'package:excessfood/foodsecurity_page.dart';
import 'package:excessfood/user_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import 'auth/user_provider.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userModel = userProvider.userModel;
    if (userModel!.type == "admin") {
      return AdminIndexPage();
    } else {
      if (userModel.type == "foodsecurity") {
        return FoodSecIndexPage();
      } else {
        if (userModel.type == "delivery") {
          return DeliveryIndexPage();
        } else {
          return UserIndexPage();
        }
      }
    }
  }
}
