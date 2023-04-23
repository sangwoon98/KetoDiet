import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ketodiet_flutter_project/pages/not_found_page.dart';

import '../pages/about_us_page.dart';
import '../pages/challenge_page.dart';
import '../pages/community_page.dart';
import '../pages/info_page.dart';
import '../pages/main_page.dart';
import '../pages/test_page.dart';

String? currentPath;

class HandleRoute {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    List<String> uri = settings.name!.split('?');
    String path = uri.first;
    Map<String, dynamic> query = {};
    if (uri.first == uri.last) {
      query = {};
    } else {
      var splitQueryString = Uri.splitQueryString(uri.last);

      for (var element in splitQueryString.keys) {
        query[element] = splitQueryString[element];
      }
    }
    if (settings.arguments != null) {
      query['additional'] = settings.arguments;
    }

    if (kDebugMode) {
      print('URI: $uri\nPATH: $path\nQUERY:$query\nSETTINGS:$settings');
    }

    currentPath = settings.name;

    switch (path) {
      case '/':
        return PageRouteBuilder(settings: settings, pageBuilder: (_, __, ___) => MainPage(query));
      case '/info':
        return PageRouteBuilder(settings: settings, pageBuilder: (_, __, ___) => InfoPage(query));
      case '/about-us':
        return PageRouteBuilder(settings: settings, pageBuilder: (_, __, ___) => AboutUsPage(query));
      case '/community':
        return PageRouteBuilder(settings: settings, pageBuilder: (_, __, ___) => CommunityPage(query));
      case '/community/post':
        return PageRouteBuilder(settings: settings, pageBuilder: (_, __, ___) => WritePostPage(query));
      case '/challenge':
        return PageRouteBuilder(settings: settings, pageBuilder: (_, __, ___) => ChallengePage(query));
      case '/test':
        return PageRouteBuilder(settings: settings, pageBuilder: (_, __, ___) => TestPage(query));
      default:
        settings = const RouteSettings(name: 'not-found');
        return PageRouteBuilder(settings: settings, pageBuilder: (_, __, ___) => const NotFoundPage());
    }
  }
}
