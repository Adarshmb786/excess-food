// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class AdminIndexPage extends StatefulWidget {
  const AdminIndexPage({super.key});

  @override
  State<AdminIndexPage> createState() => _AdmiIndexnPageState();
}

class _AdmiIndexnPageState extends State<AdminIndexPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Admin Index Page')));
  }
}
