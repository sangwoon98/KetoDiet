import 'dart:async';

import 'package:flutter/material.dart';

import '../modules/account.dart';
import '../modules/handle.dart';

AppBar appBar(context) {
  return AppBar(
    automaticallyImplyLeading: false,
    toolbarHeight: AppBar().preferredSize.height,
    title: Row(
      children: [
        homeButton(context),
        pageButton(context, '/about-us', '우리는 누구인가요?'),
        pageButton(context, '/info', '키토제닉이란?'),
        pageButton(context, '/community', '커뮤니티'),
        pageButton(context, '/challenge', '키토 챌린지'),
        pageButton(context, '/test', '개발자 도구'),
      ],
    ),
    actions: [
      signButtons(context),
    ],
  );
}

Widget homeButton(context) {
  return Padding(
    padding: const EdgeInsets.only(left: 10),
    child: SizedBox(
      height: AppBar().preferredSize.height,
      child: TextButton(
        onPressed: () {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            Navigator.pushReplacementNamed(context, '/');
          });
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
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            Navigator.pushReplacementNamed(context, path);
          });
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

StreamController _signStreamController = StreamController.broadcast();

Widget signInButton(context) {
  return TextButton(
    onPressed: () async {
      await Navigator.pushNamed(context, '/sign',
          arguments: SignArgs('signIn'));
      updateSignStatus(context);
    },
    child: const Text(
      'Sign In',
      style: TextStyle(color: Colors.white),
      // TODO: SignInButton 디자인
    ),
  );
}

Widget signOutButton(context) {
  return TextButton(
    onPressed: () async {
      await Navigator.pushNamed(context, '/sign',
          arguments: SignArgs('signOut'));
      updateSignStatus(context);
    },
    child: const Text(
      'Sign Out',
      style: TextStyle(color: Colors.white),
      // TODO: signOutButton 디자인
    ),
  );
}

Widget signButtons(context) {
  updateSignStatus(context);
  return StreamBuilder(
    stream: _signStreamController.stream,
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      if (snapshot.hasData) {
        if (snapshot.data == true) {
          return Row(
            children: [
              // TODO: 설정 버튼 제작
              signOutButton(context),
            ],
          );
        } else if (snapshot.data == false) {
          return signInButton(context);
        }
      }

      return const SizedBox();
    },
  );
}

void updateSignStatus(context) async {
  try {
    _signStreamController.add(await getSignStatus(context));
  } catch (e) {
    handleError(context, e, 'app_bar.dart', 'updateSignStatus');
  }
}
