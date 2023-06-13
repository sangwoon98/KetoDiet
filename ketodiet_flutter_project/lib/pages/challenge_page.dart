import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';

import '../modules/handle.dart';
import '../modules/layout.dart';

class ChallengePage extends StatefulWidget {
  final Map<String, dynamic> query;
  final GlobalKey<FormState> firstFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> secondKnowBodyFatFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> secondNotKnowBodyFatFormKey = GlobalKey<FormState>();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController knowBodyFatController = TextEditingController();
  final StreamController knowBodyFatStreamController = StreamController.broadcast();
  final TextEditingController bodyFatController = TextEditingController();
  final TextEditingController neckController = TextEditingController();
  final TextEditingController waistController = TextEditingController();
  final TextEditingController hipController = TextEditingController();

  ChallengePage(this.query, {super.key});

  @override
  State<ChallengePage> createState() => _ChallengePageState();

  static Widget card(BuildContext context, Widget child) {
    double deviceSize = MediaQuery.of(context).size.width;

    return CustomScaffold.scaffold(
      context: context,
      body: SingleChildScrollView(
        padding:
            deviceSize >= 1024 ? EdgeInsets.only(left: (deviceSize - 1024) / 2, right: (deviceSize - 1024) / 2) : null,
        child: Card(
          color: Colors.white,
          elevation: 8.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: child,
        ),
      ),
    );
  }
}

class _ChallengePageState extends State<ChallengePage> {
  @override
  void initState() {
    if (widget.query.keys.length > 1 || (widget.query.keys.length == 1 && !widget.query.containsKey('additional'))) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushNamedAndRemoveUntil(context, '/challenge', (_) => false);
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.query.containsKey('additional')) {
      Map additionalQuery = widget.query['additional'];
      switch (additionalQuery['screen']) {
        case 'FirstStep':
          return FirstStepScreen.widget(
            context,
            additionalQuery,
            widget.firstFormKey,
            widget.secondKnowBodyFatFormKey,
            widget.secondNotKnowBodyFatFormKey,
            widget.genderController,
            widget.heightController,
            widget.weightController,
            widget.knowBodyFatController,
            widget.knowBodyFatStreamController,
            widget.bodyFatController,
            widget.neckController,
            widget.waistController,
            widget.hipController,
          );
        case 'SecondStep':
          return SecondStepScreen.widget(context, additionalQuery);
        case 'Result':
          return ResultScreen.widget(context, additionalQuery);
        default:
          return StartScreen.widget(context);
      }
    } else {
      return StartScreen.widget(context);
    }
  }
}

class StartScreen {
  static Widget widget(BuildContext context) {
    return CustomScaffold.scaffold(
      context: context,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '키토 챌린지 계산기로\n본인의 적정 섭취량을 계산해보세요!',
                style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder(
                      stream: accountManager.nameStreamController.stream,
                      builder: (context, snapshot) {
                        if (snapshot.data != accountManager.accountArguments.name) {
                          accountManager.nameStreamController.add(accountManager.accountArguments.name);
                          accountManager.oAuthTokenStreamController.add(accountManager.accountArguments.oAuthToken);
                        }
                        return Visibility(
                          visible: accountManager.accountArguments.name != null ? true : false,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: SizedBox(
                              width: 200.0,
                              height: 40.0,
                              child: ElevatedButton(
                                onPressed: () async {
                                  getChallengeDialog(context, await HandleChallenge.getChallenge());
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                child: const Text('계산결과 불러오기'),
                              ),
                            ),
                          ),
                        );
                      }),
                  SizedBox(
                    width: 200.0,
                    height: 40.0,
                    child: ElevatedButton(
                      onPressed: () {
                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                          Navigator.pushNamedAndRemoveUntil(context, '/challenge', (_) => false,
                              arguments: {'screen': 'FirstStep'});
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: const Text('계산하러 가기'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static getChallengeDialog(BuildContext context, List dataList) {
    List<Widget> list = [];

    for (var element in dataList) {
      var height = element['height'].toString();
      var weight = element['weight'].toString();
      DateTime dateTime = DateTime.parse(element['dateTime']);

      Map data = {'screen': 'Result'};
      data.addAll(element);

      list.add(Padding(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
        child: ElevatedButton(
          onPressed: () {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.pushNamedAndRemoveUntil(context, '/challenge', (_) => false, arguments: data);
            });
          },
          child: Row(
            children: [
              Expanded(child: Text('${height}cm | ${weight}kg')),
              Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime)),
            ],
          ),
        ),
      ));
    }

    late Widget content;

    if (list.isEmpty) {
      content = const Center(
        child: Text('저장된 데이터가 없습니다.', style: TextStyle(color: Colors.grey)),
      );
    } else {
      content = ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return list[index];
        },
        itemCount: list.length,
      );
    }

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '저장된 계산결과 불러오기',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          content: SizedBox(width: 400.0, height: 300.0, child: content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기', style: TextStyle(color: Colors.red)),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        );
      },
      barrierDismissible: true,
    );
  }
}

