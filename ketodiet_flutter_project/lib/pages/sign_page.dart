import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import '../secret.dart';
import '../modules/account.dart';
import '../modules/handle.dart';

class SignPage extends StatefulWidget {
  const SignPage({super.key});

  @override
  State<SignPage> createState() => _SignPageState();
}

class _SignPageState extends State<SignPage> {
  @override
  Widget build(BuildContext context) {
    SignArgs? signArgs =
        ModalRoute.of(context)?.settings.arguments as SignArgs?;

    return Scaffold(
      body: FutureBuilder(
        future: signPageFuture(context, signArgs),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == 'register') {
              return registerWidget(context);
            } else if (snapshot.data == true) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                Navigator.pop(context);
              });
            }
          }

          return const SizedBox();
          // TODO: Sign Processing 창 만들기
        },
      ),
    );
  }
}

Future<dynamic> signPageFuture(context, SignArgs? signArgs) async {
  if (signArgs == null) {
    return true;
  } else if (signArgs.signType == 'signIn') {
    return await signIn(context);
  } else if (signArgs.signType == 'signOut') {
    return await signOut(context);
  }
}

Future<dynamic> signIn(context) async {
  late OAuthToken token;
  Object? error;

  if (await isKakaoTalkInstalled()) {
    try {
      token = await UserApi.instance.loginWithKakaoTalk();
    } catch (e) {
      error = e;
    }
  } else {
    try {
      token = await UserApi.instance.loginWithKakaoAccount();
    } catch (e) {
      error = e;
    }
  }

  if (error == null) {
    try {
      http.Response response = await http.get(
        Uri.http(backendDomain, '/api/account'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': '${token.toJson()}',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        return 'register';
      } else {
        throw 'Response Status Code Error.\nStatusCode: ${response.statusCode}';
      }
    } catch (e) {
      error = e;
    }
  }

  await handleError(context, error, 'sign_page.dart', 'signIn');
  return false;
}

Future<bool> signOut(context) async {
  dropToken(context);
  return true;
}

Widget registerWidget(context) {
  TextEditingController controller = TextEditingController();

  // TODO: 회원가입 창
  return Center(
    child: SizedBox(
      width: 300.0,
      height: 300.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('좋은 말로 할때 닉네임 입력하쇼.\n이건 내 마지막 경고요.'),
          TextField(
            controller: controller,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await dropToken(context);
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    Navigator.pop(context);
                  });
                },
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () async {
                  OAuthToken? token = await getToken(context);
                  http.Response response = await http.post(
                    Uri.http(backendDomain, '/api/account'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Accept': 'application/json',
                      'Authorization': '${token!.toJson()}',
                    },
                    body: jsonEncode({
                      'name': controller.text,
                    }),
                  );

                  if (response.statusCode == 200) {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      Navigator.pop(context);
                    });
                  } else {
                    handleError(
                      context,
                      'Response Status Code Error.\nStatusCode: ${response.statusCode}',
                      'sign_page.dart',
                      'registerWidget',
                    );
                  }
                },
                child: const Text('확인'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
