import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import '../secret.dart';
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

    return FutureBuilder(
      future: signFuture(context, signArgs),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.pop(context);
            });
          }
        }
        return const Scaffold();
        // TODO: [로그인 처리 중] 안내 페이지 제작
        // 클릭 시 MainPage로 가는 버튼 제작
      },
    );
  }
}

Future<bool> signFuture(context, SignArgs? signArgs) async {
  if (signArgs == null) {
    return true;
  } else if (signArgs.signType == 'signIn') {
    return await signIn(context);
  } else if (signArgs.signType == 'signOut') {
    return await signOut(context);
  }

  return true;
}

Future<bool> signIn(context) async {
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
        Uri.http(backendDomain, '/api/account', token.toJson()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': '${token.toJson()}',
        },
      );

      // TODO: StatusCode에 따라서 회원가입 창으로 넘어가게 하기

      return true;
    } catch (e) {
      error = e;
    }
  }

  await handleError(context, error, 'sign_page.dart', 'signOut');
  return false;
}

Future<bool> signOut(context) async {
  try {
    await UserApi.instance.logout();
  } catch (error) {
    await handleError(context, error, 'sign_page.dart', 'signOut');
    return false;
  }

  return true;
}
