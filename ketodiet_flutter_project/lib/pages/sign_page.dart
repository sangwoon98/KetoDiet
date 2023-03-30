import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class SignInButton extends StatefulWidget {
  const SignInButton({super.key});

  @override
  State<SignInButton> createState() => _SignInButtonState();
}

class _SignInButtonState extends State<SignInButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () async {
          Navigator.pushNamed(context, '/test');
          if (await isKakaoTalkInstalled()) {
            try {
              OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
              print('카카오톡으로 로그인 성공 ${token.accessToken}');
            } catch (error) {
              print('카카오톡으로 로그인 실패 $error');
            }
          } else {
            try {
              OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
              print('카카오계정으로 로그인 성공 ${token.accessToken}');
              await http.get(Uri.http(
                  '127.0.0.1:8001', '/api/logincheck', token.toJson()));
            } catch (error) {
              print('카카오계정으로 로그인 실패 $error');
            }
          }
          Navigator.pop(context);
        },
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          fixedSize: MaterialStateProperty.all(const Size.fromWidth(500)),
        ),
        child: const Image(
          image: AssetImage('assets/images/kakao_login_large_wide.png'),
        ));
  }
}
