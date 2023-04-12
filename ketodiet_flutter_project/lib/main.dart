import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:url_strategy/url_strategy.dart'; // URL Path에 '#' 없애는 Package

import 'secret.dart';
import 'modules/handle.dart';

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
      onGenerateRoute: (settings) => HandleRoute.onGenerateRoute(settings),
      title: 'KetoDiet',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
