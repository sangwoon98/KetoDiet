import 'package:flutter/material.dart';

import '../modules/app_bar.dart';

class ChallengePage extends StatefulWidget {
  final Map<String, String>? params;

  const ChallengePage({super.key, this.params});

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  @override
  Widget build(BuildContext context) {
    if (widget.params != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushReplacementNamed(context, '/challenge');
      });
    }

    return Scaffold(
      appBar: CustomAppBar.widget(context),
      body: const Center(
        child: Text('키토 챌린지'),
      ),
    );
  }
}
