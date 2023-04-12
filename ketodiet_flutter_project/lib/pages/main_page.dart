import 'package:flutter/material.dart';

import '../modules/app_bar.dart';

class MainPage extends StatefulWidget {
  final Map<String, String>? params;

  const MainPage({super.key, this.params});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.params != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushReplacementNamed(context, '/');
      });
    }

    return Scaffold(
      appBar: CustomAppBar.widget(context),
      body: const Center(
        child: Text('MainPage'),
      ),
    );
  }
}
