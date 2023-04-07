import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import '../secret.dart';
import '../modules/handle.dart';

AccountManager accountManager = AccountManager();

class AccountArgs {
  OAuthToken? oAuthToken;
  String? name;

  AccountArgs({this.oAuthToken, this.name});
}

class AccountManager {
  StreamController<OAuthToken?> oAuthTokenStreamController = StreamController<OAuthToken?>.broadcast();
  StreamController<String?> nameStreamController = StreamController<String?>.broadcast();
  AccountArgs accountArguments = AccountArgs();

  AccountManager() {
    oAuthTokenStreamController.stream.listen((event) {
      accountArguments.oAuthToken = event;
    });
    nameStreamController.stream.listen((event) {
      accountArguments.name = event;
    });
  }

  AccountArgs get() {
    return accountArguments;
  }

  void set({AccountArgs? accountArgs, OAuthToken? oAuthToken, String? name}) {
    if (accountArgs == null) {
      if (oAuthToken != null) {
        oAuthTokenStreamController.add(oAuthToken);
        accountArguments.oAuthToken = oAuthToken;
      }

      if (name != null) {
        nameStreamController.add(name);
        accountArguments.name = name;
      }
    } else {
      oAuthTokenStreamController.add(accountArgs.oAuthToken);
      nameStreamController.add(accountArgs.name);
      accountArgs.oAuthToken = oAuthToken;
      accountArguments.name = name;
    }
  }

  void clear() {
    oAuthTokenStreamController.add(null);
    nameStreamController.add(null);
  }
}

class HandleAccount {
  static Future<void> init() async {
    if (await AuthApi.instance.hasToken()) {
      OAuthToken? oAuthToken = await TokenManagerProvider.instance.manager.getToken();
      accountManager.set(oAuthToken: oAuthToken);

      if (accountManager.get().name is! String) {
        http.Response response = await http.get(
          Uri.http(backendDomain, '/api/account'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
          },
        );

        if (response.statusCode == 200) {
          accountManager.set(name: jsonDecode(response.body)['name']);
        } else {
          accountManager.clear();
          await TokenManagerProvider.instance.manager.clear();
        }
      }
    }
  }

  static Future<void> signIn(BuildContext context) async {
    if (await isKakaoTalkInstalled()) {
      try {
        accountManager.set(oAuthToken: await UserApi.instance.loginWithKakaoTalk());
      } catch (error) {
        errorManager.set(ErrorArgs('$error', 'handle.dart', 'HandleAccount.signIn'));
      }
    } else {
      try {
        accountManager.set(oAuthToken: await UserApi.instance.loginWithKakaoAccount());
      } catch (error) {
        errorManager.set(ErrorArgs('$error', 'handle.dart', 'HandleAccount.signIn'));
      }
    }

    if (context.mounted) await HandleError.ifErroredPushError(context);

    if (context.mounted) await get(context);
  }

  static Future<void> signOut(BuildContext context) async {
    accountManager.clear();
    if (await AuthApi.instance.hasToken()) {
      try {
        TokenManagerProvider.instance.manager.clear();
      } catch (error) {
        errorManager.set(ErrorArgs('$error', 'handle.dart', 'HandleAccount.signIn'));
      }
    }

    if (context.mounted) await HandleError.ifErroredPushError(context);
  }

  static Future<void> get(BuildContext context) async {
    OAuthToken? oAuthToken = await TokenManagerProvider.instance.manager.getToken();
    if (oAuthToken is! OAuthToken) {
      if (context.mounted) await signOut(context);
      return;
    }

    if (oAuthToken.refreshTokenExpiresAt is! DateTime) {
      if (context.mounted) await signIn(context);
    } else if (oAuthToken.refreshTokenExpiresAt!.difference(DateTime.now().add(const Duration(days: 7))).isNegative) {
      if (context.mounted) await signIn(context);
    } else if (oAuthToken.expiresAt.difference(DateTime.now().add(const Duration(minutes: 10))).isNegative) {
      try {
        oAuthToken = await AuthApi.instance.refreshToken(oldToken: oAuthToken);
        accountManager.set(oAuthToken: oAuthToken);
      } catch (error) {
        if (context.mounted) await signIn(context);
      }
    } else {
      accountManager.set(oAuthToken: oAuthToken);
    }

    if (accountManager.get().oAuthToken is OAuthToken) {
      http.Response response = await http.get(
        Uri.http(backendDomain, '/api/account'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
        },
      );

      if (response.statusCode == 200) {
        accountManager.set(name: jsonDecode(response.body)['name']);
      } else if (response.statusCode == 404) {
        if (context.mounted) await post(context);
      } else {
        errorManager.set(ErrorArgs('Response Status Code Error.\nStatusCode: ${response.statusCode}',
            'handle_account.dart', 'HandleAccount._getName'));
        if (context.mounted) await signOut(context);
      }
    } else {
      if (context.mounted) await signOut(context);
    }
  }

