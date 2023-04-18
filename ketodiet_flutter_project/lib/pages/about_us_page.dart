import 'package:flutter/material.dart';

import '../modules/app_bar.dart';

class AboutUsPage extends StatefulWidget {
  final Map<String, dynamic> query;

  const AboutUsPage(this.query, {super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  @override
  void initState() {
    if (widget.query.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushNamedAndRemoveUntil(context, '/about-us', (_) => false);
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.widget(context),
      body: const Center(
        child: Text('우리는 누구인가요?'),
      ),
    );
  }
}
