import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import '../modules/app_bar.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String signInfo = '';

  @override
  void initState() {
    signInfoInit().then((value) {
      signInfo = value;
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              testModule(signInfoText(signInfo)),
              testModule(signInButton(context)),
              testModule(signOutButton()),
              testModule(apiTestField()),
              testModule(accountButtons()),
            ],
          ),
        ),
      ),
    );
  }
}

Widget testModule(widget) {
  return SizedBox(
    width: 500.0,
    child: Padding(
      padding: EdgeInsets.all(10.0),
      child: widget,
    ),
  );
}

Future<String> signInfoInit() async {
  try {
    var tokenInfo = await UserApi.instance.accessTokenInfo();
    return 'appId: ${tokenInfo.appId}, id: ${tokenInfo.id}, expires_in: ${tokenInfo.expiresIn}';
  } catch (error) {
    print(error);
    return 'NOT SIGNED or ERROR';
  }
}

Widget signInfoText(text) {
  return Center(child: Text(text));
}

Widget signInButton(context) {
  return TextButton(
    onPressed: () async {
      if (await isKakaoTalkInstalled()) {
        try {
          OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
          await http.get(
              Uri.http('127.0.0.1:8001', '/api/logincheck', token.toJson()));
        } catch (error) {
          Navigator.pushNamed(context, '/error');
        }
      } else {
        try {
          OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          await http.get(
              Uri.http('127.0.0.1:8001', '/api/logincheck', token.toJson()));
        } catch (error) {
          Navigator.pushNamed(context, '/error');
        }
      }
    },
    style: ButtonStyle(
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      padding: MaterialStateProperty.all(EdgeInsets.zero),
      fixedSize: MaterialStateProperty.all(const Size.fromWidth(500)),
    ),
    child: const Image(
      image: AssetImage('assets/images/kakao_login_large_wide.png'),
    ),
  );
}

Widget signOutButton() {
  return TextButton(
      onPressed: () {
        UserApi.instance.logout();
      },
      child: const Text('Sign Out'));
}

Widget apiTestField() {
  final myController = TextEditingController();

  return SizedBox(
    width: 500.0,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: TextField(
            controller: myController,
            decoration: const InputDecoration(
              labelText: 'Value',
              hintText: 'Enter Value for Test',
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(width: 2, color: Colors.green),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(width: 1, color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () async {
            var myValue = myController.text;
            var myUri = Uri.http(
              '127.0.0.1:8001',
              '/api/test',
              {'value': myValue},
            );
            var response = await http.get(myUri);

            print(response.body);
          },
          style: ButtonStyle(
            fixedSize: MaterialStateProperty.all(const Size.fromHeight(50.0)),
            shape: MaterialStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
          ),
          child: const Text('SEND'),
        ),
      ],
    ),
  );
}

Widget accountButtons() {
  return Row();
}
