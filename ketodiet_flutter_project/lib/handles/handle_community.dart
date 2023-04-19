import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ketodiet_flutter_project/handles/handle_error.dart';

import '../secret.dart';
import 'handle_account.dart';

class CommunityForum {
  CommunityPost? communityPost;
  CommunityPostList? communityPostList;
  CommunityCommentList? communityCommentList;
  List<String>? categoryList;

  CommunityForum({
    this.communityPost,
    this.communityPostList,
    this.communityCommentList,
    this.categoryList,
  }) {
    communityPostList ??= CommunityPostList();
    categoryList ??= [];
  }
}

class CommunityPost {
  int postNum;
  String? category, title, name, content;
  int? hit, recommend, commentCount;
  List<dynamic>? recommendList;
  DateTime? createDate, updateDate;

  CommunityPost({
    required this.postNum,
    this.category,
    this.title,
    this.name,
    this.content,
    this.hit,
    this.commentCount,
    this.recommendList,
    this.createDate,
    this.updateDate,
  }) {
    recommendList ??= [];
    recommend ??= recommendList!.length;
  }

  static CommunityPost? init(Map<String, dynamic> query, Map<String, dynamic>? body) {
    if (!query.containsKey('post')) return null;

    if (body == null || body.containsKey('detail')) return CommunityPost(postNum: query['post']);

    return CommunityPost(
      postNum: query['post'],
      category: body['category'],
      title: body['title'],
      name: body['name'],
      content: body['content'],
      hit: body['hit'],
      recommendList: body['recommend'],
      commentCount: body['comment_count'],
      createDate: DateTime.parse(body['create_date']).toLocal(),
      updateDate: DateTime.parse(body['update_date']).toLocal(),
    );
  }
}

class CommunityPostList {
  List<CommunityPost>? list;
  late int pageNum;
  String? category, target, keyword;
  int? pageCount;
  bool? recommend;

  CommunityPostList({
    this.pageNum = 0,
    this.category,
    this.target,
    this.keyword,
    this.list,
    this.pageCount,
    this.recommend,
  }) {
    list ??= [];
  }

  static CommunityPostList init(Map<String, dynamic> query, Map<String, dynamic>? body) {
    CommunityPostList communityPostList = CommunityPostList();

    for (var element in query.keys) {
      switch (element) {
        case 'page':
          communityPostList.pageNum = query[element];
          break;
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

    if (body == null || body.containsKey('detail')) return communityPostList;

    int count = body['count'];
    int postPerPage = 30;

    if (count / postPerPage == count ~/ postPerPage) {
      communityPostList.pageCount = count ~/ postPerPage;
    } else {
      communityPostList.pageCount = (count ~/ postPerPage) + 1;
    }

    for (var element in body['results']) {
      communityPostList.list!.add(CommunityPost(
        postNum: element['post_num'],
        category: element['category'],
        title: element['title'],
        name: element['name'],
        hit: element['hit'],
        recommendList: element['recommend'],
        commentCount: element['comment_count'],
        createDate: DateTime.parse(element['create_date']).toLocal(),
      ));
    }

    return communityPostList;
  }
}

class CommunityComment {
  int commentNum;
  String name, content;
  DateTime createDate, updateDate;

  CommunityComment({
    required this.commentNum,
    required this.name,
    required this.content,
    required this.createDate,
    required this.updateDate,
  });
}

class CommunityCommentList {
  List<CommunityComment>? list;
  late int pageNum, pageCount, postNum;

  CommunityCommentList({
    this.list,
    this.pageNum = 1,
    this.pageCount = 0,
    required this.postNum,
  }) {
    list ??= [];
  }

  static CommunityCommentList? init(Map<String, dynamic> query, Map<String, dynamic>? body) {
    CommunityCommentList communityCommentList = CommunityCommentList(
      postNum: query.containsKey('post') ? query['post'] : 0,
      pageNum: query.containsKey('page') ? query['page'] : 1,
    );

    if (!query.containsKey('post') || body == null || body.containsKey('detail')) return communityCommentList;

    int count = body['count'];
    int commentPerPage = 20;

    if (count / commentPerPage == count ~/ commentPerPage) {
      communityCommentList.pageCount = count ~/ commentPerPage;
    } else {
      communityCommentList.pageCount = (count ~/ commentPerPage) + 1;
    }

    if (query.containsKey('page')) {
      communityCommentList.pageNum = query['page'];
    } else {
      communityCommentList.pageNum = communityCommentList.pageCount;
    }

    for (var element in body['results']) {
      communityCommentList.list!.add(CommunityComment(
        commentNum: element['comment_num'],
        name: element['name'],
        content: element['content'],
        createDate: DateTime.parse(element['create_date']).toLocal(),
        updateDate: DateTime.parse(element['update_date']).toLocal(),
      ));
    }
    return communityCommentList;
  }
}

class CategoryList {
  static List<String> init(List<dynamic>? body) {
    if (body == null || body.isEmpty) {
      return [];
    } else {
      List<String> list = [];
      for (var element in body) {
        list.add(element);
      }
      return list;
    }
  }
}

class HandleCommunity {
  static Future<CommunityForum> getForum(BuildContext context, Map<String, dynamic> query) async {
    CommunityForum communityForum = CommunityForum();
    query = _initQuery(query);

    if (query.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('잘못된 요청'),
              content: const Text('존재하지 않는 페이지거나\n잘못된 요청입니다.'),
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
          barrierDismissible: false,
        );
      });
    } else {
      http.Response response = await http.get(Uri.http(backendDomain, '/api/community', _encodeQueryComponent(query)));

      if (response.statusCode == 200) {
        Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));

