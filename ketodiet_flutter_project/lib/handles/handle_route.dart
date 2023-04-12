import 'package:flutter/material.dart';

import '../pages/about_us_page.dart';
import '../pages/challenge_page.dart';
import '../pages/community_page.dart';
import '../pages/info_page.dart';
import '../pages/main_page.dart';
import '../pages/test_page.dart';

class HandleRoute {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    List<String> uri = settings.name!.split('?');
    String path = uri.first;
    Map<String, String>? params = uri.first == uri.last ? null : Uri.splitQueryString(uri.last);

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) {
        return route(path: path, params: params);
      },
    );
  }

  static Widget route({required String path, Map<String, String>? params}) {
    final Map<String, Widget> routes = {
      '/': MainPage(params: params),
      '/about-us': AboutUsPage(params: params),
      '/info': InfoPage(params: params),
      '/community': CommunityPage(params: params),
      '/challenge': ChallengePage(params: params),
      '/test': TestPage(params: params),
    };

    if (routes.containsKey(path)) {
      return routes[path]!;
    } else {
      return routes['/']!;
    }
  }
}
