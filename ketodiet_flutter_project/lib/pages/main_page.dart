import 'package:flutter/material.dart';
import 'package:ketodiet_flutter_project/modules/handle.dart';

import '../modules/layout.dart';

class MainPage extends StatefulWidget {
  final Map<String, dynamic> query;

  const MainPage(this.query, {super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int isFirstRender = 4;

  @override
  void initState() {
    if (widget.query.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = MainPageWidget.widgetList(context);

    for (var i = 0; i < widgetList.length; i++) {
      widgetList[i] = animateModule(widgetList[i], i);
    }

    double deviceSize = MediaQuery.of(context).size.width;

    return CustomScaffold.scaffold(
      context: context,
      body: deviceSize >= tablet
          ? Column(children: [
              Expanded(child: Row(children: [widgetList[0], widgetList[1]])),
              Expanded(child: Row(children: [widgetList[2], widgetList[3]]))
            ])
          : Column(children: widgetList),
    );
  }

  Widget animateModule(Widget widget, int sequence) {
    late final AnimationController controller = AnimationController(
      duration: Duration(milliseconds: 500 + (sequence * 100)),
      vsync: this,
    );

    late final Animation<double> opacity = CurvedAnimation(
      parent: controller,
      curve: Curves.linear,
    );

    late final Animation<Offset> position = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.linear,
    ));

    if (isFirstRender > 0) {
      controller.forward();
      isFirstRender--;
    } else {
      controller.duration = Duration.zero;
      controller.forward();
    }

    return Expanded(
      child: FadeTransition(
        opacity: opacity,
        child: SlideTransition(
          position: position,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: widget,
          ),
        ),
      ),
    );
  }
}

class MainPageWidget {
  static List<Widget> widgetList(BuildContext context) {
    return [
      _widget(context, '/info', Icons.question_mark, '키토제닉이란?', '키토제닉이 처음이신가요? 키토제닉이 궁금하신가요?'),
      _widget(context, '/about-us', Icons.group, '우리는 누구인가요?', 'KetoDiet은 뭐하는 곳인가요? 누가 만들었나요?'),
      _widget(context, '/community', Icons.forum_outlined, '커뮤니티', '키토제닉에 대해 다양한 정보를 여러 사람들과 공유해 보세요!'),
      _widget(context, '/challenge', Icons.military_tech, '키토 챌린지', '자신의 체질에 맞는 섭취량을 계획하고 실천해 보세요!'),
    ];
  }

  static Widget _widget(BuildContext context, String path, IconData icon, String title, String explain) {
    double deviceSize = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: () {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Navigator.pushNamedAndRemoveUntil(context, path, (_) => false);
        });
      },
      borderRadius: BorderRadius.circular(20.0),
      hoverColor: Colors.green,
      highlightColor: Colors.greenAccent,
      child: Card(
        color: Colors.white,
        elevation: 8.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: deviceSize >= tablet
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(icon, size: height / 4, color: Colors.green),
                  ),
                  Text(title, style: const TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 5.0),
                  Text(explain, textAlign: TextAlign.center),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(icon, size: height / 5.5, color: Colors.green),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 32.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(explain),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