class FirstStepScreen {
  static Widget widget(
    BuildContext context,
    Map query,
    GlobalKey<FormState> firstFormKey,
    GlobalKey<FormState> secondKnowBodyFatFormKey,
    GlobalKey<FormState> secondNotKnowBodyFatFormKey,
    TextEditingController genderController,
    TextEditingController heightController,
    TextEditingController weightController,
    TextEditingController knowBodyFatController,
    StreamController knowBodyFatStreamController,
    TextEditingController bodyFatController,
    TextEditingController neckController,
    TextEditingController waistController,
    TextEditingController hipController,
  ) {
    double deviceSize = MediaQuery.of(context).size.width;

    if (query.keys.length > 1) {
      genderController.text = query['gender'];
      heightController.text = query['height'].toString();
      weightController.text = query['weight'].toString();
      knowBodyFatController.text = query['knowBodyFat'] ? 'true' : 'false';
      bodyFatController.text = query['bodyFat'].toString();
      neckController.text = query['neck'].toString();
      waistController.text = query['waist'].toString();
      hipController.text = query['hip'].toString();
    }

    return ChallengePage.card(
      context,
      deviceSize >= tablet
          ? Column(
              children: [
                IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child:
                              _firstColumn(context, firstFormKey, genderController, heightController, weightController),
                        ),
                        const VerticalDivider(),
                        Expanded(
                          child: _secondColumn(
                            context,
                            secondKnowBodyFatFormKey,
                            secondNotKnowBodyFatFormKey,
                            knowBodyFatController,
                            knowBodyFatStreamController,
                            bodyFatController,
                            neckController,
                            waistController,
                            hipController,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      Flexible(
                        flex: 0,
                        child: _nextStepButton(
                          context,
                          firstFormKey,
                          secondKnowBodyFatFormKey,
                          secondNotKnowBodyFatFormKey,
                          genderController,
                          heightController,
                          weightController,
                          knowBodyFatController,
                          knowBodyFatStreamController,
                          bodyFatController,
                          neckController,
                          waistController,
                          hipController,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      _firstColumn(context, firstFormKey, genderController, heightController, weightController),
                      _secondColumn(
                        context,
                        secondKnowBodyFatFormKey,
                        secondNotKnowBodyFatFormKey,
                        knowBodyFatController,
                        knowBodyFatStreamController,
                        bodyFatController,
                        neckController,
                        waistController,
                        hipController,
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      _nextStepButton(
                        context,
                        firstFormKey,
                        secondKnowBodyFatFormKey,
                        secondNotKnowBodyFatFormKey,
                        genderController,
                        heightController,
                        weightController,
                        knowBodyFatController,
                        knowBodyFatStreamController,
                        bodyFatController,
                        neckController,
                        waistController,
                        hipController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  static Widget _firstColumn(
      BuildContext context,
      GlobalKey<FormState> firstFormKey,
      TextEditingController genderController,
      TextEditingController heightController,
      TextEditingController weightController) {
    return Form(
      key: firstFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          _genderSelectButton(context, genderController),
          _heightTextField(context, heightController),
          _weightTextField(context, weightController),
        ],
      ),
    );
  }

  static Widget _secondColumn(
    BuildContext context,
    GlobalKey<FormState> secondKnowBodyFatFormKey,
    GlobalKey<FormState> secondNotKnowBodyFatFormKey,
    TextEditingController knowBodyFatController,
    StreamController knowBodyFatStreamController,
    TextEditingController bodyFatController,
    TextEditingController neckController,
    TextEditingController waistController,
    TextEditingController hipController,
  ) {
    return StreamBuilder(
      stream: knowBodyFatStreamController.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) knowBodyFatStreamController.add(knowBodyFatController.text);

        if (knowBodyFatController.text == 'true') {
          neckController.clear();
          waistController.clear();
          hipController.clear();
          return Form(
            key: secondKnowBodyFatFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                _knowBodyFatSelectButton(context, knowBodyFatController, knowBodyFatStreamController),
                _bodyFatTextField(context, bodyFatController),
              ],
            ),
          );
        } else if (knowBodyFatController.text == 'false') {
          bodyFatController.clear();
          return Form(
            key: secondNotKnowBodyFatFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                _knowBodyFatSelectButton(context, knowBodyFatController, knowBodyFatStreamController),
                _neckTextField(context, neckController),
                _waistTextField(context, waistController),
                _hipTextField(context, hipController),
              ],
            ),
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              _knowBodyFatSelectButton(context, knowBodyFatController, knowBodyFatStreamController),
            ],
          );
        }
      },
    );
  }

