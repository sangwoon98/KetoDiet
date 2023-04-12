import 'package:flutter/material.dart';

import '../modules/app_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.widget(context),
      body: const Center(
        child: Text('MainPage'),
      ),
    );
  }
}