        communityForum.communityPost = CommunityPost.init(query, body['post']);
        communityForum.communityPostList = CommunityPostList.init(query, body['page']);
        communityForum.communityCommentList = CommunityCommentList.init(query, body['comment']);
        communityForum.categoryList = CategoryList.init(body['category']);
        if (body.containsKey('page_num')) communityForum.communityPostList!.pageNum = body['page_num'];

        if (communityForum.communityPostList!.pageNum > 1 && communityForum.communityPostList!.pageCount == null) {
          query['page'] = 1;
          response = await http.get(Uri.http(backendDomain, '/api/community', _encodeQueryComponent(query)));

          if (response.statusCode == 200) {
            Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));

            communityForum.communityPost = CommunityPost.init(query, body['post']);
            communityForum.communityPostList = CommunityPostList.init(query, body['page']);
            communityForum.communityCommentList = CommunityCommentList.init(query, body['comment']);
            communityForum.categoryList = CategoryList.init(body['category']);
            if (body.containsKey('page_num')) communityForum.communityPostList!.pageNum = body['page_num'];

            if (communityForum.communityPostList!.pageCount! > 1) {
              query['page'] = communityForum.communityPostList!.pageCount;
              response = await http.get(Uri.http(backendDomain, '/api/community', _encodeQueryComponent(query)));

              if (response.statusCode == 200) {
                Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));

