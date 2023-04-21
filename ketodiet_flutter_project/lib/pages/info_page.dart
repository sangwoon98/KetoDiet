import 'package:flutter/material.dart';

import '../modules/layout.dart';

class InfoPage extends StatefulWidget {
  final Map<String, dynamic> query;

  const InfoPage(this.query, {super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  void initState() {
    if (widget.query.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushNamedAndRemoveUntil(context, '/info', (_) => false);
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold.scaffold(
      context: context,
      body: const Center(child: Text('키토제닉이란?')),
    );
  }
}
