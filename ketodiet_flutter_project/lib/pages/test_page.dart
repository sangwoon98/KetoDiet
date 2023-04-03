import 'package:flutter/material.dart';

import '../modules/app_bar.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: const [],
          ),
        ),
      ),
    );
  }
}

Widget testModule(widget) {
  return SizedBox(
    width: 500.0,
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: widget,
    ),
  );
}
