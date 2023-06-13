import 'dart:convert';

import 'package:http/http.dart' as http;

import '../modules/handle.dart';
import '../secret.dart';

class UserInfo {
  dynamic uid;
  String name;
  bool isAdmin;

  UserInfo({required this.uid, required this.name, required this.isAdmin});
}

class UserList {
  List<UserInfo>? list;
  int pageNum;
  String? keyword;
  int? pageCount;

  UserList({
    required this.pageNum,
    required this.keyword,
    this.list,
    this.pageCount,
  }) {
    list ??= [];
  }

  static Future<UserList> init({required int page, String? keyword}) async {
    UserList userList = UserList(pageNum: page, keyword: keyword);
    Map body = await HandleAdmin.getUserList(page: page, keyword: keyword);

    if (body.isEmpty || body.containsKey('detail')) return userList;
    int count = body['count'];
    int userPerPage = 30;

    if (count / userPerPage == count ~/ userPerPage) {
      userList.pageCount = count ~/ userPerPage;
    } else {
      userList.pageCount = (count ~/ userPerPage) + 1;
    }

    for (var element in body['results']) {
      userList.list!.add(UserInfo(
        uid: element['id'],
        name: element['name'],
        isAdmin: element['isAdmin'],
      ));
    }
    return userList;
  }
}

class HandleAdmin {
  static Future<Map> getUserList({required int page, String? keyword}) async {
    Map<String, dynamic> query = {'page': page.toString()};

    if (keyword != null) query.addAll({'keyword': keyword});

    http.Response response = await http.get(
      Uri.http(backendDomain, '/api/admin', query),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes))['page'];
    } else {
      return {};
    }
  }

  static Future<UserList> patchAdmin(UserList list, UserInfo info) async {
    http.Response response = await http.patch(
      Uri.http(backendDomain, '/api/admin'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
      },
      body: jsonEncode({
        'uid': info.uid,
        'isAdmin': !info.isAdmin,
      }),
    );

    if (response.statusCode == 200) {
      for (int index = 0; index < list.list!.length; index++) {
        if (list.list![index].uid == info.uid) {
          list.list![index].isAdmin = !list.list![index].isAdmin;
        }
      }
    }

    return list;
  }

  static Future<UserList> deleteUser(UserList list, UserInfo info) async {
    http.Response response = await http.delete(
      Uri.http(backendDomain, '/api/admin'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
      },
      body: jsonEncode({
        'uid': info.uid,
      }),
    );

    if (response.statusCode == 200) {
      for (int index = 0; index < list.list!.length; index++) {
        if (list.list![index].uid == info.uid) {
          list.list!.removeAt(index);
        }
      }
    }

    return list;
  }
}
