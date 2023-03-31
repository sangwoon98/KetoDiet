import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:url_strategy/url_strategy.dart';

import 'pages/about_us_page.dart';
import 'pages/challenge_page.dart';
import 'pages/community_page.dart';
import 'pages/error_page.dart';
import 'pages/info_page.dart';
import 'pages/main_page.dart';
import 'pages/setting_page.dart';
import 'pages/test_page.dart';

final routes = {
  '/': (BuildContext context) => const MainPage(),
  '/about-us': (BuildContext context) => const AboutUsPage(),
  '/info': (BuildContext context) => const InfoPage(),
  '/community': (BuildContext context) => const CommunityPage(),
  '/challenge': (BuildContext context) => const ChallengePage(),
  '/setting': (BuildContext context) => const SettingPage(),
  '/error': (BuildContext context) => const ErrorPage(),
  '/test': (BuildContext context) => const TestPage(),
};

void main() async {
  await dotenv.load(fileName: 'assets/config/.env');

  setPathUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(
    nativeAppKey: '${dotenv.env['KAKAO_NATIVE_APP_KEY']}',
    javaScriptAppKey: '${dotenv.env['KAKAO_JAVASCRIPT_APP_KEY']}',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KetoDiet',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      routes: routes,
    );
  }
}
