import 'package:flutter/material.dart';
import 'package:ketodiet_flutter_project/modules/handle.dart';

import '../modules/app_bar.dart';

class CommunityPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const CommunityPage(this.params, {super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.params.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushReplacementNamed(context, '/community');
      });
    }

    return Scaffold(
      appBar: CustomAppBar.widget(context),
      body: FutureBuilder(
        future: HandleCommunity.getPostList(context, CommunityPostList(1)),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ForumWidget.widget(snapshot.data!);
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class ForumWidget {
  static Widget widget(CommunityPostList postList) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(200.0, 50.0, 200.0, 100.0),
      itemBuilder: (BuildContext context, int index) {
        return _postRow(postList.list![index]);
      },
      itemCount: postList.list!.length,
    );
  }

  static Widget _menu() {
    return Row(
      children: [_searchBar(), _postButton()],
    );
  }

  static Widget _searchBar() {
    return const SizedBox();
  }

  static Widget _postButton() {
    return const SizedBox();
  }

  static Widget _postList() {
    return Column(
      children: [],
    );
  }

  static Widget _categoryButtons() {
    return const SizedBox();
  }

  static Widget _categoryButton() {
    return const SizedBox();
  }

  static Widget _postRow(CommunityPost communityPost) {
    return Row(
      children: [
        _expanded(Text(communityPost.postNum.toString())),
        _expanded(Text(communityPost.title), 6),
        _expanded(Text(communityPost.name), 2),
        _expanded(Text(communityPost.createDate.toString())),
        _expanded(Text(communityPost.hit.toString())),
        _expanded(Text(communityPost.recommend.toString())),
      ],
    );
  }

  static Widget _expanded(Widget child, [int flex = 1]) {
    return Expanded(
      flex: flex,
      child: child,
    );
  }
}
