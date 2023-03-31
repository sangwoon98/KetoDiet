import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import 'account.dart';

AppBar appBar(context) {
  return AppBar(
    automaticallyImplyLeading: false,
    toolbarHeight: AppBar().preferredSize.height,
    title: Row(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        homeButton(context),
        pageButton(context, '/about-us', '우리는 누구인가요?'),
        pageButton(context, '/info', '키토제닉이란?'),
        pageButton(context, '/community', '커뮤니티'),
        pageButton(context, '/challenge', '키토 챌린지'),
        pageButton(context, '/test', '개발자 도구'),
      ],
    ),
    actions: const [],
  );
}

Widget homeButton(context) {
  return Padding(
    padding: const EdgeInsets.only(left: 10),
    child: SizedBox(
      height: AppBar().preferredSize.height,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/');
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0.0, 2.0, 4.0, 2.0),
                child: Image(
                  image: AssetImage('assets/images/beef.png'),
                ),
              ),
              Text(
                'KetoDiet',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: AppBar().preferredSize.height / 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget pageButton(context, String path, String displayedName) {
  return Padding(
    padding: const EdgeInsets.only(left: 10),
    child: SizedBox(
      height: AppBar().preferredSize.height,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, path);
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          child: Text(
            displayedName,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  );
}
