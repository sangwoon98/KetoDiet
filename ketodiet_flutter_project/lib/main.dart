import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:url_strategy/url_strategy.dart'; // URL Path에 '#' 없애는 Package

import 'secret.dart';
import 'pages/about_us_page.dart';
import 'pages/challenge_page.dart';
import 'pages/community_page.dart';
import 'pages/error_page.dart';
import 'pages/info_page.dart';
import 'pages/main_page.dart';
import 'pages/setting_page.dart';
import 'pages/sign_page.dart';
import 'pages/test_page.dart';

// final routes = {
//   '/': (BuildContext context) => const MainPage(),
//   '/about-us': (BuildContext context) => const AboutUsPage(),
//   '/info': (BuildContext context) => const InfoPage(),
//   '/community': (BuildContext context) => const CommunityPage(),
//   '/challenge': (BuildContext context) => const ChallengePage(),
//   '/setting': (BuildContext context) => const SettingPage(),
//   '/sign': (BuildContext context) => const SignPage(),
//   '/error': (BuildContext context) => const ErrorPage(),
//   '/test': (BuildContext context) => const TestPage(),
// };

final routes = {
  '/': const MainPage(),
  '/about-us': const AboutUsPage(),
  '/info': const InfoPage(),
  '/community': const CommunityPage(),
  '/challenge': const ChallengePage(),
  '/setting': const SettingPage(),
  '/sign': const SignPage(),
  '/error': const ErrorPage(),
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
    return MaterialApp(
      onGenerateRoute: (settings) {
        if (routes.containsKey(settings.name)) {
          return PageRouteBuilder(
              settings: RouteSettings(
                name: settings.name,
                arguments: settings.arguments,
              ),
              pageBuilder: (_, __, ___) => routes[settings.name]!);
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
