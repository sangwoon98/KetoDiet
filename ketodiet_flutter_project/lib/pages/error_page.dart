import 'package:flutter/material.dart';

import '../modules/handle.dart';

// TODO: ErrorPage 수정 (로직, 디자인);

class ErrorPage extends StatefulWidget {
  const ErrorPage({super.key});

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {
    ErrorArgs? errorArgs =
        ModalRoute.of(context)?.settings.arguments as ErrorArgs?;

    if (errorArgs == null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushReplacementNamed(context, '/');
      });
    } else {
      // ignore: avoid_print
      print(
          'ERROR!!!\n\nMassage: ${errorArgs.error}\n\nFrom:\n -Route: ${errorArgs.route}\n -File: ${errorArgs.file}\n -method: ${errorArgs.method}');
    }

    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.red,
          width: double.maxFinite,
          height: double.maxFinite,
        ),
      ),
    );
  }
}