  static Widget _genderSelectButton(BuildContext context, TextEditingController genderController) {
    final StreamController streamController = StreamController.broadcast();
    return StreamBuilder(
      stream: streamController.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) streamController.add(genderController.text);
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('당신의 성별은?', style: TextStyle(color: Colors.green)),
              const SizedBox(height: 4.0),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40.0,
                      child: ElevatedButton(
                        onPressed: () {
                          genderController.text = 'male';
                          streamController.add('male');
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: snapshot.data == 'male' ? Colors.white : Colors.black,
                          backgroundColor: snapshot.data == 'male' ? Colors.green : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text('남성'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: SizedBox(
                      height: 40.0,
                      child: ElevatedButton(
                        onPressed: () {
                          genderController.text = 'female';
                          streamController.add('female');
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: snapshot.data == 'female' ? Colors.white : Colors.black,
                          backgroundColor: snapshot.data == 'female' ? Colors.green : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text('여성'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _heightTextField(BuildContext context, TextEditingController heightController) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('당신의 키는?', style: TextStyle(color: Colors.green)),
          const SizedBox(height: 4.0),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: heightController,
                  decoration: const InputDecoration(
                    suffixIcon: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('cm'),
                    ),
                    suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '값을 입력해주세요.';
                    } else if (double.tryParse(value) is! double) {
                      return '숫자 및 소수점만 입력해주세요.';
                    } else if (double.parse(value) <= 0.0) {
                      return '양수만 입력해주세요.';
                    } else {
                      return null;
                    }
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _weightTextField(BuildContext context, TextEditingController weightController) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('당신의 몸무게는?', style: TextStyle(color: Colors.green)),
          const SizedBox(height: 4.0),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    suffixIcon: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('kg'),
                    ),
                    suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '값을 입력해주세요.';
                    } else if (double.tryParse(value) is! double) {
                      return '숫자 및 소수점만 입력해주세요.';
                    } else if (double.parse(value) <= 0.0) {
                      return '양수만 입력해주세요.';
                    } else {
                      return null;
                    }
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _knowBodyFatSelectButton(
      BuildContext context, TextEditingController knowBodyFatController, StreamController knowBodyFatStreamController) {
    return StreamBuilder(
      stream: knowBodyFatStreamController.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) knowBodyFatStreamController.add(knowBodyFatController.text);

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('당신의 체지방률(%)를 알고있나요?', style: TextStyle(color: Colors.green)),
              const SizedBox(height: 4.0),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40.0,
                      child: ElevatedButton(
                        onPressed: () {
                          if (snapshot.data != true) {
                            knowBodyFatStreamController.add('true');
                            knowBodyFatController.text = 'true';
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: knowBodyFatController.text == 'true' ? Colors.white : Colors.black,
                          backgroundColor: knowBodyFatController.text == 'true' ? Colors.green : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text('예'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: SizedBox(
                      height: 40.0,
                      child: ElevatedButton(
                        onPressed: () {
                          if (snapshot.data != false) {
                            knowBodyFatStreamController.add('false');
                            knowBodyFatController.text = 'false';
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: knowBodyFatController.text == 'false' ? Colors.white : Colors.black,
                          backgroundColor: knowBodyFatController.text == 'false' ? Colors.green : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: const Text('아니요'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _bodyFatTextField(BuildContext context, TextEditingController bodyFatController) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('당신의 체지방률은?', style: TextStyle(color: Colors.green)),
          const SizedBox(height: 4.0),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: bodyFatController,
                  decoration: const InputDecoration(
                    suffixIcon: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('%'),
                    ),
                    suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '값을 입력해주세요.';
                    } else if (int.tryParse(value) is! int) {
                      return '정수만 입력해주세요.';
                    } else if (int.parse(value) < 0 || int.parse(value) > 100) {
                      return '0 부터 100 까지만 입력해주세요.';
                    } else {
                      return null;
                    }
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _neckTextField(BuildContext context, TextEditingController neckController) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('당신의 목 둘레는?', style: TextStyle(color: Colors.green)),
          const SizedBox(height: 4.0),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: neckController,
                  decoration: const InputDecoration(
                    suffixIcon: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('cm'),
                    ),
                    suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '값을 입력해주세요.';
                    } else if (double.tryParse(value) is! double) {
                      return '숫자 및 소수점만 입력해주세요.';
                    } else if (double.parse(value) <= 0.0) {
                      return '양수만 입력해주세요.';
                    } else {
                      return null;
                    }
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _waistTextField(BuildContext context, TextEditingController waistController) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('당신의 허리 둘레는?', style: TextStyle(color: Colors.green)),
          const SizedBox(height: 4.0),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: waistController,
                  decoration: const InputDecoration(
                    suffixIcon: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('cm'),
                    ),
                    suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '값을 입력해주세요.';
                    } else if (double.tryParse(value) is! double) {
                      return '숫자 및 소수점만 입력해주세요.';
                    } else if (double.parse(value) <= 0.0) {
                      return '양수만 입력해주세요.';
                    } else {
                      return null;
                    }
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _hipTextField(BuildContext context, TextEditingController hipController) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('당신의 엉덩이 둘레는?', style: TextStyle(color: Colors.green)),
          const SizedBox(height: 4.0),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: hipController,
                  decoration: const InputDecoration(
                    suffixIcon: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('cm'),
                    ),
                    suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return '값을 입력해주세요.';
                    } else if (double.tryParse(value) is! double) {
                      return '숫자 및 소수점만 입력해주세요.';
                    } else if (double.parse(value) <= 0.0) {
                      return '양수만 입력해주세요.';
                    } else {
                      return null;
                    }
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _nextStepButton(
    BuildContext context,
    GlobalKey<FormState> firstFormKey,
    GlobalKey<FormState> secondKnowBodyFatFormKey,
    GlobalKey<FormState> secondNotKnowBodyFatFormKey,
    TextEditingController genderController,
    TextEditingController heightController,
    TextEditingController weightController,
    TextEditingController knowBodyFatController,
    StreamController knowBodyFatStreamController,
    TextEditingController bodyFatController,
    TextEditingController neckController,
    TextEditingController waistController,
    TextEditingController hipController,
  ) {
    return SizedBox(
      width: 150.0,
      height: 40.0,
      child: ElevatedButton(
          onPressed: () {
            if (genderController.text.isEmpty) {
              _dialog(context, '성별을 선택해주세요.');
            } else if (knowBodyFatController.text.isEmpty) {
              _dialog(context, '체지방률 입력 방법을 선택해주세요.');
            } else {
              if (knowBodyFatController.text == 'true') {
                if (firstFormKey.currentState!.validate() && secondKnowBodyFatFormKey.currentState!.validate()) {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    Navigator.pushNamedAndRemoveUntil(context, '/challenge', (_) => false, arguments: {
                      'screen': 'SecondStep',
                      'gender': genderController.text,
                      'height': double.parse(heightController.text),
                      'weight': double.parse(weightController.text),
                      'knowBodyFat': true,
                      'bodyFat': int.parse(bodyFatController.text),
                    });
                  });
                }
              } else if (knowBodyFatController.text == 'false') {
                if (firstFormKey.currentState!.validate() && secondNotKnowBodyFatFormKey.currentState!.validate()) {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    Navigator.pushNamedAndRemoveUntil(context, '/challenge', (_) => false, arguments: {
                      'screen': 'SecondStep',
                      'gender': genderController.text,
                      'height': double.parse(heightController.text),
                      'weight': double.parse(weightController.text),
                      'knowBodyFat': false,
                      'neck': double.parse(neckController.text),
                      'waist': double.parse(waistController.text),
                      'hip': double.parse(hipController.text),
                    });
                  });
                }
              }
            }
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Text('다음')),
    );
  }

  static _dialog(BuildContext context, String content) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '데이터 입력 안내',
            style: TextStyle(
              color: Colors.green,
            ),
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인', style: TextStyle(color: Colors.green)),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        );
      },
      barrierDismissible: true,
    );
  }
}

class SecondStepScreen {
  static final TextEditingController textEditingController = TextEditingController();
  static final StreamController streamController = StreamController.broadcast();

  static Widget widget(BuildContext context, Map query) {
    if (query['knowBodyFat']) {
      query['bodyFat'] = query['bodyFat'];
      query['bmr'] = HandleChallenge.getBMR(query['weight'], query['bodyFat']);
    } else {
      query['bodyFat'] =
          HandleChallenge.getBodyFat(query['gender'], query['height'], query['neck'], query['waist'], query['hip']);
      query['bmr'] = HandleChallenge.getBMR(query['weight'], query['bodyFat']);
    }

    if (query.containsKey('activityLevel')) textEditingController.text = query['activityLevel'].toString();

    double deviceSize = MediaQuery.of(context).size.width;
    List<Widget> children = [];

    return ChallengePage.card(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder(
                stream: streamController.stream,
                builder: (context, snapshot) {
                  if (textEditingController.text.isNotEmpty && !snapshot.hasData) {
                    streamController.add(double.tryParse(textEditingController.text));
                  }
                  children.clear();

                  children.add(
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(text: '당신의 활동량은? ', style: TextStyle(color: Colors.green)),
                          TextSpan(text: '(운동량은 제외)', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                  children.add(const SizedBox(width: 4.0));

                  if (deviceSize >= tablet) {
                    children.add(
                      SizedBox(
                        height: 300.0,
                        child: Row(
                          children: [
                            _item(context, textEditingController, streamController, 1.2),
                            _item(context, textEditingController, streamController, 1.375),
                          ],
                        ),
                      ),
                    );
                    children.add(
                      SizedBox(
                        height: 200.0,
                        child: Row(
                          children: [
                            _item(context, textEditingController, streamController, 1.55),
                            _item(context, textEditingController, streamController, 1.725),
                            _item(context, textEditingController, streamController, 1.9),
                          ],
                        ),
                      ),
                    );
                  } else {
                    children.add(_item(context, textEditingController, streamController, 1.2));
                    children.add(_item(context, textEditingController, streamController, 1.375));
                    children.add(_item(context, textEditingController, streamController, 1.55));
                    children.add(_item(context, textEditingController, streamController, 1.725));
                    children.add(_item(context, textEditingController, streamController, 1.9));
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  );
                }),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                _previousStepButton(context, query, textEditingController),
                const Expanded(child: SizedBox()),
                _nextStepButton(context, query, textEditingController),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _item(
      BuildContext context, TextEditingController controller, StreamController streamController, double level) {
    double deviceSize = MediaQuery.of(context).size.width;
    late String title, sub, image;
    if (level == 1.2) {
      title = '사무직';
      sub = '앉아서 일하는 일반적인 직종';
      image = 'activity1';
    } else if (level == 1.375) {
      title = '서비스직';
      sub = '약간 활동적인 직종';
      image = 'activity2';
    } else if (level == 1.55) {
      title = '생산직';
      sub = '활발한 직종';
      image = 'activity3';
    } else if (level == 1.725) {
      title = '힘든 생산직';
      sub = '매우 활발한 직종';
      image = 'activity4';
    } else if (level == 1.9) {
      title = '매우 힘든 생산직';
      sub = '매우 힘든 노동 직종';
      image = 'activity5';
    }

    if (deviceSize >= tablet) {
      return Expanded(
        child: InkWell(
          onTap: () {
            controller.text = level.toString();
            streamController.add(level);
          },
          borderRadius: BorderRadius.circular(20.0),
          child: Card(
            color: Colors.white,
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: controller.text.isNotEmpty && (double.tryParse(controller.text) == level)
                  ? const BorderSide(color: Colors.green, width: 4.0)
                  : BorderSide.none,
            ),
            child: Column(
              children: [
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image(image: AssetImage('assets/images/$image.png')))),
                Text(title, style: const TextStyle(color: Colors.green, fontSize: 32.0, fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text('($sub)'),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        height: 150.0,
        child: InkWell(
          onTap: () {
            controller.text = level.toString();
            streamController.add(level);
          },
          borderRadius: BorderRadius.circular(20.0),
          child: Card(
            color: Colors.white,
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: controller.text.isNotEmpty && (double.tryParse(controller.text) == level)
                  ? const BorderSide(color: Colors.green, width: 4.0)
                  : BorderSide.none,
            ),
            child: Row(
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 4.0, 4.0, 4.0),
                    child: Image(image: AssetImage('assets/images/$image.png'))),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title,
                          style: const TextStyle(color: Colors.green, fontSize: 32.0, fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text('($sub)'),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
  }

  static Widget _previousStepButton(BuildContext context, Map query, TextEditingController controller) {
    return SizedBox(
      width: 150.0,
      height: 40.0,
      child: ElevatedButton(
          onPressed: () {
            if (controller.text.isNotEmpty) query['activityLevel'] = double.tryParse(controller.text);
            query['screen'] = 'FirstStep';
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.pushNamedAndRemoveUntil(context, '/challenge', (_) => false, arguments: query);
            });
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Text('다시 입력하기')),
    );
  }

  static Widget _nextStepButton(BuildContext context, Map query, TextEditingController controller) {
    return SizedBox(
      width: 150.0,
      height: 40.0,
      child: ElevatedButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              query['activityLevel'] = double.tryParse(controller.text);
              query['screen'] = 'Result';
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                Navigator.pushNamedAndRemoveUntil(context, '/challenge', (_) => false, arguments: query);
              });
            } else {
              _dialog(context, '활동량을 선택해주세요.');
            }
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Text('결과 보기')),
    );
  }

  static _dialog(BuildContext context, String content) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '데이터 입력 안내',
            style: TextStyle(
              color: Colors.green,
            ),
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인', style: TextStyle(color: Colors.green)),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        );
      },
      barrierDismissible: true,
    );
  }
}

class ResultScreen {
  static final GlobalKey activityKey = GlobalKey();
  static final GlobalKey sliderKey = GlobalKey();
  static final ScreenshotController screenshotController = ScreenshotController();

  static Widget widget(BuildContext context, Map query) {
    query['totalEnergy'] = HandleChallenge.getTotalEnergy(query['bmr'], query['activityLevel']);
    query.addAll(HandleChallenge.getNormalIntake(query['weight'], query['bodyFat'], query['totalEnergy']));

    return ChallengePage.card(
      context,
      Column(
        children: [
          Screenshot(
            controller: screenshotController,
            child: Column(
              children: [
                result(context, query),
                option(context, query),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                _previousStepButton(context, query),
                const Expanded(child: SizedBox()),
                _saveButton(context, query),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget result(BuildContext context, Map query) {
    return Card(
      color: Colors.white,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text('신체 정보', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.green)),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(text: '성별\n', style: TextStyle(fontSize: 18.0)),
                        TextSpan(
                          text: query['gender'] == 'male' ? '남성' : '여성',
                          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                      style: const TextStyle(color: Colors.black, fontFamily: 'roboto'),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(text: '키\n', style: TextStyle(fontSize: 18.0)),
                        TextSpan(
                          text: query['height'].toString(),
                          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: 'cm'),
                      ],
                      style: const TextStyle(color: Colors.black, fontFamily: 'roboto'),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(text: '몸무게\n', style: TextStyle(fontSize: 18.0)),
                        TextSpan(
                          text: query['weight'].toString(),
                          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: 'kg'),
                      ],
                      style: const TextStyle(color: Colors.black, fontFamily: 'roboto'),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(text: '체지방\n', style: TextStyle(fontSize: 18.0)),
                        TextSpan(
                          text: query['bodyFat'].toString(),
                          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: '%'),
                      ],
                      style: const TextStyle(color: Colors.black, fontFamily: 'roboto'),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(text: '기초 대사량\n', style: TextStyle(fontSize: 18.0)),
                        TextSpan(
                          text: '${query['bmr']}',
                          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: 'kcal'),
                      ],
                      style: const TextStyle(color: Colors.black, fontFamily: 'roboto'),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(text: '활동 대사량\n', style: TextStyle(fontSize: 18.0)),
                        TextSpan(
                          text: '${query['totalEnergy']}',
                          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: 'kcal'),
                      ],
                      style: const TextStyle(color: Colors.black, fontFamily: 'roboto'),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget option(BuildContext context, Map query) {
    double deviceSize = MediaQuery.of(context).size.width;

    final TextEditingController walkController = TextEditingController();
    final TextEditingController runController = TextEditingController();
    final TextEditingController cycleController = TextEditingController();
    final TextEditingController goalController = TextEditingController();

    if (query.containsKey('activity')) {
      walkController.text = query['activity']['walk'].toString();
      runController.text = query['activity']['run'].toString();
      cycleController.text = query['activity']['cycle'].toString();
    }

    if (query['change'] != null) goalController.text = query['change'].toString();

    if (deviceSize >= tablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    activity(context, query, walkController, runController, cycleController),
                    slider(context, query, goalController),
                  ],
                ),
              ),
              Expanded(
                  flex: 2,
                  child: graph(context, query, walkController, runController, cycleController, goalController)),
            ],
          ),
          intake(context, query, goalController),
        ],
      );
    } else {
      return Column(
        children: [
          activity(context, query, walkController, runController, cycleController),
          slider(context, query, goalController),
          graph(context, query, walkController, runController, cycleController, goalController),
          intake(context, query, goalController),
        ],
      );
    }
  }

  static Widget activity(BuildContext context, Map query, TextEditingController walkController,
      TextEditingController runController, TextEditingController cycleController) {
    final StreamController walkStream = StreamController.broadcast();
    final StreamController runStream = StreamController.broadcast();
    final StreamController cycleStream = StreamController.broadcast();

    query['activity'] = {};

    return Card(
      key: activityKey,
      color: Colors.white,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text('운동', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.green)),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              child: StreamBuilder(
                stream: walkStream.stream,
                builder: (context, snapshot) {
                  query['activity']['walk'] = walkController.text.isNotEmpty ? int.parse(walkController.text) : 0;
                  return Row(
                    children: [
                      const Expanded(flex: 2, child: Padding(padding: EdgeInsets.all(8.0), child: Text('걷기'))),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: walkController,
                          decoration: const InputDecoration(
                            hintText: '0',
                            suffixIcon: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('분'),
                            ),
                            suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => walkStream.add(value),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${walkController.text.isEmpty ? 0 : (query['weight'] * 0.9 / 15 * double.parse(walkController.text)).round()} kcal',
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
              child: StreamBuilder(
                stream: runStream.stream,
                builder: (context, snapshot) {
                  query['activity']['run'] = runController.text.isNotEmpty ? int.parse(runController.text) : 0;
                  return Row(
                    children: [
                      const Expanded(flex: 2, child: Padding(padding: EdgeInsets.all(8.0), child: Text('달리기'))),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: runController,
                          decoration: const InputDecoration(
                            hintText: '0',
                            suffixIcon: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('분'),
                            ),
                            suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => runStream.add(value),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${runController.text.isEmpty ? 0 : (query['weight'] * 2 / 15 * double.parse(runController.text)).round()} kcal',
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              child: StreamBuilder(
                stream: cycleStream.stream,
                builder: (context, snapshot) {
                  query['activity']['cycle'] = cycleController.text.isNotEmpty ? int.parse(cycleController.text) : 0;
                  return Row(
                    children: [
                      const Expanded(flex: 2, child: Padding(padding: EdgeInsets.all(8.0), child: Text('자전거'))),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: cycleController,
                          decoration: const InputDecoration(
                            hintText: '0',
                            suffixIcon: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('분'),
                            ),
                            suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(12, 0, 12, 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => cycleStream.add(value),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${cycleController.text.isEmpty ? 0 : (query['weight'] * 1.5 / 15 * double.parse(cycleController.text)).round()} kcal',
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget slider(BuildContext context, Map query, TextEditingController goalController) {
    double sliderValue = 0.0;
    final StreamController sliderValueController = StreamController.broadcast();

    if (goalController.text.isNotEmpty) sliderValue = double.parse(goalController.text);

    return Card(
      key: sliderKey,
      color: Colors.white,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text('섭취량 조절', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.green)),
            const Divider(),
            SliderTheme(
              data: const SliderThemeData(),
              child: StreamBuilder(
                  stream: sliderValueController.stream,
                  builder: (context, snapshot) {
                    return Column(
                      children: [
                        Slider(
                          value: sliderValue,
                          min: -50.0,
                          max: 20.0,
                          divisions: 7,
                          onChanged: (value) {
                            sliderValue = value;
                            sliderValueController.add(sliderValue);
                            goalController.text = sliderValue.toString();

                            query['change'] = sliderValue.round();
                          },
                        ),
                        Text(sliderValue == 0.0
                            ? '섭취량 조절 안함'
                            : '섭취량 ${sliderValue.abs()}% ${sliderValue >= 0.0 ? '증가' : '감소'}'),
                      ],
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  static Widget graph(
    BuildContext context,
    Map query,
    TextEditingController walkController,
    TextEditingController runController,
    TextEditingController cycleController,
    TextEditingController goalController,
  ) {
    final StreamController streamController = StreamController.broadcast();
    walkController.addListener(() {
      streamController.add(null);
    });
    runController.addListener(() {
      streamController.add(null);
    });
    cycleController.addListener(() {
      streamController.add(null);
    });
    goalController.addListener(() {
      streamController.add(null);
    });

    return FutureBuilder(
        future: _setGraphWidgetHeight(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            double graphHeight = snapshot.data!;
            return Card(
              color: Colors.white,
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder(
                  stream: streamController.stream,
                  builder: (context, snapshot) {
                    int walkCalorie = walkController.text.isEmpty
                        ? 0
                        : (double.parse(query['weight'].toString()) * 0.9 / 15 * double.parse(walkController.text))
                            .round();
                    int runCalorie = runController.text.isEmpty
                        ? 0
                        : (double.parse(query['weight'].toString()) * 2 / 15 * double.parse(runController.text))
                            .round();
                    int cycleCalorie = cycleController.text.isEmpty
                        ? 0
                        : (double.parse(query['weight'].toString()) * 1.5 / 15 * double.parse(cycleController.text))
                            .round();
                    int activityCalorie = walkCalorie + runCalorie + cycleCalorie;
                    int calorieGoal = goalController.text.isEmpty ? 0 : int.parse(goalController.text);
                    int changeCalorie =
                        (double.parse(query['totalEnergy'].toString()) / 100 * calorieGoal).round() - activityCalorie;
                    double changeWeight = changeCalorie / 7700;
                    double currentWeight = double.parse(query['weight'].toString());

                    List<FlSpot> spots = [];
                    for (double i = 0; i < 27; i++) {
                      spots.add(FlSpot(i, currentWeight + (changeWeight * i * 7)));
                    }
                    double minY = ((currentWeight / 10).roundToDouble() * 10) - 30;
                    double maxY = ((currentWeight / 10).roundToDouble() * 10) + 10;
                    while (minY >= currentWeight + (changeWeight * 26 * 7)) {
                      minY -= 10;
                    }
                    while (maxY <= currentWeight + (changeWeight * 26 * 7)) {
                      maxY += 10;
                    }

                    return SizedBox(
                      height: graphHeight,
                      child: Column(
                        children: [
                          const Text('6개월간 체중 변화',
                              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.green)),
                          const Divider(),
                          const SizedBox(height: 8),
                          Expanded(
                            child: LineChart(
                              LineChartData(
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: spots,
                                    color: Colors.green,
                                    dotData: FlDotData(show: false),
                                    barWidth: 5.0,
                                  ),
                                ],
                                lineTouchData: LineTouchData(
                                  touchTooltipData: LineTouchTooltipData(
                                    tooltipBgColor: Colors.white,
                                    tooltipBorder: const BorderSide(color: Colors.green),
                                    getTooltipItems: (touchedSpots) {
                                      return touchedSpots.map((barSpot) {
                                        final flSpot = barSpot;

                                        return LineTooltipItem(
                                          flSpot.x == 0 ? '현재\n' : '${flSpot.x}주 후\n',
                                          const TextStyle(color: Colors.black),
                                          children: [
                                            TextSpan(
                                              text: '${flSpot.y.toStringAsFixed(2)} kg',
                                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        );
                                      }).toList();
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child: Text(
                                            '${value.round()}kg',
                                            textAlign: TextAlign.right,
                                          ),
                                        );
                                      },
                                      reservedSize: 50,
                                      interval: 10,
                                    ),
                                  ),
                                  topTitles: AxisTitles(),
                                  rightTitles: AxisTitles(),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        switch (value.round().toString()) {
                                          case '0':
                                            return const Padding(
                                              padding: EdgeInsets.only(top: 5),
                                              child: Text('현재'),
                                            );
                                          case '26':
                                            return const Padding(
                                              padding: EdgeInsets.only(top: 5),
                                              child: Text('26주'),
                                            );
                                          default:
                                            return const SizedBox();
                                        }
                                      },
                                      interval: 1,
                                    ),
                                  ),
                                ),
                                gridData: FlGridData(
                                  drawHorizontalLine: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 10,
                                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey, strokeWidth: 0.5),
                                ),
                                borderData: FlBorderData(
                                  border: const Border(
                                    top: BorderSide(color: Colors.grey, width: 0.5),
                                    bottom: BorderSide(color: Colors.grey, width: 0.5),
                                  ),
                                ),
                                minY: minY,
                                maxY: maxY,
                                minX: -1,
                                maxX: 27,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        });
  }

  static Future<double> _setGraphWidgetHeight(BuildContext context) async {
    double height = 0.0;

    while (activityKey.currentContext == null || sliderKey.currentContext == null) {
      await Future.delayed(const Duration(microseconds: 1));
    }

    if (context.mounted) {
      final RenderBox renderBox = activityKey.currentContext!.findRenderObject() as RenderBox;
      Size size = renderBox.size;
      height = height + size.height;
    }

    if (context.mounted) {
      final RenderBox renderBox = sliderKey.currentContext!.findRenderObject() as RenderBox;
      Size size = renderBox.size;
      height = height + size.height;
    }

    return height - 24.0;
  }

  static Widget intake(BuildContext context, Map query, TextEditingController goalController) {
    final StreamController streamController = StreamController.broadcast();
    goalController.addListener(() {
      streamController.add(null);
    });

    return StreamBuilder(
      stream: streamController.stream,
      builder: (context, snapshot) {
        int calorieGoal = goalController.text.isEmpty ? 0 : int.parse(goalController.text);
        int changeCalorie = (double.parse(query['totalEnergy'].toString()) / 100 * calorieGoal).round();
        query['fat'] =
            HandleChallenge.getFatIntake(query['weight'], query['bodyFat'], query['totalEnergy'] + changeCalorie);

        return Card(
          color: Colors.white,
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text('계산된 섭취량',
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.green)),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(text: '탄수화물\n', style: TextStyle(fontSize: 18.0)),
                            TextSpan(
                              text: query['carbs'].toString(),
                              style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: 'g'),
                          ],
                          style: const TextStyle(color: Colors.black, fontFamily: 'roboto'),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(text: '단백질\n', style: TextStyle(fontSize: 18.0)),
                            TextSpan(
                              text: query['protein'].toString(),
                              style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: 'g'),
                          ],
                          style: const TextStyle(color: Colors.black, fontFamily: 'roboto'),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(text: '지방\n', style: TextStyle(fontSize: 18.0)),
                            TextSpan(
                              text: query['fat'].toString(),
                              style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: 'g'),
                          ],
                          style: const TextStyle(color: Colors.black, fontFamily: 'roboto'),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _previousStepButton(BuildContext context, Map query) {
    return SizedBox(
      width: 150.0,
      height: 40.0,
      child: ElevatedButton(
          onPressed: () {
            query['screen'] = 'SecondStep';
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Navigator.pushNamedAndRemoveUntil(context, '/challenge', (_) => false, arguments: query);
            });
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Text('다시 선택하기')),
    );
  }

  static Widget _saveButton(BuildContext context, Map query) {
    return SizedBox(
      width: 150.0,
      height: 40.0,
      child: ElevatedButton(
        onPressed: () async {
          if (accountManager.accountArguments.name == null) {
            screenshotController.capture(delay: const Duration(milliseconds: 10)).then((capturedImage) async {
              TextEditingController emailController = TextEditingController();
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(
                      '이메일 입력',
                      style: TextStyle(
                        color: Colors.green,
                      ),
                    ),
                    content: TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        hintText: 'example@email.com',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          borderSide: BorderSide(color: Colors.green),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      autofocus: true,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('취소', style: TextStyle(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (emailController.text.isNotEmpty) {
                            if (await HandleChallenge.postEmail(emailController.text, capturedImage!)) {
                              Fluttertoast.showToast(
                                msg: '전송 성공',
                                timeInSecForIosWeb: 3,
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                                fontSize: 16.0,
                                webBgColor: '#4CAF50',
                                webPosition: 'center',
                              );
                            } else {
                              Fluttertoast.showToast(
                                msg: '전송 실패',
                                timeInSecForIosWeb: 3,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                                webBgColor: '#F44336',
                                webPosition: 'center',
                              );
                            }
                            if (context.mounted) Navigator.pop(context);
                          } else {
                            Fluttertoast.showToast(
                              msg: '이메일을 입력해주세요.',
                              timeInSecForIosWeb: 3,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                              webBgColor: '#F44336',
                              webPosition: 'center',
                            );
                          }
                        },
                        child: const Text('이메일로 받기', style: TextStyle(color: Colors.green)),
                      ),
                    ],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  );
                },
                barrierDismissible: true,
              );
            });
          } else {
            if (await HandleChallenge.postChallenge(query)) {
              Fluttertoast.showToast(
                msg: '저장 성공',
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
                webBgColor: '#4CAF50',
                webPosition: 'center',
              );
            } else {
              Fluttertoast.showToast(
                msg: '저장 실패',
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
                webBgColor: '#F44336',
                webPosition: 'center',
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        child: StreamBuilder(
          stream: accountManager.nameStreamController.stream,
          builder: (context, snapshot) {
            if (snapshot.data != accountManager.accountArguments.name) {
              accountManager.nameStreamController.add(accountManager.accountArguments.name);
              accountManager.oAuthTokenStreamController.add(accountManager.accountArguments.oAuthToken);
            }
            if (!snapshot.hasData) {
              return const Text('이메일로 결과 받기');
            } else {
              return const Text('저장하기');
            }
          },
        ),
      ),
    );
  }
}
