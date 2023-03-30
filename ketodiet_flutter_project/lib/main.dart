import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:url_strategy/url_strategy.dart';

import 'test.dart';
import 'pages/sign_page.dart';

final routes = {
  '/': (BuildContext context) => const HomePage(),
  '/test': (BuildContext context) => const TestPage()
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SignInButton(),
            SizedBox(
              height: 50.0,
            ),
            TestGround(),
          ],
        ),
      ),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
