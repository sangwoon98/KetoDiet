import 'package:flutter/material.dart';

import '../modules/handle.dart';

class CustomScaffold {
  static Widget scaffold({required BuildContext context, required Widget? body}) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return FutureBuilder(
        future: null,
        builder: (context, snapshot) {
          return Scaffold(
            key: scaffoldKey,
            appBar: CustomAppBar.widget(context, scaffoldKey),
            body: body,
            drawer: CustomDrawer.widget(context, scaffoldKey),
          );
        });
  }
}

class CustomAppBar {
  static AppBar widget(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    double deviceSize = MediaQuery.of(context).size.width;
    if (deviceSize >= desktop || deviceSize >= laptop) {
      return AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: AppBar().preferredSize.height,
        title: Row(
          children: [
            PageButton.home(context),
            PageButton.page(context, '/info', '키토제닉이란?'),
            PageButton.page(context, '/about-us', '우리는 누구인가요?'),
            PageButton.page(context, '/community', '커뮤니티'),
            PageButton.page(context, '/challenge', '키토 챌린지'),
            PageButton.page(context, '/test', '개발자 도구'),
          ],
        ),
        actions: Actions.actions(context),
      );
    } else {
      return AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: AppBar().preferredSize.height,
        leading: IconButton(
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onPressed: () {
            scaffoldKey.currentState!.openDrawer();
          },
          icon: const Icon(Icons.menu),
        ),
        title: PageButton.home(context),
        centerTitle: true,
        actions: Actions.actions(context),
      );
    }
  }
}

class PageButton {
  static Widget home(BuildContext context) {
    return FittedBox(
      child: TextButton(
        onPressed: () {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
          });
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Row(
          children: [
            Image(
              image: const AssetImage('assets/images/beef.png'),
              height: AppBar().preferredSize.height,
            ),
            const SizedBox(width: 5.0),
            Text(
              'KetoDiet',
              style: TextStyle(
                color: Colors.black,
                fontSize: AppBar().preferredSize.height / 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget page(BuildContext context, String path, String displayedName) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: SizedBox(
        height: AppBar().preferredSize.height,
        child: TextButton(
          onPressed: () {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.pushNamedAndRemoveUntil(context, path, (_) => false);
            });
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            child: Text(
              displayedName,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Actions {
  static List<Widget> actions(BuildContext context) {
    return [
      StreamBuilder(
        stream: accountManager.nameStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.data != accountManager.accountArguments.name) {
            accountManager.nameStreamController.add(accountManager.accountArguments.name);
            accountManager.oAuthTokenStreamController.add(accountManager.accountArguments.oAuthToken);
          }
          if (!snapshot.hasData) {
            return signInButton(context);
          } else {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                settingButton(context),
                signOutButton(context),
              ],
            );
          }
        },
      ),
    ];
  }

  static Widget signInButton(BuildContext context) {
    return IconButton(
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onPressed: () async {
        await HandleAccount.signIn(context);
      },
      icon: const Icon(Icons.login),
    );
  }

  static Widget signOutButton(BuildContext context) {
    return IconButton(
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onPressed: () async {
        await HandleAccount.signOut(context);
      },
      icon: const Icon(Icons.logout),
    );
  }

  static Widget settingButton(BuildContext context) {
    return IconButton(
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) {
            return _settingDialog(context);
          },
          barrierDismissible: true,
        );
      },
      icon: const Icon(Icons.settings),
    );
  }

  static Widget _settingDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('계정 설정'),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _padding(_patchAccountButton(context), 10, 10, 10, 10),
          _padding(_deleteAccountButton(context), 10, 10, 10, 10),
          _padding(_closeButton(context), 10, 10, 10, 0),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
  }

  static Widget _padding(Widget child, double left, double top, double right, double bottom) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: child,
    );
  }

  static Widget _patchAccountButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await HandleAccount.patch(context);
        if (context.mounted) Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        fixedSize: const Size(200.0, 50.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      child: const Text('닉네임 변경'),
    );
  }

  static Widget _deleteAccountButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await HandleAccount.delete(context);
        if (context.mounted) Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
        fixedSize: const Size(200.0, 50.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      child: const Text('회원 탈퇴'),
    );
  }

  static Widget _closeButton(BuildContext context) {
    return TextButton(
      onPressed: () async {
        Navigator.pop(context);
      },
      child: const Text('닫기'),
    );
  }
}

class CustomDrawer {
  static Widget widget(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    Map<String, String> pageMap = {
      '키토제닉이란?': '/info',
      '우리는 누구인가요?': '/about-us',
      '커뮤니티': '/community',
      '키토 챌린지': '/challenge',
      '개발자 도구': '/test',
    };

    List<String> pageList = pageMap.keys.toList();

    return Drawer(
      child: ListView.separated(
        separatorBuilder: (context, index) => const Divider(height: 0.0, thickness: 2.0),
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(pageList[index], style: const TextStyle(fontSize: 24.0)),
            contentPadding: const EdgeInsets.fromLTRB(15.0, 10.0, 0.0, 10.0),
            onTap: () {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                Navigator.pushNamedAndRemoveUntil(context, pageMap[pageList[index]]!, (_) => false);
              });
            },
          );
        },
        itemCount: pageList.length,
      ),
    );
  }
}
