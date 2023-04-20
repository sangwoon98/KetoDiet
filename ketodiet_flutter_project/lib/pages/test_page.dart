import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../secret.dart';
import '../modules/app_bar.dart';
import '../modules/handle.dart';

class TestPage extends StatefulWidget {
  final Map<String, dynamic> query;

  const TestPage(this.query, {super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  void initState() {
    if (widget.query.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushNamedAndRemoveUntil(context, '/test', (_) => false);
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.widget(context),
      body: Center(
        child: Column(
          children: [
            testModule(communityDrop(context)),
            testModule(communityTestInit(context)),
            testModule(settingsGet(context)),
            testModule(settingsPatch(context)),
          ],
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

Widget communityDrop(context) {
  return ElevatedButton(
    onPressed: () async {
      // 카테고리 삭제
      List<String>? categoryList = await HandleCommunity.getCategoryList(context);
      if (categoryList is List<String>) {
        for (var element in categoryList) {
          await HandleCommunity.deleteCategory(context, element);
        }
      }

      // 글 삭제
      List<CommunityForum> communityForumList = [
        await HandleCommunity.getForum(context, {'page': 1})
      ];
      if (communityForumList[0].communityPostList != null) {
        if (communityForumList[0].communityPostList!.pageCount != null) {
          for (int i = 2; i <= communityForumList[0].communityPostList!.pageCount!; i++) {
            communityForumList.add(await HandleCommunity.getForum(context, {'page': i}));
          }
        }
      }

      List<int> postList = [];
      for (var element in communityForumList) {
        for (var element in element.communityPostList!.list!) {
          postList.add(element.postNum);
        }
      }

      for (var element in postList) {
        await HandleCommunity.deletePost(context, element);
      }

      if (kDebugMode) {
        print('Community All Drop Success!!!');
      }
    },
    child: const Text('Community All Drop'),
  );
}

Widget communityTestInit(context) {
  return ElevatedButton(
    onPressed: () async {
      // 카테고리 생성
      List<String> categoryList = ['일반', '정보', '식단', '유머'];
      for (var element in categoryList) {
        await HandleCommunity.postCategory(context, element);
      }

      // 글 생성 // 모든 카테고리에 글 91개
      for (var i = 1; i <= 91; i++) {
        for (var element in categoryList) {
          await HandleCommunity.postPost(
            context,
            element,
            '$element 카테고리의 $i번째 글',
            base64Encode(utf8.encode('$element 카테고리의 $i번째 글')),
          );
        }
      }

      // 댓글 생성 // 모든 글에 댓글 0~181개
      CommunityForum communityForum = await HandleCommunity.getForum(context, {'page': 1});

      List<int> postList = [];
      for (var element in communityForum.communityPostList!.list!) {
        postList.add(element.postNum);
      }

      for (var element in postList) {
        int randomComment = Random().nextInt(10) > 8 ? Random().nextInt(81) + 101 : Random().nextInt(21);
        for (var i = 1; i <= randomComment; i++) {
          await HandleCommunity.postComment(
              context, element, base64Encode(utf8.encode('포스트넘버: $element의 $i번째 댓글 ${DateTime.now()}')));
        }
      }

      if (kDebugMode) {
        print('Community Test init Success!!!');
      }
    },
    child: const Text('Community Test init'),
  );
}

Widget settingsGet(context) {
  return ElevatedButton(
    onPressed: () async {
      http.Response response = await http.get(
        Uri.http(backendDomain, '/api/settings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
        },
      );

      if (kDebugMode) {
        print('StatusCode: ${response.statusCode}\n${jsonDecode(utf8.decode(response.bodyBytes))}');
      }
    },
    child: const Text('PATCH settings'),
  );
}

Widget settingsPatch(context) {
  final controller = TextEditingController();
  return Row(
    children: [
      Expanded(
        child: TextField(
          controller: controller,
        ),
      ),
      ElevatedButton(
        onPressed: () async {
          http.Response response = await http.patch(
            Uri.http(backendDomain, '/api/settings'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
            },
            body: jsonEncode(
              {
                'num': controller.text,
              },
            ),
          );

          if (kDebugMode) {
            print('StatusCode: ${response.statusCode}\n${jsonDecode(utf8.decode(response.bodyBytes))}');
          }
        },
        child: const Text('PATCH settings'),
      ),
    ],
  );
}
