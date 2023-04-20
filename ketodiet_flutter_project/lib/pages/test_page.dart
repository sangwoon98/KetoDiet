import 'package:flutter/material.dart';
import 'package:ketodiet_flutter_project/handles/handle_community.dart';
import 'package:ketodiet_flutter_project/pages/community_page.dart';

import '../modules/app_bar.dart';

class TestPage extends StatefulWidget {
  final Map<String, dynamic> query;

  const TestPage(this.query, {super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  void initState() {
    if (widget.query.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushNamedAndRemoveUntil(context, '/test', (_) => false);
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.widget(context),
      body: ForumWidget.widget(
          context,
          CommunityForum(
            categoryList: ['testCategory'],
            communityPost: CommunityPost(
              postNum: 1,
              category: 'testCategory',
              title: 'testTitle',
              name: 'testName',
              content: 'testContent',
              hit: 0,
              commentCount: 0,
              recommendList: [1, 2, 3, 4, 5],
              createDate: DateTime.now(),
              updateDate: DateTime.now(),
              isRecommend: true,
            ),
            communityCommentList: CommunityCommentList(postNum: 1, pageCount: 1, pageNum: 1, list: []),
            communityPostList: CommunityPostList(
              pageNum: 1,
              pageCount: 1,
              list: [
                CommunityPost(
                  postNum: 1,
                  category: 'testCategory',
                  title: 'testTitle',
                  name: 'testName',
                  hit: 0,
                  commentCount: 0,
                  recommendList: [1, 2, 3, 4, 5],
                  createDate: DateTime.now(),
                  isRecommend: true,
                ),
              ],
            ),
          )),
    );
  }
}

Widget testModule(widget) {
  return SizedBox(
    width: 500.0,
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: widget,
    ),
  );
}
