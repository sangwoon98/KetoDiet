import 'package:flutter/material.dart';

import '../modules/layout.dart';

class MainPage extends StatefulWidget {
  final Map<String, dynamic> query;

  const MainPage(this.query, {super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    if (widget.query.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold.scaffold(
      context: context,
      body: const Center(child: Text('메인 페이지')),
    );
  }
}
