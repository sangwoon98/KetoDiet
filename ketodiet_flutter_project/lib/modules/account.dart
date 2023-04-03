import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import '../modules/handle.dart';

Future<bool> getSignStatus(context) async {
  if (await AuthApi.instance.hasToken()) {
    try {
      await UserApi.instance.accessTokenInfo();
      return true;
    } catch (error) {
      if (error is KakaoException && error.isInvalidTokenError()) {
        try {
          OAuthToken? oldToken =
              await TokenManagerProvider.instance.manager.getToken();
          AuthApi.instance.refreshToken(oldToken: oldToken!);
          return true;
        } catch (error) {
          handleError(context, error, 'account.dart', 'getSignStatus');
          return false;
        }
      } else {
        handleError(context, error, 'account.dart', 'getSignStatus');
        return false;
      }
    }
  } else {
    return false;
  }
}

Future<OAuthToken?> getToken(context) async {
  try {
    final oAuthToken = await TokenManagerProvider.instance.manager.getToken();
    return oAuthToken;
  } catch (error) {
    handleError(context, error, 'account.dart', 'getToken');
  }
  return null;
}
