import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../secret.dart';
import '../modules/handle.dart';

class CommunityPost {
  int postNum, hit, recommend, commentCount;
  String category, title, name;
  DateTime createDate; // "2022-03-20T10:30:00Z"

  CommunityPost(
      this.postNum, this.category, this.title, this.name, this.createDate, this.hit, this.recommend, this.commentCount);
}

class CommunityPostList {
  List<CommunityPost>? list;
  int pageNum;
  String? category, target, keyword;

  CommunityPostList(this.pageNum, {this.category, this.target, this.keyword, this.list}) {
    list ??= [];
  }

  static Map<String, dynamic> initQuery(CommunityPostList communityPostList) {
    Map<String, dynamic> query = {'page': communityPostList.pageNum.toString()};
    if (communityPostList.category is String) query['category'] = communityPostList.category;
    if (communityPostList.target is String) query['target'] = communityPostList.target;
    if (communityPostList.keyword is String) query['keyword'] = communityPostList.keyword;

    return query;
  }
}

class HandleCommunity {
  static Future<CommunityPostList> getPostList(BuildContext context, CommunityPostList postList) async {
    Map<String, dynamic> query = CommunityPostList.initQuery(postList);

    http.Response response = await http.get(
      Uri.http(backendDomain, '/api/community', query),
    );

    if (response.statusCode != 200) {
      errorManager.set(ErrorArgs('Response Status Code Error.\nStatusCode: ${response.statusCode}',
          'handle_community.dart', 'HandleCommunity.getPostList'));
      if (context.mounted) await HandleError.ifErroredPushError(context);
    } else {
      Map jsonData = jsonDecode(response.body)['serializer'];
      if (jsonData.containsKey('results')) {
        List results = jsonData['results'];

        for (var element in results) {
          postList.list!.add(CommunityPost(
            element['post_num'],
            element['category'],
            element['title'],
            element['name'],
            DateTime.parse(element['create_date']),
            element['hit'],
            element['recommend'],
            element['comment_count'],
          ));
        }
      } else {
        if (context.mounted) {
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('페이지가 존재하지 않습니다.'),
                content: const Text('검색 결과가 존재 하지 않거나 해당 페이지가 존재하지 않습니다.'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        Navigator.pushReplacementNamed(context, '/community');
                      });
                    },
                    child: const Text('확인'),
                  ),
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              );
            },
            barrierDismissible: false,
          );
        }
      }
    }

    return postList;
  }
}
