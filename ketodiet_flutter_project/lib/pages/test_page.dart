import 'package:flutter/material.dart';

import '../modules/app_bar.dart';
import '../modules/handle.dart';

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
    return Scaffold(
      appBar: CustomAppBar.widget(context),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              testModule(button(context)),
            ],
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

Widget oAuthTokenText() {
  return StreamBuilder(
    stream: accountManager.oAuthTokenStreamController.stream,
    builder: (context, snapshot) {
      return Text('OAuthToken is:\n${accountManager.get().oAuthToken}');
    },
  );
}

Widget nameText() {
  return StreamBuilder(
    stream: accountManager.nameStreamController.stream,
    builder: (context, snapshot) {
      return Text('Name is: ${accountManager.get().name}');
    },
  );
}

Widget errors() {
  return StreamBuilder(
      stream: errorManager.streamController.stream,
      builder: (context, snapshot) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorManager.get()?.error is String ? errorManager.get()!.error : 'null'),
            Text(errorManager.get()?.file is String ? errorManager.get()!.file : 'null'),
            Text(errorManager.get()?.method is String ? errorManager.get()!.method : 'null'),
          ],
        );
      });
}

Widget button(context) {
  return ElevatedButton(
    onPressed: () async {
      Navigator.pushNamedAndRemoveUntil(context, '/community?page=1&hello=world', (_) => false);
    },
    child: const Text('발작버튼'),
  );
}
