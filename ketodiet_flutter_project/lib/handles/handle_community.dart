import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../secret.dart';
import '../modules/handle.dart';

class CommunityForum {
  CommunityPost? communityPost;
  CommunityComment? communityComment;
  CommunityPostList communityPostList;

  CommunityForum({this.communityPost, this.communityComment, required this.communityPostList});

  static Future<CommunityForum> get(BuildContext context, Map<String, dynamic> query) async {
    if (query.isEmpty) query = {'page': 1};

    if (!_validateQuery(query)) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('잘못된 요청'),
              content: const Text('존재하지 않는 페이지입니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
                      Navigator.pushNamedAndRemoveUntil(context, '/community', (_) => false);
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
          barrierDismissible: true,
        );
      });

      return CommunityForum(communityPostList: await HandleCommunity.getPostList(context, {}));
    } else if (query.containsKey('post')) {
      // TODO: GET post
      return CommunityForum(communityPostList: await HandleCommunity.getPostList(context, {}));
    } else {
      return CommunityForum(communityPostList: await HandleCommunity.getPostList(context, query));
    }
  }

  static bool _validateQuery(Map<String, dynamic> query) {
    for (var element in query.keys) {
      const validateParam = ['page', 'post', 'category', 'target', 'keyword', 'recommend'];
      if (!validateParam.contains(element)) return false;
    }

    return true;
  }
}

class CommunityPost {
  int postNum, hit, recommend, commentCount;
  String category, title, name;
  DateTime createDate;

  CommunityPost(
      this.postNum, this.category, this.title, this.name, this.createDate, this.hit, this.recommend, this.commentCount);
}

class CommunityComment {}

class CommunityPostList {
  List<CommunityPost>? list;
  int pageNum;
  String? category, target, keyword;
  int? pageCount;
  bool? recommend;

  CommunityPostList(this.pageNum,
      {this.category, this.target, this.keyword, this.list, this.pageCount, this.recommend}) {
    list ??= [];
  }

  static Map<String, dynamic> initQuery(Map<String, dynamic> query) {
    if (query.containsKey('page')) {
      if (query['page'] is String) query['page'] = int.tryParse(query['page']);
      if (query['page'] is! int) return {};
    }

    if (query.containsKey('category')) {
      if (query['category'] is! String) query['category'] = query['category'].toString();
    }

    if (query.containsKey('target')) {
      if (query['target'] is! String) query['target'] = query['target'].toString();
    }

    if (query.containsKey('keyword')) {
      if (query['keyword'] is! String) query['keyword'] = query['keyword'].toString();
    }

    if (query.containsKey('recommend')) {
      if (query['recommend'] is String) {
        String stringBool = query['recommend'];
        if (stringBool.toLowerCase() == 'true') query['recommend'] = true;
      }
      if (query['recommend'] is! bool || query['recommend'] == false) return {};
    }

    return query;
  }

  static CommunityPostList initCommunityPostList(Map<String, dynamic> query) {
    CommunityPostList communityPostList = CommunityPostList(query['page']);

    for (var element in query.keys) {
      switch (element) {
        case 'category':
          communityPostList.category = query[element];
          break;
        case 'target':
          communityPostList.target = query[element];
          break;
        case 'keyword':
          communityPostList.keyword = query[element];
          break;
        case 'recommend':
          communityPostList.recommend = query[element];
          break;
      }
    }

    return communityPostList;
  }
}

class HandleCommunity {
  static Future<CommunityPostList> getPostList(BuildContext context, Map<String, dynamic> query) async {
    query = CommunityPostList.initQuery(query);

    if (query.isEmpty) {
      return CommunityPostList(0);
    } else {
      CommunityPostList communityPostList = CommunityPostList.initCommunityPostList(query);
      for (var element in query.keys) {
        query[element] = Uri.encodeQueryComponent(query[element].toString());
      }

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
          if (results.isNotEmpty) {
            communityPostList.pageCount = jsonData['count'];
            communityPostList.pageCount = communityPostList.pageCount! ~/ results.length;

            for (var element in results) {
              communityPostList.list!.add(CommunityPost(
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
          }
        }
      }

      return communityPostList;
    }
  }
}
