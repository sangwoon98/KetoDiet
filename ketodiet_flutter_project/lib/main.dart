import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:url_strategy/url_strategy.dart'; // URL Path에 '#' 없애는 Package

import 'secret.dart';
import 'modules/handle.dart';
import 'pages/about_us_page.dart';
import 'pages/challenge_page.dart';
import 'pages/community_page.dart';
import 'pages/info_page.dart';
import 'pages/main_page.dart';
import 'pages/test_page.dart';

final routes = {
  '/': const MainPage(),
  '/about-us': const AboutUsPage(),
  '/info': const InfoPage(),
  '/community': const CommunityPage(),
  '/challenge': const ChallengePage(),
  '/test': const TestPage(),
};

void main() async {
  setPathUrlStrategy(); // URL Path에 '#' 없애는 Function

  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(
    nativeAppKey: kakaoNativeAppKey,
    javaScriptAppKey: kakaoJavascriptAppKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    HandleAccount.init();

    return MaterialApp(
      onGenerateRoute: (settings) {
        if (routes.containsKey(settings.name)) {
          return PageRouteBuilder(
            settings: RouteSettings(
              name: settings.name,
              arguments: settings.arguments,
            ),
            pageBuilder: (_, __, ___) => routes[settings.name]!,
          );
        }

        return null;
      },
      title: 'KetoDiet',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
