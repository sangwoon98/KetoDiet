import 'package:flutter/material.dart';

import '../pages/about_us_page.dart';
import '../pages/challenge_page.dart';
import '../pages/community_page.dart';
import '../pages/info_page.dart';
import '../pages/main_page.dart';
import '../pages/test_page.dart';

class HandleRoute {
  static late List<String> uri;
  static late String path;
  static late Map<String, dynamic> params;

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    uri = settings.name!.split('?');
    path = uri.first;
    params = uri.first == uri.last ? {} : Uri.splitQueryString(uri.last);
    if (settings.arguments != null) params['additional'] = settings.arguments;

    final Map<String, Widget> routes = {
      '/': MainPage(params),
      '/about-us': AboutUsPage(params),
      '/info': InfoPage(params),
      '/community': CommunityPage(params),
      '/challenge': ChallengePage(params),
      '/test': TestPage(params),
    };

    if (!routes.containsKey(path)) {
      settings = const RouteSettings(name: '/', arguments: {});
      path = '/';
    }

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) {
        return routes[path]!;
      },
    );
  }
}
