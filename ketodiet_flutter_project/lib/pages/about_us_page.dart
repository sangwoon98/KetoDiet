import 'package:flutter/material.dart';

import '../modules/app_bar.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
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
