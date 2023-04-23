import 'package:flutter/material.dart';

import '../modules/layout.dart';

class ChallengePage extends StatefulWidget {
  final Map<String, dynamic> query;

  const ChallengePage(this.query, {super.key});

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  @override
  void initState() {
    if (widget.query.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushNamedAndRemoveUntil(context, '/challenge', (_) => false);
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold.scaffold(
      context: context,
      body: const Center(child: Text('키토 챌린지')),
    );
  }
}
