import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../modules/handle.dart';
import '../secret.dart';

class ChallengeArgs {
  String gender; // 성별
  double height; // 키
  double weight; // 몸무게
  bool knowBodyFat; // 체지방률을 알고있는가?
  double bodyFat; // 체지방량
  // 안다면 바로 기입, 모른다면 아래 값 가지고 계산
  double neck; // 목둘레
  double waist; // 허리둘레
  double hip; // 엉덩이둘레
  double activityLevel; // 활동량 수치
  // (1.2: 앉아서 일하는 일반적인 직종, 1.375: 약간 활동적인 직종, 1.55: 활발한 직종, 1.725: 매우 활발한 직종, 1.9: 매우 힘든 노동 직종)
  late double bmr; // 기초 대사량
  late double totalEnergy; // 총 소모 에너지
  late double carbs; // 탄수화물
  late double protein; // 단백질
  late double fat; // 지방

  ChallengeArgs({
    required this.gender,
    required this.height,
    required this.weight,
    required this.knowBodyFat,
    this.bodyFat = 0.0,
    this.neck = 0.0,
    this.waist = 0.0,
    this.hip = 0.0,
    required this.activityLevel,
  }) {
    if (!knowBodyFat) {
      if (gender == 'male') {
        bodyFat = 495 / (1.0324 - 0.19077 * log(waist - neck) + 0.15456 * log(height)) - 450;
      } else {
        bodyFat = 495 / (1.29579 - 0.35004 * log(waist + hip - neck) + 0.22100 * log(height)) - 450;
      }
    }

    final double lbm = (weight - (weight * (bodyFat / 100)));

    bmr = 370.0 + (21.6 * lbm);
    totalEnergy = bmr * activityLevel;
    carbs = 20.0;
    protein = 2.2 * lbm;
    fat = (totalEnergy - (4 * protein) - (4 * 20)) / 9;
  }

  static ChallengeArgs setChallengeArgs({
    required String gender,
    required String age,
    required String height,
    required String weight,
    required bool knowBodyFat,
    String? bodyFat,
    String? neck,
    String? waist,
    String? hip,
    required double activityLevel,
  }) {
    if (knowBodyFat) {
      return ChallengeArgs(
        gender: gender,
        height: double.parse(height),
        weight: double.parse(weight),
        knowBodyFat: knowBodyFat,
        bodyFat: double.parse(bodyFat!),
        activityLevel: activityLevel,
      );
    } else {
      return ChallengeArgs(
        gender: gender,
        height: double.parse(height),
        weight: double.parse(weight),
        knowBodyFat: knowBodyFat,
        neck: double.parse(neck!),
        waist: double.parse(waist!),
        hip: double.parse(hip!),
        activityLevel: activityLevel,
      );
    }
  }
}

class HandleChallenge {
  static int getBodyFat(String gender, double height, double neck, double waist, double hip) {
    if (gender == 'male') {
      double result = (495 / (1.0324 - 0.19077 * _log10(waist - neck) + 0.15456 * _log10(height)) - 450);

      if (result.isNaN) {
        return -1;
      } else {
        return result.round();
      }
    } else {
      double result = (495 / (1.29579 - 0.35004 * _log10(waist + hip - neck) + 0.22100 * _log10(height)) - 450);

      if (result.isNaN) {
        return -1;
      } else {
        return result.round();
      }
    }
  }

  static int getBMR(double weight, int bodyFat) {
    return (370.0 + (21.6 * (weight - (weight * (bodyFat / 100))))).round();
  }

  static int getTotalEnergy(int bmr, double activityLevel) {
    return (bmr * activityLevel).round();
  }

  static Map<String, int> getNormalIntake(double weight, int bodyFat, int totalEnergy) {
    int carbs = 20;
    int protein = (2.2 * (weight - (weight * (bodyFat / 100)))).round();
    int fat = ((totalEnergy - (4 * protein) - (4 * 20)) / 9).round();

    return {'carbs': carbs, 'protein': protein, 'fat': fat};
  }

  static int getFatIntake(double weight, int bodyFat, int totalEnergy) {
    return ((totalEnergy - (4 * (2.2 * (weight - (weight * (bodyFat / 100)))).round()) - (4 * 20)) / 9).round();
  }

  static double _log10(double num) {
    return log(num) / ln10;
  }

  static Future<List> getChallenge() async {
    http.Response response = await http.get(
      Uri.http(backendDomain, '/api/challenge'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      errorManager.set(ErrorArgs('Response Status Code Error.\nStatusCode: ${response.statusCode}',
          'handle_challenge.dart', 'HandleChallenge.getChallenge'));
    }

    return [];
  }

  static Future<bool> postChallenge(Map query) async {
    Map data = {
      'gender': query['gender'],
      'height': query['height'],
      'weight': query['weight'],
      'knowBodyFat': query['knowBodyFat'],
      'neck': query.containsKey('neck') ? query['neck'] : null,
      'waist': query.containsKey('waist') ? query['waist'] : null,
      'hip': query.containsKey('hip') ? query['hip'] : null,
      'bodyFat': query['bodyFat'],
      'bmr': query['bmr'],
      'activityLevel': query['activityLevel'],
      'totalEnergy': query['totalEnergy'],
      'carbs': query['carbs'],
      'protein': query['protein'],
      'fat': query['fat'],
      'activity': query['activity'],
      'change': query.containsKey('change') ? query['change'] : null,
    };

    http.Response response = await http.post(
      Uri.http(backendDomain, '/api/challenge'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '${accountManager.get().oAuthToken!.toJson()}',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      errorManager.set(ErrorArgs('Response Status Code Error.\nStatusCode: ${response.statusCode}',
          'handle_challenge.dart', 'HandleChallenge.postChallenge'));
      return false;
    }
  }

  static Future<bool> postEmail(String email, Uint8List image) async {
    http.Response response = await http.post(
      Uri.http(backendDomain, '/api/challenge/email'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(
        {
          'email': email,
          'image': base64.encode(image),
        },
      ),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      errorManager.set(ErrorArgs('Response Status Code Error.\nStatusCode: ${response.statusCode}',
          'handle_challenge.dart', 'HandleChallenge.postChallenge'));
      return false;
    }
  }
}
