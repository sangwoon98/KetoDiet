import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:ketodiet_flutter_project/modules/handle.dart';

import '../secret.dart';
import '../modules/account.dart';
import '../modules/app_bar.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              testModule(unregister(context)),
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
      padding: const EdgeInsets.all(10.0),
      child: widget,
    ),
  );
}

Widget unregister(context) {
  return ElevatedButton(
    onPressed: () async {
      try {
        await UserApi.instance.unlink();
      } catch (e) {
        handleError(context, e, 'test_dart', 'unregister');
      }
      http.Response response = await http.delete(
        Uri.http(backendDomain, '/api/account'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': '${(await getToken(context))!.toJson()}',
        },
      );

      print(response.statusCode);
    },
    child: const Text('계정 삭제 (Sign In 돼있을때만 누르기)'),
  );
}
