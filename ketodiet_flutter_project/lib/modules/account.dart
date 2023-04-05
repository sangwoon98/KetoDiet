import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import '../secret.dart';
import '../modules/handle.dart';

Future<bool> getSignStatus(context) async {
  if (await getTokenStatus(context)) {
    OAuthToken? token = await getToken(context);
    http.Response response = await http.get(
      Uri.http(backendDomain, '/api/account'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '${token!.toJson()}',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      dropToken(context);
      return false;
    }
  } else {
    return false;
  }
}

Future<bool> getTokenStatus(context) async {
  if (await AuthApi.instance.hasToken()) {
    try {
      await UserApi.instance.accessTokenInfo();
    } catch (error) {
      if (error is KakaoException && error.isInvalidTokenError()) {
        try {
          OAuthToken? oldToken = await getToken(context);
          await AuthApi.instance.refreshToken(oldToken: oldToken!);
        } catch (error) {
          await handleError(context, error, 'account.dart', 'getTokenStatus');
          return false;
        }
      } else {
        await handleError(context, error, 'account.dart', 'getTokenStatus');
        return false;
      }
    }
  } else {
    return false;
  }

  return true;
}

Future<OAuthToken?> getToken(context) async {
  try {
    return await TokenManagerProvider.instance.manager.getToken();
  } catch (error) {
    await handleError(context, error, 'account.dart', 'getToken');
  }
  return null;
}

Future<void> dropToken(context) async {
  try {
    await UserApi.instance.logout();
  } catch (error) {
    await handleError(context, error, 'account.dart', 'dropToken');
  }
}
