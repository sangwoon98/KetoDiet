import 'package:flutter/material.dart';

import '../handles/handle_size.dart';
import '../modules/layout.dart';

class AboutUsPage extends StatefulWidget {
  final Map<String, dynamic> query;

  const AboutUsPage(this.query, {super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  @override
  void initState() {
    if (widget.query.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushNamedAndRemoveUntil(context, '/about-us', (_) => false);
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
          child: AboutUsPageWidget.widget(context),
        ),
      ),
    );
  }
}

class AboutUsPageWidget {
  static Widget widget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24.0),
        const Text('KetoDiet 팀 소개', style: TextStyle(color: Colors.green, fontSize: 48.0, fontFamily: 'DoHyeon')),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(text: '안녕하세요. 우리는 KetoDiet팀이에요! 우리는 웹 개발자 두명으로 이루어진 팀이에요. '),
              TextSpan(
                  text: 'KetoDiet에서는 키토제닉 다이어트에 관련한 정보를 얻을 수 있고 여러 사람들과 정보를 공유해 볼 수 있어요.',
                  style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)])),
              TextSpan(text: ' 그리고 키토 챌린지를 통해서 자신의 체질에 맞는 권장 섭취량도 계산해 볼 수 있어요!\n'),
              TextSpan(text: '혹시라도 "프로그래머 두명이서 만든게 얼마나 정확한 정보겠어?" 라고 생각 하셨다면 그런 의심은 하지 않으셔도 괜찮아요. 왜냐하면 개발자 중 한명이 '),
              TextSpan(
                  text: '키토제닉을 직접 2년간 경험', style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)])),
              TextSpan(text: '해보고 효과를 보았으며 키토제닉을 실행하기 전, 실행하면서 많은 공부를 해왔기 때문이에요.\n'),
              TextSpan(text: '개발자 두명에 대한 소개도 궁금하시다면 아래를 참고해 주세요~'),
            ],
            style: TextStyle(color: Colors.black, fontSize: 24.0, fontFamily: 'GowunDodum'),
          ),
        ),
        const SizedBox(height: 24.0),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(text: '윤상운', style: TextStyle(color: Colors.green, fontSize: 48.0, fontFamily: 'DoHyeon')),
              TextSpan(
                  text: ': 팀 리더, 백엔드 개발\n',
                  style: TextStyle(color: Colors.grey, fontSize: 32.0, fontFamily: 'DoHyeon')),
              TextSpan(
                  text:
                      '안녕하세요! KetoDiet 팀 리더 윤상운입니다! 저는 웹 백엔드 개발을 공부하며 새로운 프로젝트를 진행해보고 싶었는데 그때 생각해낸 것이 바로 이 KetoDiet 서비스에요.\n'),
              TextSpan(text: 'KetoDiet의 프론트 개발자이자 저의 단짝친구가 키토제닉 경험이 있었기때문에 키토제닉에 대해 관심이 있었으며 '),
              TextSpan(
                  text: '사람들이 처음 키토제닉을 도전하려 할 때 어떤 어려움이 있는지, 그것을 어떻게 해결해 줄 수 있는지 고민해보고 이것을 바탕으로 제작',
                  style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)])),
              TextSpan(text: '을 하게 됐어요. 많은 분들이 저희 웹사이트를 이용해서 쉽게 키토제닉에 도전 할 수 있으면 좋겠네요!'),
            ],
            style: TextStyle(color: Colors.black, fontSize: 24.0, fontFamily: 'GowunDodum'),
          ),
        ),
        const SizedBox(height: 24.0),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(text: '김주선', style: TextStyle(color: Colors.green, fontSize: 48.0, fontFamily: 'DoHyeon')),
              TextSpan(
                  text: ': 키토제닉 경험자, 프론트엔드 개발\n',
                  style: TextStyle(color: Colors.grey, fontSize: 32.0, fontFamily: 'DoHyeon')),
              TextSpan(
                  text:
                      '안녕하세요. 저는 KetoDiet 서비스에서 키토제닉과 관련된 모든 정보들을 제작하고 프론트엔드를 개발했습니다. 처음 친구의 제안을 받았을때 저는 프론트 개발에 관심이 있었고 마침 키토제닉을 주제로 프로젝트를 진행한다는 말에 흔쾌히 참여했습니다.\n저는 '),
              TextSpan(
                  text: '체중 감량을 목적으로 한 키토제닉 다이어트를 2년간 경험해 보았고, 30kg을 감량하는 매우 큰 효과도 봤습니다.',
                  style: TextStyle(shadows: [Shadow(blurRadius: 6.0, color: Colors.yellow)])),
              TextSpan(
                  text:
                      ' 저희 서비스에 기술된 키토제닉 정보들은 모두 제 경험과 제가 공부한 것을 바탕으로 작성하였습니다. 만약 키토제닉에 대해 도움이 필요하다면 우리 커뮤니티 페이지에 글을 올려보세요. 여유가 있다면 제가 직접 답변해 드리겠습니다!'),
            ],
            style: TextStyle(color: Colors.black, fontSize: 24.0, fontFamily: 'GowunDodum'),
          ),
        ),
        const SizedBox(height: 24.0),
      ],
    );
  }
}
