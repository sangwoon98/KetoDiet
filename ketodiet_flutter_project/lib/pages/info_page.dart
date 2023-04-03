import 'package:flutter/material.dart';

import '../modules/app_bar.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: const Center(
        child: Text('키토제닉이란?'),
      ),
    );
  }
}
