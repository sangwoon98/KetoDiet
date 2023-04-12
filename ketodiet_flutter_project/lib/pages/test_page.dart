import 'package:flutter/material.dart';

import '../modules/app_bar.dart';
import '../modules/handle.dart';

class TestPage extends StatefulWidget {
  final Map<String, String>? params;

  const TestPage({super.key, this.params});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.params != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushReplacementNamed(context, '/test');
      });
    }

    return Scaffold(
      appBar: CustomAppBar.widget(context),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              testModule(oAuthTokenText()),
              testModule(nameText()),
              testModule(errors()),
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