  static Future<void> post(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return SetNameWidget.post(context);
      },
      barrierDismissible: false,
    );
  }

  static Future<void> patch(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return SetNameWidget.patch(context);
      },
      barrierDismissible: false,
    );
  }

  static Future<void> delete(BuildContext context) async {
    accountManager.clear();
    if (await AuthApi.instance.hasToken()) {
      try {
        await UserApi.instance.unlink();
      } catch (error) {
        errorManager.set(ErrorArgs('$error', 'handle.dart', 'HandleAccount.delete'));
      }
    }

    if (context.mounted) await HandleError.ifErroredPushError(context);
  }
}

class SetNameWidget {
  static final registerController = TextEditingController();
  static final registerKey = GlobalKey<FormState>();
  static bool? registerValidator;

  static Widget post(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _padding(_welcomeText(), 10, 10, 10, 10),
          _padding(_explainText(), 10, 10, 10, 10),
          _padding(_textField(), 10, 10, 10, 10),
          _padding(_postButtons(context), 10, 10, 10, 10),
        ],
      ),
    );
  }

  static Widget patch(BuildContext context) {
    return AlertDialog(
      title: const Text('닉네임 변경'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _padding(_textField(), 10, 10, 10, 10),
          _padding(_patchButtons(context), 10, 10, 10, 10),
        ],
      ),
    );
  }

  static Widget _padding(Widget child, double left, double top, double right, double bottom) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: child,
    );
  }

  static Widget _welcomeText() {
    return const Text(
      '환영합니다!',
      style: TextStyle(
        color: Colors.green,
        fontSize: 60.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static Widget _explainText() {
    return const Text(
      'KetoDiet에 처음 방문하셨네요\n닉네임을 설정해주세요',
      style: TextStyle(
        fontSize: 20.0,
      ),
      textAlign: TextAlign.center,
    );
  }

  static Widget _textField() {
    return SizedBox(
      width: 300.0,
      child: Form(
        key: registerKey,
        child: TextFormField(
          controller: registerController,
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
            } else if (registerValidator == false) {
              return '이미 존재하는 닉네임입니다.';
            }

            return null;
          },
        ),
      ),
    );
  }

  static Widget _postButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () async {
            await HandleAccount.signOut(context);
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.pop(context);
            });
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            fixedSize: const Size(145.0, 40.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Text('취소'),
        ),
        const SizedBox(width: 10.0),
        ElevatedButton(
          onPressed: () async {
            registerValidator = null;
            if (registerKey.currentState!.validate()) {
              http.Response response = await http.post(
                Uri.http(backendDomain, '/api/account'),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
                },
                body: jsonEncode({
                  'name': registerController.text,
                }),
              );

              if (response.statusCode == 201) {
                accountManager.set(name: registerController.text);
                registerValidator = true;
              } else if (response.statusCode == 409) {
                registerValidator = false;
              } else {
                errorManager.set(ErrorArgs('Response Status Code Error.\nStatusCode: ${response.statusCode}',
                    'handle_account.dart', 'RegisterWidget._submitButton'));
                registerValidator = false;
              }

              if (context.mounted) await HandleError.ifErroredPushError(context);
            }
            if (registerKey.currentState!.validate()) {
              accountManager.set(name: registerController.text);
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                Navigator.pop(context);
              });
            }
          },
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(145.0, 40.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Text('확인'),
        ),
      ],
    );
  }

  static Widget _patchButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () async {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.pop(context);
            });
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            fixedSize: const Size(145.0, 40.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Text('취소'),
        ),
        const SizedBox(width: 10.0),
        ElevatedButton(
          onPressed: () async {
            registerValidator = null;
            if (registerKey.currentState!.validate()) {
              http.Response response = await http.patch(
                Uri.http(backendDomain, '/api/account'),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
                },
                body: jsonEncode({
                  'name': registerController.text,
                }),
              );

              if (response.statusCode == 200) {
                accountManager.set(name: registerController.text);
                registerValidator = true;
              } else if (response.statusCode == 409) {
                registerValidator = false;
              } else {
                errorManager.set(ErrorArgs('Response Status Code Error.\nStatusCode: ${response.statusCode}',
                    'handle_account.dart', 'RegisterWidget._submitButton'));
                registerValidator = false;
              }

              if (context.mounted) HandleError.ifErroredPushError(context);
            }
            if (registerKey.currentState!.validate()) {
              accountManager.set(name: registerController.text);
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                Navigator.pop(context);
              });
            }
          },
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(145.0, 40.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Text('확인'),
        ),
      ],
    );
  }
}
