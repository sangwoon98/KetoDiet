import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ketodiet_flutter_project/handles/handle_size.dart';

import '../modules/layout.dart';

class InfoPage extends StatefulWidget {
  final Map<String, dynamic> query;

  const InfoPage(this.query, {super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  void initState() {
    if (widget.query.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushNamedAndRemoveUntil(context, '/info', (_) => false);
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double deviceSize = MediaQuery.of(context).size.width;

    return CustomScaffold.scaffold(
      context: context,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: deviceSize >= laptop ? (deviceSize - laptop) / 2 : 4.0,
            right: deviceSize >= laptop ? (deviceSize - laptop) / 2 : 4.0,
          ),
          child: InfoPageWidget.widget(context),
        ),
      ),
    );
  }
}

class InfoPageWidget {
  static Widget widget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('키토제닉이란?', style: GoogleFonts.doHyeon(textStyle: const TextStyle(color: Colors.green, fontSize: 48.0))),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(text: '키토제닉(Ketogenic)은 '),
              const TextSpan(
                text: '탄수화물 섭취를 제한',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              const TextSpan(text: '하고 '),
              const TextSpan(
                text: '지방과 단백질을 고갈',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              const TextSpan(text: ' 시키는 고지방, 중단백, 저탄수화물 식이요법이에요.'),
              const TextSpan(text: '\n\n'),
              const TextSpan(text: '키토제닉을 하게되면 적은 양의 탄수화물을 섭취하므로 '),
              const TextSpan(
                text: '혈당 농도가 낮아',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              const TextSpan(text: '지며, 그 결과로 '),
              const TextSpan(
                text: '인슐린 분비가 감소',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              const TextSpan(text: '해요.'),
              const TextSpan(text: '\n\n'),
              TextSpan(text: '중요!!!', style: TextStyle(color: Colors.red[200])),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: '인슐린은 지방 저장을 촉진하는 호르몬이므로, 인슐린 분비량이 감소하면 체지방을 태우기 시작합니다. 이로 인해 체중 감량이나 혈당 관리에 효과가 있어요!',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.red)]),
              ),
              const TextSpan(text: '\n\n'),
              const TextSpan(text: '또한, 키토제닉 식이요법을 따르는 동안, 간에서는 '),
              const TextSpan(
                text: '지방 대사를 촉진하여 케톤체를 생성',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              const TextSpan(text: '해요. 케톤체는 '),
              const TextSpan(
                text: '대체 에너지원으로 사용',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              const TextSpan(text: '되어, 뇌와 근육 등의 조직에서 에너지를 공급해요. 이러한 작용으로 키토제닉은 특히 '),
              const TextSpan(
                text: '체중 감량, 인슐린 저항성, 심혈관 질환 등에 대한 해결책',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              const TextSpan(text: '으로 인기를 얻고 있어요!'),
            ],
            style: GoogleFonts.gowunDodum(textStyle: const TextStyle(color: Colors.black, fontSize: 24.0)),
          ),
        ),
        const SizedBox(height: 24.0),
        Text('위험하지 않나요?', style: GoogleFonts.doHyeon(textStyle: const TextStyle(color: Colors.green, fontSize: 48.0))),
        RichText(
          text: TextSpan(
            children: const [
              TextSpan(text: '키토제닉은 몇가지 위험이 있을 수 있어요. 탄수화물 섭취를 제한하다 보면, '),
              TextSpan(
                text: '섬유질 섭취량이 감소할 수 있고,',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: ' 이로 인해 변비, 영양 결핍 등의 문제가 발생할 수 있어요.'),
              TextSpan(text: '\n\n'),
              TextSpan(text: '하지만 이것은 '),
              TextSpan(
                text: '단순히 탄수화물을 제한 했을때 생기는 문제',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: '에요. 탄수화물 중 '),
              TextSpan(
                text: '당류는 적고 섬유질이 풍부한 식품',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: '을 먹는다면 인슐린 분비를 억제하며 '),
              TextSpan(
                text: '인체에 필요한 영양소를 공급',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: '받을 수 있어요.'),
              TextSpan(text: '\n\n'),
              TextSpan(
                  text:
                      '그렇다고 모든 사람들에게 키토제닉 식이요법이 추천되는 것은 아니에요. 간에 관련한 질병이 있거나 당뇨가 있는 경우 등 의사나 전문가의 조언을 받고 상담하여 진행여부를 결정짓는 것이 바람직해요.'),
            ],
            style: GoogleFonts.gowunDodum(textStyle: const TextStyle(color: Colors.black, fontSize: 24.0)),
          ),
        ),
        const SizedBox(height: 24.0),
        Text('부작용이 있나요?', style: GoogleFonts.doHyeon(textStyle: const TextStyle(color: Colors.green, fontSize: 48.0))),
        RichText(
          text: TextSpan(
            children: const [
              TextSpan(text: ''),
              TextSpan(
                text: '',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: '키토제닉 식이요법을 시작하고 나서 생기는 부작용들이 몇가지 있어요. 대표적으로는 키토플루, 입냄새, 학습능력 저하, 불면증, 주량 감소 등이 있어요.'),
              TextSpan(text: '\n'),
              TextSpan(text: '이 모든 부작용들은 '),
              TextSpan(
                text: '평생 가는 것이 아닌 대부분 케토시스 상태 진입 후에 완화',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: ' 되는것으로 알려져 있어요. 하지만 기존 식사 대비 간의 부하가 크게 걸리기 때문에, 주량 감소는 피하기가 어려워요.'),
            ],
            style: GoogleFonts.gowunDodum(textStyle: const TextStyle(color: Colors.black, fontSize: 24.0)),
          ),
        ),
        const SizedBox(height: 24.0),
        Text('케토시스가 뭐에요?', style: GoogleFonts.doHyeon(textStyle: const TextStyle(color: Colors.green, fontSize: 48.0))),
        RichText(
          text: TextSpan(
            children: const [
              TextSpan(text: ''),
              TextSpan(
                text: '',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(
                  text: '케토시스는 탄수화물이 주 에너지원으로 쓰이는 대사 상태와 반대로 탄수화물 섭취가 제한되어 있거나 전혀 없는 상황에서 발생하는 대사 상태에요. 이 상태에서는 체내에서 '),
              TextSpan(
                text: '지방 대사가 증가',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: '하며, '),
              TextSpan(
                text: '지방산이 간에서 분해되어 케톤체가 생성',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: '돼요. 케톤체는 혈액으로 이동하여 '),
              TextSpan(
                text: '에너지원으로 사용',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: '돼요.'),
            ],
            style: GoogleFonts.gowunDodum(textStyle: const TextStyle(color: Colors.black, fontSize: 24.0)),
          ),
        ),
        const SizedBox(height: 24.0),
        Text('마지막으로 정리해드릴께요!',
            style: GoogleFonts.doHyeon(textStyle: const TextStyle(color: Colors.green, fontSize: 48.0))),
        RichText(
          text: TextSpan(
            children: const [
              TextSpan(text: ''),
              TextSpan(
                text: '',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: '키토제닉 식이요법으로 체중감량을 목표로 할때 가장 중요한 것을 말씀드릴께요!'),
              TextSpan(text: '\n\n'),
              TextSpan(text: '핵심은 인슐린과 케톤이에요.\n'),
              TextSpan(
                text: '인슐린은 혈당을 낮추는 호르몬',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(
                  text:
                      '이에요. 탄수화물을 섭취 할 경우 혈당이 올라가 인슐린이 분비되고 인슐린이 분비되면 배고픔을 느껴요. 그래서 "면요리를 먹고 나면 금방 소화된다" 라는 느낌을 받는거에요. 사실은 소화된것이 아닌 거짓배고픔을 느끼는거에요. 완전한 악순환이라고 볼 수 있죠. '),
              TextSpan(
                text: '그동안 다이어트에 실패한 것은 당신의 의지 문제가 아니에요. 온전히 호르몬 불균형의 문제이고 키토제닉은 그 호르몬 불균형을 다시 바로잡을 수 있는 식이요법',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: '이에요.'),
              TextSpan(
                text: '케톤은 체내에 탄수화물 에너지원이 부족한 경우 지방을 분해 하여 생성되는 에너지원',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: '이에요. 이말은 '),
              TextSpan(
                text: '24시간 상시 체내의 지방을 분해',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(
                  text:
                      '한다는 말이죠! "런닝머신을 뛸때 일정시간 이상 뛰어야 그때부터 지방이 분해된다" 라는 말을 들어보셨나요? 일반식이를 할 경우 지방을 분해 하기 위해서는 체내의 탄수화물을 모두 소진해야 하기 때문이에요. 하지만 키토제닉을 한다면 24시간 지방을 분해하기 때문에 '),
              TextSpan(
                text: '체중 감량을 위한 운동이 일반식이를 할 때보다 더욱 효과적',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: '이에요.'),
              TextSpan(text: '\n\n'),
              TextSpan(text: '절대적 저탄수 고지방이 아니에요.\n'),
              TextSpan(
                text: '탄수화물 중에 섬유질은 인체에 매우 중요한 영양소',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: '에요. 무탄수 식이를 할 경우 건강은 상당히 나빠지며 즉시 나빠진것을 느낄수도 있을거에요. '),
              TextSpan(
                text: '지방에 비해서 탄수화물을 비교적 적게 섭취',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: '하는 것이지 '),
              TextSpan(
                text: '아예 끊는 것이 아니라는것',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: '을 유념하세요.'),
              TextSpan(text: '\n\n'),
              TextSpan(text: '단백질도 상당히 중요해요.\n'),
              TextSpan(
                text: '단백질도 체내에 필수적으로 필요한 영양소',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: '에요. 만약 단백질 섭취를 소홀히 한다면 근손실도 심각해질거에요. '),
              TextSpan(
                text: '탄수화물은',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: ' 안정적인 지방 연소와 케토시스를 위해 '),
              TextSpan(
                text: '제한',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: ', '),
              TextSpan(
                text: '단백질은',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: ' 골격근 성장 및 유지를 위해 '),
              TextSpan(
                text: '필요량을 채워야하며,',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: ' '),
              TextSpan(
                text: '지방은',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: ' 자신의 목표나 체지방량의 따라서 '),
              TextSpan(
                text: '조절하는 것',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: '이에요. "저탄수 고지방" 이라고 해서 단백질이 서운해하지 않게끔 잘 챙겨주세요!'),
              TextSpan(text: '\n\n'),
              TextSpan(text: '다량의 수분 섭취는 필수에요.\n'),
              TextSpan(text: '케토시스 상태 진입 직전 나타나는 부작용들은 대부분 진입 이후 완화되며 '),
              TextSpan(
                text: '부작용의 강도는 전해질이 부족할 수록 심하게 나타나요.',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: ' 이로인해 수분 섭취는 필수에요.'),
              TextSpan(text: '\n\n'),
              TextSpan(text: '건강상의 문제가 생기면 즉시 중단하세요.\n'),
              TextSpan(
                  text: '키토제닉 식이요법은 과학적으로 완전히 입증되지 않고 아직 많은 실험과 연구가 진행되는 식이요법이에요. 그리고 본인이 갖고있는 질병에 따라 위험할 수 있어요. '),
              TextSpan(
                text: '케토시스 진입 후 완화되는 부작용으로 알려진 부작용이 아닌 다른 부작용이 발생한다면 즉시 중단',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)]),
              ),
              TextSpan(text: '하고 의사 및 전문가와 상담 후 진행 여부를 결정하세요.'),
            ],
            style: GoogleFonts.gowunDodum(textStyle: const TextStyle(color: Colors.black, fontSize: 24.0)),
          ),
        ),
        const SizedBox(height: 24.0),
        Text('그래서 어떻게 시작해야하나요?',
            style: GoogleFonts.doHyeon(textStyle: const TextStyle(color: Colors.green, fontSize: 48.0))),
        RichText(
          text: TextSpan(
            children: const [
              TextSpan(text: '저희 KetoDiet 커뮤니티에서 여러 사람들의 경험을 통한 정보를 얻고, '),
              TextSpan(
                text: '키토 챌린지',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.green)]),
              ),
              TextSpan(text: '를 진행해보세요! 키토 챌린지는 '),
              TextSpan(
                text: '본인의 신체정보를 바탕으로 권장 섭취량을 알려주고 식단을 짜볼 수 있어요.',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.green)]),
              ),
              TextSpan(text: ' 그리고 이를 바탕으로 '),
              TextSpan(
                text: '키토제닉에 도전',
                style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.green)]),
              ),
              TextSpan(text: '해보세요!'),
            ],
            style: GoogleFonts.gowunDodum(textStyle: const TextStyle(color: Colors.black, fontSize: 24.0)),
          ),
        ),
        const SizedBox(height: 24.0),
      ],
    );
  }
}
