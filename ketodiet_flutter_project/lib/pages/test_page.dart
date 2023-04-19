import 'package:flutter/material.dart';
import 'package:ketodiet_flutter_project/pages/community_page.dart';

import '../modules/app_bar.dart';

class TestPage extends StatefulWidget {
  final Map<String, dynamic> query;

  const TestPage(this.query, {super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  void initState() {
    if (widget.query.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushNamedAndRemoveUntil(context, '/test', (_) => false);
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (context.mounted) ModifyCategory.dialog(context);
    });

    return Scaffold(
      appBar: CustomAppBar.widget(context),
      body: Center(
        child: Column(
          children: const [],
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
