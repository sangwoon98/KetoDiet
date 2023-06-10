import 'dart:io';
import 'dart:math';

void main(List<String> args) {
  stdout.write('성별 (male or female)을 입력하세요: ');
  String gender = stdin.readLineSync().toString();
  stdout.write('나이(만)를 입력하세요: ');
  int age = int.parse(stdin.readLineSync()!);
  stdout.write('체중(kg)을 입력하세요: ');
  double weight = double.parse(stdin.readLineSync()!);
  stdout.write('키(cm)을 입력하세요: ');
  double height = double.parse(stdin.readLineSync()!);
  stdout.write('본인의 체지방률을 알고 계신가요? (true or false): ');
  bool knowBodyFat = stdin.readLineSync().toString() == 'true' ? true : false;
  late double bodyFat;
  late double neck;
  late double waist;
  late double hip;
  if (knowBodyFat) {
    stdout.write('체지방률(%)를 입력하세요: ');
    bodyFat = double.parse(stdin.readLineSync()!);
  } else {
    stdout.write('목둘레(cm)를 입력하세요: ');
    neck = double.parse(stdin.readLineSync()!);
    stdout.write('허리둘레(cm)를 입력하세요: ');
    waist = double.parse(stdin.readLineSync()!);
    stdout.write('엉덩이둘레(cm)를 입력하세요: ');
    hip = double.parse(stdin.readLineSync()!);
  }
  stdout.write(
      '활동량 수치(1.2:앉아서 일하는 일반적인 직종, 1.375:약간 활동적인 직종, 1.55:활발한 직종, 1.725:매우 활발한 직종, 1.9:매우 힘든 노동을 하는 경우)을 입력하세요: ');
  double activityLevel = double.parse(stdin.readLineSync()!);

  late ChallengeArgs challengeArgs;

  if (knowBodyFat) {
    challengeArgs = ChallengeArgs(
      gender: gender,
      age: age,
      weight: weight,
      height: height,
      knowBodyFat: knowBodyFat,
      bodyFat: bodyFat,
      activityLevel: activityLevel,
    );
  } else {
    challengeArgs = ChallengeArgs(
      gender: gender,
      age: age,
      weight: weight,
      height: height,
      knowBodyFat: knowBodyFat,
      neck: neck,
      waist: waist,
      hip: hip,
      activityLevel: activityLevel,
    );
  }

  print('\n\n');
  challengeArgs.resultPrint();
}

class ChallengeArgs {
  String gender; // 성별
  int age; // 나이(만)
  double weight; // 몸무게
  double height; // 키
  bool knowBodyFat; // 체지방률을 알고있는가?
  // 안다면 바로 기입, 모른다면 아래 값 가지고 계산
  double bodyFat; // 체지방량
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
    required this.age,
    required this.weight,
    required this.height,
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

    if (gender == 'male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    totalEnergy = bmr * activityLevel;

    carbs = 20.0;
    protein = 2.2 * weight;
    fat = (totalEnergy - (4 * protein) - (4 * 20)) / 9;
  }

  void resultPrint() {
    print(bodyFat);
    print('기초 대사량: ${bmr}kcal');
    print('활동 대사량: ${totalEnergy - bmr}kcal');
    print('총 소모 에너지: ${totalEnergy}kcal');
    print('권장 탄수화물 섭취량: ${carbs}g');
    print('권장 단백질 섭취량: ${protein}g');
    print('권장 지방 섭취량: ${fat}g');
  }
}
