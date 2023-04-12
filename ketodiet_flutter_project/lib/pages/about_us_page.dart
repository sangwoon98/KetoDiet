import 'package:flutter/material.dart';

import '../modules/app_bar.dart';

class AboutUsPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const AboutUsPage(this.params, {super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.params.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushReplacementNamed(context, '/about-us');
      });
    }

    return Scaffold(
      appBar: CustomAppBar.widget(context),
      body: const Center(
        child: Text('우리는 누구인가요?'),
      ),
    );
  }
}