                communityForum.communityPost = CommunityPost.init(query, body['post']);
                communityForum.communityPostList = CommunityPostList.init(query, body['page']);
                communityForum.communityCommentList = CommunityCommentList.init(query, body['comment']);
                communityForum.categoryList = CategoryList.init(body['category']);
                if (body.containsKey('page_num')) communityForum.communityPostList!.pageNum = body['page_num'];
              }
            }
          }
        }
      }
    }

    return communityForum;
  }

  static Future<List<String>?> getCategoryList(BuildContext context) async {
    http.Response response = await http.get(Uri.http(backendDomain, '/api/community/category'));

    if (response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));

      return CategoryList.init(body['category']);
    } else {
      return [];
    }
  }

  static Future<List<String>?> postCategory(BuildContext context, String categoryName) async {
    http.Response response = await http.post(
      Uri.http(backendDomain, '/api/community/category'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
      },
      body: jsonEncode({
        'category': categoryName,
      }),
    );

    if (response.statusCode == 201) {
      Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));

      return CategoryList.init(body['category']);
    } else if (response.statusCode == 400 && context.mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('카테고리 생성 오류'),
            content: const Text('중복된 카테고리명 이거나 잘못된 값을 입력했습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
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
      return null;
    } else {
      errorManager.set(ErrorArgs('Response Status Code Error.\nStatusCode: ${response.statusCode}',
          'handle_community.dart', 'HandleCommunity.postPost'));
      if (context.mounted) HandleError.ifErroredPushError(context);
      return null;
    }
  }

  static Future<List<String>?> patchCategory(
      BuildContext context, String categoryName, String modifiedCategoryName) async {
    http.Response response = await http.patch(
      Uri.http(backendDomain, '/api/community/category'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
      },
      body: jsonEncode({
        'category': categoryName,
        'newcategory': modifiedCategoryName,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));

      return CategoryList.init(body['category']);
    } else if (response.statusCode == 400 && context.mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('카테고리 수정 오류'),
            content: const Text('중복된 카테고리명 이거나 잘못된 값을 입력했습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
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
      return null;
    } else {
      errorManager.set(ErrorArgs('Response Status Code Error.\nStatusCode: ${response.statusCode}',
          'handle_community.dart', 'HandleCommunity.postPost'));
      if (context.mounted) HandleError.ifErroredPushError(context);
      return null;
    }
  }

  static Future<List<String>?> deleteCategory(BuildContext context, String categoryName) async {
    http.Response response = await http.delete(
      Uri.http(backendDomain, '/api/community/category'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
      },
      body: jsonEncode({
        'category': categoryName,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));

      return CategoryList.init(body['category']);
    } else if (response.statusCode == 404 && context.mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('카테고리 삭제 오류'),
            content: const Text('존재하지 않는 카테고리 입니다.\n이미 삭제처리 되었거나 다른 관리자가 삭제하였을 수 있습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
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

      Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));

      return CategoryList.init(body['category']);
    } else {
      errorManager.set(ErrorArgs('Response Status Code Error.\nStatusCode: ${response.statusCode}',
          'handle_community.dart', 'HandleCommunity.postPost'));
      if (context.mounted) HandleError.ifErroredPushError(context);
      return null;
    }
  }

  static Future<int?> postPost(BuildContext context, String category, String title, String content) async {
    http.Response response = await http.post(
      Uri.http(backendDomain, '/api/community'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
      },
      body: jsonEncode({
        'category': category,
        'title': title,
        'content': content,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(utf8.decode(response.bodyBytes))['post_num'];
    } else {
      errorManager.set(ErrorArgs('Response Status Code Error.\nStatusCode: ${response.statusCode}',
          'handle_community.dart', 'HandleCommunity.postPost'));
      return null;
    }
  }

  static Future<bool> patchPost(
      BuildContext context, int postNum, String category, String title, String content) async {
    http.Response response = await http.patch(
      Uri.http(backendDomain, '/api/community', {'post_num': postNum.toString()}),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
      },
      body: jsonEncode({
        'category': category,
        'title': title,
        'content': content,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      errorManager.set(ErrorArgs('Response Status Code Error.\nStatusCode: ${response.statusCode}',
          'handle_community.dart', 'HandleCommunity.postPost'));
      return false;
    }
  }

  static Future<bool> deletePost(BuildContext context, int postNum) async {
    http.Response response = await http.delete(
      Uri.http(backendDomain, '/api/community', {'post_num': postNum.toString()}),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      errorManager.set(ErrorArgs('Response Status Code Error.\nStatusCode: ${response.statusCode}',
          'handle_community.dart', 'HandleCommunity.postPost'));
      return false;
    }
  }

  static Future<CommunityCommentList> getCommentList(BuildContext context, Map<String, dynamic> query) async {
    http.Response response =
        await http.get(Uri.http(backendDomain, '/api/community/comment', _encodeQueryComponent(query)));

    if (response.statusCode == 200) {
      CommunityCommentList communityCommentList =
          CommunityCommentList.init(query, jsonDecode(utf8.decode(response.bodyBytes))['comment'])!;

      if (communityCommentList.pageNum > 1 && communityCommentList.list!.isEmpty) {
        query['page'] = 1;
        response = await http.get(Uri.http(backendDomain, '/api/community/comment', _encodeQueryComponent(query)));
        if (response.statusCode == 200) {
          communityCommentList =
              CommunityCommentList.init(query, jsonDecode(utf8.decode(response.bodyBytes))['comment'])!;

          if (communityCommentList.pageCount > 1) {
            query['page'] = communityCommentList.pageCount;
            response = await http.get(Uri.http(backendDomain, '/api/community/comment', _encodeQueryComponent(query)));
            if (response.statusCode == 200) {
              communityCommentList =
                  CommunityCommentList.init(query, jsonDecode(utf8.decode(response.bodyBytes))['comment'])!;
            }
          }
        }
      }

      return communityCommentList;
    } else {
      return CommunityCommentList(postNum: query['page']);
    }
  }

  static Future<bool> postComment(BuildContext context, int postNum, String content) async {
    http.Response response = await http.post(
      Uri.http(backendDomain, '/api/community/comment', {'post_num': postNum.toString()}),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
      },
      body: jsonEncode({
        'content': content,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      errorManager.set(ErrorArgs('Response Status Code Error.\nStatusCode: ${response.statusCode}',
          'handle_community.dart', 'HandleCommunity.postComment'));
      return false;
    }
  }

  static Future<bool> patchComment(BuildContext context, int commentNum, String content) async {
    http.Response response = await http.patch(
      Uri.http(backendDomain, '/api/community/comment', {'comment_num': commentNum.toString()}),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
      },
      body: jsonEncode({
        'content': content,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      errorManager.set(ErrorArgs('Response Status Code Error.\nStatusCode: ${response.statusCode}',
          'handle_community.dart', 'HandleCommunity.postPost'));
      return false;
    }
  }

  static Future<bool> deleteComment(BuildContext context, int commentNum) async {
    http.Response response = await http.delete(
      Uri.http(backendDomain, '/api/community/comment', {'comment_num': commentNum.toString()}),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      errorManager.set(ErrorArgs('Response Status Code Error.\nStatusCode: ${response.statusCode}',
          'handle_community.dart', 'HandleCommunity.postPost'));
      return false;
    }
  }

  static Future<List> postRecommend(BuildContext context, int postNum) async {
    http.Response response = await http.post(
      Uri.http(backendDomain, '/api/community/recommend', {'post_num': postNum.toString()}),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
      },
    );

    if (response.statusCode == 201) {
      Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));

      return body['recommend'];
    } else {
      errorManager.set(ErrorArgs('Response Status Code Error.\nStatusCode: ${response.statusCode}',
          'handle_community.dart', 'HandleCommunity.postComment'));
      if (context.mounted) await HandleError.ifErroredPushError(context);

      return [];
    }
  }

  static Map<String, dynamic> _initQuery(Map<String, dynamic> query) {
    if (query.isEmpty) query = {'page': 1};

    for (var element in query.keys) {
      const validateParam = ['page', 'post', 'category', 'target', 'keyword', 'recommend'];
      if (!validateParam.contains(element)) return {};
    }

    if (query.containsKey('post')) {
      if (query['post'] is String) query['post'] = int.tryParse(query['post']);
      if (query['post'] is! int) return {};
    }

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

  static Map<String, dynamic> _encodeQueryComponent(Map<String, dynamic> query) {
    Map<String, String> encodedQuery = {};

    for (var element in query.keys) {
      switch (element) {
        case 'post':
          encodedQuery['post_num'] = Uri.encodeQueryComponent(query[element].toString());
          break;
        default:
          encodedQuery[element] = Uri.encodeQueryComponent(query[element].toString());
      }
    }
    return encodedQuery;
  }
}
