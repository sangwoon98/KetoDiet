import 'package:flutter/material.dart';

import '../modules/app_bar.dart';

class InfoPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const InfoPage(this.params, {super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.params.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushReplacementNamed(context, '/info');
      });
    }

    return Scaffold(
      appBar: CustomAppBar.widget(context),
      body: const Center(
        child: Text('키토제닉이란?'),
      ),
    );
  }
}
