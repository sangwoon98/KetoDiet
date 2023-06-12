import 'package:flutter/material.dart';

import '../modules/layout.dart';

class TestPage extends StatefulWidget {
  final Map<String, dynamic> query;

  const TestPage(this.query, {super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> with TickerProviderStateMixin {
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
    return CustomScaffold.scaffold(
      context: context,
      body: const Center(child: Text('여기엔 아무것도 업슈~ 뭘 바라고 온거유?', style: TextStyle(fontSize: 32, color: Colors.red))),
    );
  }
}
