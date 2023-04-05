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
              return RegisterWidget().form(context);
            } else if (snapshot.data == true) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                Navigator.pop(context);
              });
            }
          }

          return SignProcess().widget();
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
  await dropToken(context);
  return true;
}

class SignProcess {
  Widget widget() {
    return Center(
      child: Card(
        elevation: 20.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            padding(explainText(), 10, 10, 10, 10),
            padding(hintText(), 10, 10, 10, 10),
          ],
        ),
      ),
    );
  }

  Widget padding(widget, left, top, right, bottom) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: widget,
    );
  }

  Widget explainText() {
    return const Text(
      '로그인/로그아웃 처리 중 입니다',
      style: TextStyle(
        fontSize: 30.0,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget hintText() {
    return const Text(
      '로그인 진행 시 카카오 로그인 팝업 창을 닫으면\n로그인이 정상적으로 진행 되지 않습니다.\n만약 창을 실수로 닫았거나 진행되지 않는다면\n새로고침 후 재 로그인 해주세요.',
      style: TextStyle(
        color: Colors.black45,
        fontSize: 20.0,
      ),
    );
  }
}

class RegisterWidget {
  final registerController = TextEditingController();
  final registerKey = GlobalKey<FormState>();
  bool? registerValidator;

  Widget form(context) {
    return Center(
      child: Card(
        elevation: 20.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            padding(welcomeText(), 10, 10, 10, 10),
            padding(explainText(), 10, 10, 10, 10),
            padding(textField(), 10, 10, 10, 10),
            padding(buttons(context), 0, 10, 0, 0),
          ],
        ),
      ),
    );
  }

  Widget padding(widget, left, top, right, bottom) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: widget,
    );
  }

  Widget welcomeText() {
    return const Text(
      '환영합니다!',
      style: TextStyle(
        color: Colors.green,
        fontSize: 60.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget explainText() {
    return const Text(
      'KetoDiet에 처음 방문하셨네요\n닉네임을 설정해주세요',
      style: TextStyle(
        fontSize: 20.0,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget textField() {
    return SizedBox(
      width: 300.0,
      child: Form(
        key: registerKey,
        child: TextFormField(
          controller: registerController,
          decoration: const InputDecoration(
            labelText: '닉네임',
            hintText: '2글자 이상, 12글자 이하로 입력해주세요',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '닉네임을 입력 해주세요';
            } else if (value.length < 2 || value.length > 12) {
              return '닉네임은 2~12글자만 가능합니다.';
            } else if (registerValidator == false) {
              return '이미 존재하는 닉네임입니다.';
            }

            return null;
          },
        ),
      ),
    );
  }

  Widget buttons(context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 0.0),
          child: cancelButton(context),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: submitButton(context),
        ),
      ],
    );
  }

  Widget cancelButton(context) {
    return ElevatedButton(
      onPressed: () async {
        await dropToken(context);
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Navigator.pop(context);
        });
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        fixedSize: const Size(160.0, 40.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
          ),
        ),
      ),
      child: const Text('취소'),
    );
  }

  Widget submitButton(context) {
    return ElevatedButton(
      onPressed: () async {
        registerValidator = null;
        if (registerKey.currentState!.validate()) {
          OAuthToken? token = await getToken(context);
          http.Response response = await http.post(
            Uri.http(backendDomain, '/api/account'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': '${token!.toJson()}',
            },
            body: jsonEncode({
              'name': registerController.text,
            }),
          );

          if (response.statusCode == 201) {
            registerValidator = true;
          } else if (response.statusCode == 409) {
            registerValidator = false;
          } else {
            handleError(
              context,
              'Response Status Code Error.\nStatusCode: ${response.statusCode}',
              'sign_page.dart',
              'registerWidget',
            );
          }
        }
        if (registerKey.currentState!.validate()) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            Navigator.pop(context);
          });
        }
      },
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(160.0, 40.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(20.0),
          ),
        ),
      ),
      child: const Text('확인'),
    );
  }
}
