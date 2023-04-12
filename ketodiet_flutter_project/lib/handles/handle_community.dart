import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../secret.dart';
import '../modules/handle.dart';

class CommunityForum {
  CommunityPost? post;
  List<CommunityPost>? postList;
  List<CommunityComment>? commentList;

  CommunityForum({this.post, this.postList, this.commentList});

  static Future<dynamic> get(BuildContext context, Map<String, String>? params, {CommunityForum? forum}) async {
    if (params == null) {
      List<CommunityPost> postList = await HandleCommunity.getPostList(context, 1);

      return CommunityForum(postList: postList);
    } else if (params.length == 2 && params.containsKey('search') && params.containsKey('keyword')) {
      // 검색
    } else if (params.length == 1 && params.containsKey('page')) {
      List<CommunityPost>? postList = await HandleCommunity.getPostList(context, int.parse(params['page']!));

      if (postList is! CommunityPost) return false;

      return CommunityForum(postList: postList);
    } else if (params.length == 1 && params.containsKey('post')) {
      CommunityPost? post = await HandleCommunity.getPost(context, int.parse(params['post']!));

      if (post is! CommunityPost) return false;
    } else {
      return false;
    }
  }
}

class CommunityPost {
  final int postNum;
  final DateTime createDate;
  final DateTime? updateDate;
  final String category;
  final String title;
  final String? content;
  final String name;
  final int hit;
  final int recommend;
  final int comment;

  CommunityPost(
    this.postNum,
    this.createDate,
    this.updateDate,
    this.category,
    this.title,
    this.content,
    this.name,
    this.hit,
    this.recommend,
    this.comment,
  );
}

class CommunityComment {}

class HandleCommunity {
  static Future<List<CommunityPost>> getPostList(BuildContext context, int pageNum) async {
    List<CommunityPost> postList = [];

    http.Response response = await http.get(Uri.http(backendDomain, '/api/community', {'page': pageNum}));

    if (response.statusCode == 200) {
      //
    } else if (response.statusCode == 404) {
      //
    } else {
      // 에러
    }

    // 에러가 있다면 출력

    return postList;
  }

  static Future<CommunityPost?> getPost(BuildContext context, int postNum) async {
    CommunityPost? post;

    http.Response response = await http.get(Uri.http(backendDomain, '/api/community', {'post_num': postNum}));

    if (response.statusCode == 200) {
      //
    } else if (response.statusCode == 404) {
      //
    } else {
      // 에러
    }

    // 에러가 있다면 출력

    return post;
  }

  static Future<CommunityPost?> postPost(BuildContext context, String body) async {
    CommunityPost? post;

    http.Response response = await http.post(
      Uri.http(backendDomain, '/api/community'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      //
    } else if (response.statusCode == 403) {
      //
    } else {
      // 에러
    }

    // 에러가 있다면 출력

    return post;
  }

  static Future<CommunityPost?> patchPost(BuildContext context, int postNum, String body) async {
    CommunityPost? post;

    http.Response response = await http.patch(
      Uri.http(backendDomain, '/api/community', {'post_num': postNum}),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      //
    } else if (response.statusCode == 403) {
      //
    } else {
      // 에러
    }

    // 에러가 있다면 출력

    return post;
  }

  static Future<void> deletePost(BuildContext context, int postNum) async {
    http.Response response = await http.delete(
      Uri.http(backendDomain, '/api/community', {'post_num': postNum}),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
      },
    );

    if (response.statusCode == 200) {
      //
    } else if (response.statusCode == 403) {
      //
    } else {
      // 에러
    }

    // 에러가 있다면 출력
  }

  static Future<List<CommunityComment>> getCommentList(BuildContext context, int postNum) async {
    return [];
  }

  static Future<List<CommunityComment>> postComment(BuildContext context, int postNum, String body) async {
    return [];
  }

  static Future<List<CommunityComment>> patchComment(
      BuildContext context, int postNum, int commentNum, String body) async {
    return [];
  }

  static Future<List<CommunityComment>> deleteComment(BuildContext context, int postNum, int commentNum) async {
    return [];
  }
}
