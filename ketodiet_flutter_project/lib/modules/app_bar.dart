import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import '../modules/account.dart';
import '../modules/handle.dart';
import '../secret.dart';

AppBar appBar(context) {
  return AppBar(
    automaticallyImplyLeading: false,
    toolbarHeight: AppBar().preferredSize.height,
    title: Row(
      children: [
        PageButton().home(context),
        PageButton().page(context, '/about-us', '우리는 누구인가요?'),
        PageButton().page(context, '/info', '키토제닉이란?'),
        PageButton().page(context, '/community', '커뮤니티'),
        PageButton().page(context, '/challenge', '키토 챌린지'),
        PageButton().page(context, '/test', '개발자 도구'),
      ],
    ),
    actions: Actions().buttons(context),
  );
}

class PageButton {
  Widget home(context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: SizedBox(
        height: AppBar().preferredSize.height,
        child: TextButton(
          onPressed: () {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.pushReplacementNamed(context, '/');
            });
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(0.0, 2.0, 4.0, 2.0),
                  child: Image(
                    image: AssetImage('assets/images/beef.png'),
                  ),
                ),
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
        ),
      ),
    );
  }

  Widget page(context, String path, String displayedName) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: SizedBox(
        height: AppBar().preferredSize.height,
        child: TextButton(
          onPressed: () {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.pushReplacementNamed(context, path);
            });
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
  final _signStreamController = StreamController.broadcast();

  void updateSignStatus(context) async {
    try {
      _signStreamController.add(await getSignStatus(context));
    } catch (e) {
      await handleError(context, e, 'app_bar.dart', 'Actions.updateSignStatus');
    }
  }

  Widget signInButton(context) {
    return TextButton(
      onPressed: () async {
        await Navigator.pushNamed(context, '/sign',
            arguments: SignArgs('signIn'));
        updateSignStatus(context);
      },
      child: const Text(
        'Sign In',
        style: TextStyle(color: Colors.white),
        // TODO: SignInButton 디자인
      ),
    );
  }

  Widget signOutButton(context) {
    return TextButton(
      onPressed: () async {
        await Navigator.pushNamed(context, '/sign',
            arguments: SignArgs('signOut'));
        updateSignStatus(context);
      },
      child: const Text(
        'Sign Out',
        style: TextStyle(color: Colors.white),
        // TODO: signOutButton 디자인
      ),
    );
  }

  List<Widget> buttons(context) {
    updateSignStatus(context);
    return [
      StreamBuilder(
        stream: _signStreamController.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == true) {
              return Row(
                children: [
                  Settings().button(context),
                  signOutButton(context),
                ],
              );
            } else if (snapshot.data == false) {
              return signInButton(context);
            }
          }

          return const SizedBox();
        },
      ),
    ];
  }
}

class Settings {
  Widget button(context) {
    // TODO: settingButton 디자인
    return IconButton(
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onPressed: () {
        _showDialog(context);
      },
      icon: const Icon(Icons.settings),
    );
  }

  Future<dynamic> _showDialog(context) {
    return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('계정 설정'),
          content: contents(context),
          actions: [
            closeButton(context),
          ],
        );
      },
    );
  }

  Widget contents(context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        padding(ModifyName().button(context), 0, 0, 0, 10),
        padding(Unregister().button(context), 0, 10, 0, 0),
      ],
    );
  }

  Widget padding(child, left, top, right, bottom) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: child,
    );
  }

  Widget closeButton(context) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text(
        '닫기',
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}

class ModifyName {
  final modifyController = TextEditingController();
  final modifyKey = GlobalKey<FormState>();
  bool? modifyValidator;

  Widget button(context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Text('닉네임 변경'),
              content: form(context),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '취소',
                    style: TextStyle(color: Colors.black45),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    modifyValidator = null;
                    if (modifyKey.currentState!.validate()) {
                      OAuthToken? token = await getToken(context);
                      http.Response response = await http.put(
                        Uri.http(backendDomain, '/api/account'),
                        headers: {
                          'Content-Type': 'application/json',
                          'Accept': 'application/json',
                          'Authorization': '${token!.toJson()}',
                        },
                        body: jsonEncode({
                          'name': modifyController.text,
                        }),
                      );

                      if (response.statusCode == 200) {
                        modifyValidator = true;
                      } else if (response.statusCode == 409) {
                        modifyValidator = false;
                      } else {
                        modifyValidator = false;
                        await handleError(
                          context,
                          'Response Status Code Error.\nStatusCode: ${response.statusCode}',
                          'app_bar.dart',
                          'ModifyName.button',
                        );
                      }
                    }
                    if (modifyKey.currentState!.validate()) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    '확인',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        fixedSize: const Size(200.0, 50.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
      child: const Text('닉네임 변경'),
    );
  }

  Widget form(context) {
    return SizedBox(
      width: 300.0,
      child: Form(
        key: modifyKey,
        child: TextFormField(
          controller: modifyController,
          decoration: const InputDecoration(
            labelText: '닉네임',
            hintText: '2글자 이상, 12글자 이하로 입력해주세요',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '닉네임을 입력 해주세요';
            } else if (value.length < 2 || value.length > 12) {
              return '닉네임은 2~12글자만 가능합니다.';
            } else if (modifyValidator == false) {
              return '이미 존재하는 닉네임입니다.';
            }

            return null;
          },
        ),
      ),
    );
  }
}

class Unregister {
  Widget button(context) {
    return ElevatedButton(
      onPressed: () async {
        http.Response response = await http.delete(
          Uri.http(backendDomain, '/api/account'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': '${(await getToken(context))!.toJson()}',
          },
        );

        if (response.statusCode == 200) {
          try {
            await UserApi.instance.unlink();
            await Navigator.pushNamedAndRemoveUntil(
                context, '/', (route) => false);
          } catch (e) {
            await handleError(context, e, 'app_bar', 'Unregister.button');
          }
        } else {
          await handleError(
              context,
              'Response Status Code Error.\nStatusCode: ${response.statusCode}',
              'app_bar',
              'Unregister.button');
        }
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
        fixedSize: const Size(200.0, 50.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
      child: const Text('회원 탈퇴'),
    );
  }
}
