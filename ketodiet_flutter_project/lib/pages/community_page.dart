import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:ketodiet_flutter_project/modules/handle.dart';

import '../modules/app_bar.dart';

class CommunityPage extends StatefulWidget {
  final Map<String, dynamic> query;

  const CommunityPage(this.query, {super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.widget(context),
      body: FutureBuilder(
        future: HandleCommunity.getForum(context, widget.query),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ForumWidget.widget(context, snapshot.data!);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class ForumWidget {
  static Widget widget(BuildContext context, CommunityForum communityForum) {
    List<Widget> itemList = _initItem(context, communityForum);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(200.0, 10.0, 200.0, 10.0),
      itemBuilder: (BuildContext context, int index) {
        return itemList[index];
      },
      itemCount: itemList.length,
    );
  }

  static List<Widget> _initItem(BuildContext context, CommunityForum communityForum) {
    List<Widget> list = [];

    list.addAll(PostWidget.widget(context, communityForum.communityPost, communityForum.communityCommentList));
    list.addAll(PostListWidget.widget(context, communityForum.communityPostList!, communityForum.categoryList!));

    return list;
  }
}

class PostWidget {
  static List<Widget> widget(
      BuildContext context, CommunityPost? communityPost, CommunityCommentList? communityCommentList) {
    if (communityPost == null) return [const SizedBox()];

    List<Widget> children;

    if (communityCommentList == null) {
      children = [_post(context, communityPost)];
    } else {
      children = [_post(context, communityPost), _commentList(communityCommentList)];
    }

    return [
      Material(
        elevation: 8.0,
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
        child: Column(
          children: children,
        ),
      ),
      const SizedBox(height: 10.0),
    ];
  }

  static Widget _post(BuildContext context, CommunityPost communityPost) {
    StreamController<bool> recommendController = StreamController<bool>.broadcast();

    if (communityPost.title == null) {
      return Column(
        children: const [
          SizedBox(height: 200.0),
          Text(
            '존재하지 않는 글입니다.',
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 200.0),
        ],
      );
    }

    Widget modifyOption = const SizedBox();

    if (accountManager.accountArguments.name == communityPost.name) {
      modifyOption = Row(
        children: [
          const SizedBox(width: 10.0),
          Container(color: Colors.black, width: 1.0, height: 14.0),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            onPressed: () {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/community/post',
                  (_) => false,
                  arguments: {
                    'postNum': communityPost.postNum,
                    'category': communityPost.category,
                    'title': communityPost.title,
                    'content': communityPost.content,
                  },
                );
              });
            },
            child: const Text('수정'),
          ),
          Container(color: Colors.black, width: 1.0, height: 14.0),
          TextButton(
            onPressed: () async {
              bool success = await HandleCommunity.deletePost(context, communityPost.postNum);
              if (success) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  Navigator.pushNamedAndRemoveUntil(context, '/community', (_) => false);
                });
              }
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            child: const Text('삭제'),
          ),
        ],
      );
    } else if (accountManager.accountArguments.isAdmin == true) {
      modifyOption = Row(
        children: [
          const SizedBox(width: 10.0),
          Container(color: Colors.black, width: 1.0, height: 14.0),
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            onPressed: () {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/community/post',
                  (_) => false,
                  arguments: {
                    'postNum': communityPost.postNum,
                    'category': communityPost.category,
                    'title': communityPost.title,
                    'content': communityPost.content,
                    'isAdmin': true,
                  },
                );
              });
            },
            child: const Text('수정'),
          ),
          Container(color: Colors.black, width: 1.0, height: 14.0),
          TextButton(
            onPressed: () async {
              bool success = await HandleCommunity.deletePost(context, communityPost.postNum);
              if (success) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  Navigator.pushNamedAndRemoveUntil(context, '/community', (_) => false);
                });
              }
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            child: const Text('삭제'),
          ),
        ],
      );
    }

    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    communityPost.title!,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(5.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Text(
                      communityPost.category!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 10.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
          child: SizedBox(
            height: 18.0,
            child: Row(
              children: [
                const Padding(padding: EdgeInsets.only(right: 2.0), child: Icon(Icons.person, size: 14.0)),
                Text(communityPost.name!),
                const Expanded(child: SizedBox()),
                const Padding(padding: EdgeInsets.only(right: 2.0), child: Icon(Icons.remove_red_eye, size: 14.0)),
                Text(communityPost.hit.toString()),
                const SizedBox(width: 10.0),
                const Padding(padding: EdgeInsets.only(right: 2.0), child: Icon(Icons.recommend, size: 14.0)),
                Text(communityPost.recommend.toString()),
                const SizedBox(width: 10.0),
                const Padding(padding: EdgeInsets.only(right: 2.0), child: Icon(Icons.comment, size: 14.0)),
                Text(communityPost.commentCount.toString()),
                const SizedBox(width: 10.0),
                const Padding(padding: EdgeInsets.only(right: 2.0), child: Icon(Icons.date_range, size: 14.0)),
                Text(communityPost.createDate == communityPost.updateDate
                    ? DateFormat('yyyy-MM-dd HH:mm:ss').format(communityPost.createDate!)
                    : '${DateFormat('yyyy-MM-dd HH:mm:ss').format(communityPost.updateDate!)} (수정됨)'),
                modifyOption,
              ],
            ),
          ),
        ),
        Container(width: 1040.0, height: 2.0, color: Colors.grey),
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 50.0),
          child: SizedBox(width: double.infinity, child: Text(communityPost.content!)),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: StreamBuilder(
              stream: recommendController.stream,
              builder: (context, snapshot) {
                if (accountManager.accountArguments.uid != null) {
                  List<String> recommendList = [];
                  for (var element in communityPost.recommendList!) {
                    recommendList.add(element.toString());
                  }

                  if (recommendList.contains(accountManager.accountArguments.uid)) {
                    recommendController.add(true);
                  } else {
                    recommendController.add(false);
                  }
                }

                return ElevatedButton(
                  onPressed: () async {
                    if (accountManager.accountArguments.uid == null) {
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('추천 오류'),
                            content: const Text('추천은 회원만 가능합니다.\n회원가입 및 로그인 후 이용해주세요.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('확인'),
                              ),
                            ],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          );
                        },
                        barrierDismissible: true,
                      );
                    } else {
                      if (snapshot.data != true) {
                        communityPost.recommendList =
                            await HandleCommunity.postRecommend(context, communityPost.postNum);
                        if (communityPost.recommendList != null && communityPost.recommendList != []) {
                          communityPost.recommend = communityPost.recommendList!.length;
                          recommendController.add(true);
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: snapshot.data == true ? Colors.white : Colors.green,
                    backgroundColor: snapshot.data == true ? Colors.green : Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: snapshot.data == true ? Colors.transparent : Colors.green, width: 3.0),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    child: Column(
                      children: [
                        const Icon(Icons.recommend, size: 38.0),
                        Text('추천: ${communityPost.recommend.toString()}'),
                      ],
                    ),
                  ),
                );
              }),
        ),
        Container(width: 1020.0, height: 2.0, color: Colors.grey),
      ],
    );
  }

  static Widget _commentList(CommunityCommentList communityCommentList) {
    StreamController<CommunityCommentList> streamController = StreamController<CommunityCommentList>.broadcast();

    return StreamBuilder<CommunityCommentList>(
      stream: streamController.stream,
      builder: (context, snapshot) {
        List<Widget> pageButtons = [];
        List<Widget> commentList = [];

        if (!snapshot.hasData) {
          streamController.add(communityCommentList);
        } else {
          communityCommentList = snapshot.data!;
          int minPage = snapshot.data!.pageNum - 2;
          int maxPage = snapshot.data!.pageNum + 2;

          while (true) {
            if (minPage < 1 && maxPage >= snapshot.data!.pageCount) {
              minPage = 1;
              maxPage = snapshot.data!.pageCount;
            } else if (minPage < 1) {
              minPage++;
              maxPage++;
            } else if (maxPage > snapshot.data!.pageCount) {
              minPage--;
              maxPage--;
            } else {
              break;
            }
          }

          if (minPage > 1) {
            pageButtons.add(
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: SizedBox(
                  width: 30.0,
                  height: 30.0,
                  child: ElevatedButton(
                    onPressed: () async {
                      streamController.add(await HandleCommunity.getCommentList(context, {
                        'post': snapshot.data!.postNum,
                        'page': 1,
                      }));
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                      elevation: MaterialStateProperty.all(0.0),
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                    child: const Icon(Icons.keyboard_double_arrow_left),
                  ),
                ),
              ),
            );
            pageButtons.add(Padding(
              padding: const EdgeInsets.all(2.0),
              child: SizedBox(
                width: 30.0,
                height: 30.0,
                child: ElevatedButton(
                  onPressed: () async {
                    streamController.add(await HandleCommunity.getCommentList(context, {
                      'post': snapshot.data!.postNum,
                      'page': snapshot.data!.pageNum - 5 < 1 ? 1 : snapshot.data!.pageNum - 5
                    }));
                  },
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
                    elevation: MaterialStateProperty.all(0.0),
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                  ),
                  child: const Icon(Icons.keyboard_arrow_left),
                ),
              ),
            ));
          }

          for (int i = minPage; i <= maxPage; i++) {
            pageButtons.add(
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: SizedBox(
                  width: i < 1000 ? 30.0 : null,
                  height: 30.0,
                  child: ElevatedButton(
                    onPressed: () async {
                      streamController.add(await HandleCommunity.getCommentList(context, {
                        'post': snapshot.data!.postNum,
                        'page': i,
                      }));
                    },
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all(snapshot.data!.pageNum == i ? Colors.white : Colors.black),
                      backgroundColor:
                          MaterialStateProperty.all(snapshot.data!.pageNum == i ? Colors.green : Colors.transparent),
                      elevation: MaterialStateProperty.all(0.0),
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                    child: Text(i.toString()),
                  ),
                ),
              ),
            );
          }

          if (maxPage < snapshot.data!.pageCount) {
            pageButtons.add(
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: SizedBox(
                  width: 30.0,
                  height: 30.0,
                  child: ElevatedButton(
                    onPressed: () async {
                      streamController.add(await HandleCommunity.getCommentList(context, {
                        'post': snapshot.data!.postNum,
                        'page': snapshot.data!.pageNum + 5 > snapshot.data!.pageCount
                            ? snapshot.data!.pageCount
                            : snapshot.data!.pageNum + 5
                      }));
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                      elevation: MaterialStateProperty.all(0.0),
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                    child: const Icon(Icons.keyboard_arrow_right),
                  ),
                ),
              ),
            );
            pageButtons.add(
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: SizedBox(
                  width: 30.0,
                  height: 30.0,
                  child: ElevatedButton(
                    onPressed: () async {
                      streamController.add(await HandleCommunity.getCommentList(context, {
                        'post': snapshot.data!.postNum,
                        'page': snapshot.data!.pageCount,
                      }));
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                      elevation: MaterialStateProperty.all(0.0),
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                    child: const Icon(Icons.keyboard_double_arrow_right),
                  ),
                ),
              ),
            );
          }

          for (var element in snapshot.data!.list!) {
            commentList.add(_comment(element, streamController, snapshot.data!));
          }
        }

        return Column(
          children: [
            const SizedBox(width: 1040.0),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  const Icon(Icons.comment, size: 18.0),
                  const SizedBox(width: 2.0),
                  const Text('댓글', style: TextStyle(fontSize: 18.0)),
                  const Expanded(child: SizedBox()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: pageButtons,
                  ),
                ],
              ),
            ),
            Column(children: commentList),
            StreamBuilder(
              stream: accountManager.nameStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.data != accountManager.accountArguments.name) {
                  accountManager.nameStreamController.add(accountManager.accountArguments.name);
                  accountManager.oAuthTokenStreamController.add(accountManager.accountArguments.oAuthToken);
                }
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      '댓글은 회원만 작성 가능합니다.\n회원가입 및 로그인 후 이용해주세요.',
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  TextEditingController commentController = TextEditingController();
                  GlobalKey<FormState> commentKey = GlobalKey<FormState>();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: SizedBox(
                      width: 1020.0,
                      height: 100.0,
                      child: Stack(
                        children: [
                          Positioned(
                            child: SizedBox(
                              width: 901.0,
                              height: 100.0,
                              child: Form(
                                key: commentKey,
                                child: TextFormField(
                                  controller: commentController,
                                  focusNode: FocusNode(
                                    onKey: (FocusNode node, RawKeyEvent evt) {
                                      if (!evt.isShiftPressed && evt.logicalKey.keyLabel == 'Enter') {
                                        if (evt is RawKeyDownEvent) {
                                          node.unfocus();
                                          commentKey.currentState!.save();
                                        }
                                        return KeyEventResult.handled;
                                      } else {
                                        return KeyEventResult.ignored;
                                      }
                                    },
                                  ),
                                  textAlignVertical: TextAlignVertical.top,
                                  decoration: const InputDecoration(
                                    hintText: '댓글 입력',
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20.0),
                                        bottomLeft: Radius.circular(20.0),
                                      ),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20.0),
                                        bottomLeft: Radius.circular(20.0),
                                      ),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    isDense: true,
                                  ),
                                  style: const TextStyle(fontSize: 14.0),
                                  onSaved: (value) async {
                                    if (commentController.text.isNotEmpty) {
                                      bool postSuccess = await HandleCommunity.postComment(
                                          context, communityCommentList.postNum, commentController.text);
                                      if (postSuccess && context.mounted) {
                                        CommunityForum newList = await HandleCommunity.getForum(
                                            context, {'post': communityCommentList.postNum});
                                        streamController.add(newList.communityCommentList!);
                                      } else {
                                        await HandleError.ifErroredPushError(context);
                                      }
                                    } else {
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('댓글 작성 오류'),
                                            content: const Text('댓글이 비어있습니다.\n입력 후 작성 버튼을 눌러주세요.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('확인'),
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
                                  },
                                  keyboardType: TextInputType.multiline,
                                  minLines: 5,
                                  maxLines: null,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 900.0,
                            child: ElevatedButton(
                              onPressed: () async {
                                commentKey.currentState!.save();
                              },
                              style: ElevatedButton.styleFrom(
                                fixedSize: const Size(120.0, 100.0),
                                elevation: 0.0,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20.0),
                                    bottomRight: Radius.circular(20.0),
                                  ),
                                ),
                              ),
                              child: const Text('작성'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  static Widget _comment(CommunityComment comment, StreamController<CommunityCommentList> commentListStream,
      CommunityCommentList commentList) {
    final StreamController<bool?> streamController = StreamController<bool?>.broadcast();
    return StreamBuilder(
      stream: streamController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!) {
            return _modifyComment(context, comment, streamController, commentListStream, commentList);
          }
        }

        Widget modifyOption = const SizedBox();

        if (accountManager.accountArguments.name == comment.name) {
          modifyOption = Row(
            children: [
              const SizedBox(width: 10.0),
              Container(color: Colors.white, width: 1.0, height: 14.0),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  streamController.add(true);
                },
                child: const Text('수정', style: TextStyle(color: Colors.white)),
              ),
              Container(color: Colors.white, width: 1.0, height: 14.0),
              TextButton(
                onPressed: () async {
                  bool success = await HandleCommunity.deleteComment(context, comment.commentNum);
                  if (success && context.mounted) {
                    commentListStream.add(await HandleCommunity.getCommentList(
                        context, {'post': commentList.postNum, 'page': commentList.pageNum}));
                  } else {
                    if (context.mounted) await HandleError.ifErroredPushError(context);
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                child: const Text('삭제', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        } else if (accountManager.accountArguments.isAdmin == true) {
          modifyOption = Row(
            children: [
              const SizedBox(width: 10.0),
              Container(color: Colors.white, width: 1.0, height: 14.0),
              TextButton(
                onPressed: () async {
                  bool success = await HandleCommunity.deleteComment(context, comment.commentNum);
                  if (success && context.mounted) {
                    commentListStream.add(await HandleCommunity.getCommentList(
                        context, {'post': commentList.postNum, 'page': commentList.pageNum}));
                  } else {
                    if (context.mounted) await HandleError.ifErroredPushError(context);
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                child: const Text('삭제', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey, width: 1, strokeAlign: BorderSide.strokeAlignOutside),
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 2.0),
                    child: SizedBox(
                      height: 20.0,
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 2.0),
                            child: Icon(Icons.person, size: 14.0, color: Colors.white),
                          ),
                          Text(
                            comment.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const Expanded(child: SizedBox()),
                          const Padding(
                            padding: EdgeInsets.only(right: 2.0),
                            child: Icon(Icons.date_range, size: 14.0, color: Colors.white),
                          ),
                          Text(
                            comment.createDate == comment.updateDate
                                ? DateFormat('yyyy-MM-dd HH:mm:ss').format(comment.createDate)
                                : '${DateFormat('yyyy-MM-dd HH:mm:ss').format(comment.updateDate)} (수정됨)',
                            style: const TextStyle(color: Colors.white),
                          ),
                          modifyOption,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 2.0),
                  child: Text(comment.content),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _modifyComment(BuildContext context, CommunityComment comment, StreamController<bool?> streamController,
      StreamController<CommunityCommentList> commentListStream, CommunityCommentList commentList) {
    TextEditingController commentController = TextEditingController();
    GlobalKey<FormState> commentKey = GlobalKey<FormState>();
    commentController.text = comment.content;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: SizedBox(
        width: 1020.0,
        height: 100.0,
        child: Stack(
          children: [
            Positioned(
              child: SizedBox(
                width: 901.0,
                height: 100.0,
                child: Form(
                  key: commentKey,
                  child: TextFormField(
                    controller: commentController,
                    focusNode: FocusNode(
                      onKey: (FocusNode node, RawKeyEvent evt) {
                        if (!evt.isShiftPressed && evt.logicalKey.keyLabel == 'Enter') {
                          if (evt is RawKeyDownEvent) {
                            node.unfocus();
                            commentKey.currentState!.save();
                          }
                          return KeyEventResult.handled;
                        } else {
                          return KeyEventResult.ignored;
                        }
                      },
                    ),
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      hintText: '댓글 입력',
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          bottomLeft: Radius.circular(20.0),
                        ),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          bottomLeft: Radius.circular(20.0),
                        ),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 14.0),
                    onSaved: (value) async {
                      if (commentController.text.isNotEmpty) {
                        bool patchSuccess =
                            await HandleCommunity.patchComment(context, comment.commentNum, commentController.text);
                        if (patchSuccess && context.mounted) {
                          commentListStream.add(await HandleCommunity.getCommentList(
                              context, {'post': commentList.postNum, 'page': commentList.pageNum}));
                          streamController.add(null);
                        } else {
                          await HandleError.ifErroredPushError(context);
                        }
                      } else {
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('댓글 작성 오류'),
                              content: const Text('댓글이 비어있습니다.\n입력 후 수정 버튼을 눌러주세요.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('확인'),
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
                    },
                    keyboardType: TextInputType.multiline,
                    minLines: 5,
                    maxLines: null,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 900.0,
              child: ElevatedButton(
                onPressed: () async {
                  commentKey.currentState!.save();
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(120.0, 100.0),
                  elevation: 0.0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                  ),
                ),
                child: const Text('수정'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostListWidget {
  static List<Widget> widget(BuildContext context, CommunityPostList communityPostList, List<String> categoryList) {
    List<Widget> list = [];

    list.add(_menu(context, communityPostList));
    list.add(const SizedBox(height: 10.0));
    list.add(Material(
      elevation: 8.0,
      color: Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      child: Column(
        children: [
          const SizedBox(height: 5.0),
          _postList(context, communityPostList, categoryList),
          const SizedBox(height: 5.0),
          _pageNavigator(context, communityPostList),
          const SizedBox(height: 5.0),
        ],
      ),
    ));

    return list;
  }

  static Widget _menu(BuildContext context, CommunityPostList postList) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _viewTypeButtons(context, postList),
        const Expanded(flex: 1, child: SizedBox()),
        _searchBar(context, postList),
        const SizedBox(width: 10.0),
        _postButton(context),
      ],
    );
  }

  static Widget _viewTypeButtons(BuildContext context, CommunityPostList postList) {
    return Material(
      elevation: 8.0,
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      child: Row(
        children: [
          _viewAllPost(context, postList),
          _viewRecommendPost(context, postList),
        ],
      ),
    );
  }

  static Widget _viewAllPost(BuildContext context, CommunityPostList postList) {
    return SizedBox(
      height: 40.0,
      child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/community', (_) => false);
          },
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(postList.recommend == null ? Colors.white : Colors.black),
            backgroundColor: MaterialStateProperty.all(postList.recommend == null ? Colors.green : Colors.white),
            elevation: MaterialStateProperty.all(0.0),
            shape: MaterialStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  bottomLeft: Radius.circular(20.0),
                ),
              ),
            ),
          ),
          child: Row(
            children: const [
              Icon(Icons.list),
              SizedBox(width: 5.0),
              Text('전체글'),
            ],
          )),
    );
  }

  static Widget _viewRecommendPost(BuildContext context, CommunityPostList postList) {
    return SizedBox(
      height: 40.0,
      child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/community?page=1&recommend=true', (_) => false);
          },
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(postList.recommend == true ? Colors.white : Colors.black),
            backgroundColor: MaterialStateProperty.all(postList.recommend == true ? Colors.green : Colors.white),
            elevation: MaterialStateProperty.all(0.0),
            shape: MaterialStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
              ),
            ),
          ),
          child: Row(
            children: const [
              Icon(Icons.recommend),
              SizedBox(width: 5.0),
              Text('개념글만'),
            ],
          )),
    );
  }

  static Widget _searchBar(BuildContext context, CommunityPostList postList) {
    const List<String> dropdownList = ['전체', '제목', '글쓴이', '내용', '댓글'];
    const Map<String, String> targetMap = {'전체': 'all', '제목': 'title', '글쓴이': 'name', '내용': 'content', '댓글': 'comment'};
    final StreamController<String?> selectedDropdownStreamController = StreamController<String?>.broadcast();
    String selectedDropdown = '전체';
    selectedDropdownStreamController.add(targetMap[selectedDropdown]);
    final searchController = TextEditingController();

    return Material(
      elevation: 8.0,
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      child: SizedBox(
        width: 358.0,
        height: 40.0,
        child: Stack(
          children: [
            Positioned(
              left: 0.0,
              child: StreamBuilder(
                stream: selectedDropdownStreamController.stream,
                builder: (context, snapshot) {
                  return Container(
                    width: 90.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0),
                      ),
                    ),
                    child: DropdownButton(
                      items: dropdownList.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(item),
                          ),
                        );
                      }).toList(),
                      value: selectedDropdown,
                      onChanged: (dynamic value) {
                        selectedDropdown = value;
                        selectedDropdownStreamController.add(targetMap[value]);
                      },
                      underline: const SizedBox(),
                      focusColor: Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20.0),
                      ),
                      isExpanded: true,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 89.0,
              child: SizedBox(
                width: 200.0,
                height: 40.0,
                child: TextFormField(
                  controller: searchController,
                  textAlignVertical: TextAlignVertical.bottom,
                  decoration: const InputDecoration(
                    hintText: '검색어 입력',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  onFieldSubmitted: (value) async {
                    if (searchController.text.isNotEmpty) {
                      String target = targetMap[selectedDropdown]!;
                      String keyword = Uri.encodeComponent(searchController.text);

                      String query = 'page=1&target=$target&keyword=$keyword';
                      if (postList.recommend == true) query = '$query&recommend=true';

                      Navigator.pushNamedAndRemoveUntil(context, '/community?$query', (_) => false);
                    } else {
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('검색어 오류'),
                            content: const Text('검색어가 비어있습니다.\n입력 후 검색하세요'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('확인'),
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
                  },
                ),
              ),
            ),
            Positioned(
              left: 288.0,
              child: ElevatedButton(
                onPressed: () async {
                  if (searchController.text.isNotEmpty) {
                    String target = targetMap[selectedDropdown]!;
                    String keyword = Uri.encodeComponent(searchController.text);

                    String query = 'page=1&target=$target&keyword=$keyword';
                    if (postList.recommend == true) query = '$query&recommend=true';

                    Navigator.pushNamedAndRemoveUntil(context, '/community?$query', (_) => false);
                  } else {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('검색어 오류'),
                          content: const Text('검색어가 비어있습니다.\n입력 후 검색하세요'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('확인'),
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
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(70.0, 40.0),
                  elevation: 0.0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                  ),
                ),
                child: const Text('검색'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _postButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (accountManager.get().name is! String && context.mounted) {
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('권한 없음'),
                content: const Text('회원가입 및 로그인 후 회원만 이용 가능합니다.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('취소'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await HandleAccount.signIn(context);
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(80.0, 40.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: const Text('로그인'),
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

        if (accountManager.get().name is String) {
          if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/community/post', (_) => false);
        }
      },
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(80.0, 40.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      child: const Text('글쓰기'),
    );
  }

  static Widget _postList(BuildContext context, CommunityPostList postList, List<String> categoryList) {
    List<Widget> list = List<Widget>.empty(growable: true);

    list.add(_categoryButtons(context, postList, categoryList));
    list.add(_headerRow());

    if (postList.list == null) {
      list.add(Column(
        children: [
          const SizedBox(height: 30.0),
          const Text('글이 존재하지 않습니다.'),
          const SizedBox(height: 30.0),
          Container(width: 1040.0, height: 1.0, color: Colors.grey),
        ],
      ));
    } else if (postList.list!.isEmpty) {
      list.add(Column(
        children: [
          const SizedBox(height: 30.0),
          const Text('글이 존재하지 않습니다.'),
          const SizedBox(height: 30.0),
          Container(width: 1040.0, height: 1.0, color: Colors.grey),
        ],
      ));
    } else {
      for (var element in postList.list!) {
        list.add(_postRow(context, postList, element));
      }
    }
    list.add(Container(width: 1040.0, height: 1.0, color: Colors.grey));

    return Column(
      children: list,
    );
  }

  static Widget _categoryButtons(BuildContext context, CommunityPostList postList, List<String> categoryList) {
    List<Widget> categoryButtons = [const SizedBox(width: 10.0), _allCategoryButton(context, postList)];

    for (var element in categoryList) {
      categoryButtons.add(_categoryButton(context, postList, element));
    }

    return SizedBox(
      height: 30.0,
      child: Stack(
        children: [
          Positioned(bottom: 0.0, child: Container(width: 1040.0, height: 2.0, color: Colors.grey)),
          Positioned(
            child: ScrollConfiguration(
              behavior: MyCustomScrollBehavior(),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  return categoryButtons[index];
                },
                itemCount: categoryButtons.length,
              ),
            ),
          ),
          StreamBuilder(
            stream: accountManager.isAdminStreamController.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData && accountManager.accountArguments.isAdmin == true) {
                accountManager.isAdminStreamController.add(accountManager.accountArguments.isAdmin);
              }

              if (snapshot.data == true) {
                return Positioned(
                  right: 10.0,
                  child: SizedBox(
                    width: 24.0,
                    height: 24.0,
                    child: ElevatedButton(
                      onPressed: () {
                        ModifyCategory.dialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: Colors.grey,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: const Icon(Icons.settings, size: 14.0),
                    ),
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }

  static Widget _allCategoryButton(BuildContext context, CommunityPostList postList) {
    return SizedBox(
      height: 30.0,
      child: ElevatedButton(
        onPressed: () {
          String query = 'page=1';
          if (postList.target is String) query = '$query&target=${postList.target}';
          if (postList.keyword is String) query = '$query&keyword=${Uri.encodeComponent(postList.keyword!)}';
          if (postList.recommend is bool) query = '$query&recommend=${postList.recommend}';

          Navigator.pushNamedAndRemoveUntil(context, '/community?$query', (_) => false);
        },
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(postList.category == null ? Colors.white : Colors.black),
          backgroundColor: MaterialStateProperty.all(postList.category == null ? Colors.green : Colors.transparent),
          elevation: MaterialStateProperty.all(0.0),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              side: BorderSide(color: postList.category == null ? Colors.grey : Colors.transparent, width: 2.0),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
          ),
        ),
        child: const Text('모든 카테고리'),
      ),
    );
  }

  static Widget _categoryButton(BuildContext context, CommunityPostList postList, String category) {
    return ElevatedButton(
      onPressed: () {
        String query = 'page=1&category=${Uri.encodeComponent(category)}';
        if (postList.target is String) query = '$query&target=${postList.target}';
        if (postList.keyword is String) query = '$query&keyword=${Uri.encodeComponent(postList.keyword!)}';
        if (postList.recommend is bool) query = '$query&recommend=${postList.recommend}';

        Navigator.pushNamedAndRemoveUntil(context, '/community?$query', (_) => false);
      },
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(postList.category == category ? Colors.white : Colors.black),
        backgroundColor: MaterialStateProperty.all(postList.category == category ? Colors.green : Colors.transparent),
        elevation: MaterialStateProperty.all(0.0),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            side: BorderSide(color: postList.category == category ? Colors.grey : Colors.transparent),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
        ),
      ),
      child: Text(category),
    );
  }

  static Widget _headerRow() {
    return Column(
      children: [
        const SizedBox(height: 10.0),
        Row(
          children: [
            _expanded(const Text('번호', textAlign: TextAlign.center)),
            _expanded(const Text('제목'), 6),
            _expanded(const Text('글쓴이'), 2),
            _expanded(const Text('작성일', textAlign: TextAlign.center)),
            _expanded(const Text('조회', textAlign: TextAlign.center)),
            _expanded(const Text('추천', textAlign: TextAlign.center)),
          ],
        ),
        const SizedBox(height: 10.0),
        Container(width: 1040.0, height: 2.0, color: Colors.grey),
      ],
    );
  }

  static Widget _postRow(BuildContext context, CommunityPostList postList, CommunityPost post) {
    DateTime createDate = post.createDate!;
    late String createDateString;

    if (createDate.difference(DateTime.now()).inHours > -24) {
      createDateString = DateFormat('HH:mm').format(createDate);
    } else {
      createDateString = DateFormat('yyyy-MM-dd').format(createDate);
    }

    return TextButton(
      onPressed: () {
        String query = 'post=${post.postNum}';
        if (postList.category is String) query = '$query&category=${Uri.encodeQueryComponent(postList.category!)}';
        if (postList.target is String) query = '$query&target=${Uri.encodeQueryComponent(postList.target!)}';
        if (postList.keyword is String) query = '$query&keyword=${Uri.encodeQueryComponent(postList.keyword!)}';
        if (postList.recommend == true) query = '$query&recommend=true';

        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Navigator.pushNamedAndRemoveUntil(context, '/community?$query', (_) => false);
        });
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        padding: EdgeInsets.zero,
      ),
      child: Column(
        children: [
          const SizedBox(height: 10.0),
          Row(
            children: [
              _expanded(Text(post.postNum.toString(), textAlign: TextAlign.center)),
              _expanded(
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(5.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Text(
                            post.category!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 10.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 2.0),
                      Text(post.title!),
                      post.commentCount! > 0
                          ? Padding(
                              padding: const EdgeInsets.only(left: 2.0),
                              child: Text(
                                '[${post.commentCount.toString()}]',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                  6),
              _expanded(Text(post.name!), 2),
              _expanded(Text(createDateString, textAlign: TextAlign.center)),
              _expanded(Text(post.hit.toString(), textAlign: TextAlign.center)),
              _expanded(Text(post.recommend.toString(), textAlign: TextAlign.center)),
            ],
          ),
          const SizedBox(height: 10.0),
          Container(width: 1040.0, height: 1.0, color: Colors.grey),
        ],
      ),
    );
  }

  static Widget _expanded(Widget child, [int flex = 1]) {
    return Expanded(
      flex: flex,
      child: child,
    );
  }

  static Widget _pageNavigator(BuildContext context, CommunityPostList postList) {
    List<Widget> pageButtons = [];

    if (postList.pageCount == null) {
      return const SizedBox();
    }

    int minPage = postList.pageNum - 4;
    int maxPage = postList.pageNum + 5;

    while (true) {
      if (minPage < 1 && maxPage >= postList.pageCount!) {
        minPage = 1;
        maxPage = postList.pageCount!;
      } else if (minPage < 1) {
        minPage++;
        maxPage++;
      } else if (maxPage > postList.pageCount!) {
        minPage--;
        maxPage--;
      } else {
        break;
      }
    }

    if (minPage > 1) {
      pageButtons.add(_firstPageButton(context, postList));
      pageButtons.add(_previousButton(context, postList));
    }

    for (int i = minPage; i <= maxPage; i++) {
      pageButtons.add(_pageButton(context, postList, i));
    }

    if (maxPage < postList.pageCount!) {
      pageButtons.add(_nextButton(context, postList));
      pageButtons.add(_lastPageButton(context, postList));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pageButtons,
    );
  }

  static Widget _pageButton(BuildContext context, CommunityPostList postList, int pageNum) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizedBox(
        width: pageNum < 1000 ? 30.0 : null,
        height: 30.0,
        child: ElevatedButton(
          onPressed: () {
            String query = 'page=${pageNum.toString()}';
            if (postList.category is String) query = '$query&category=${Uri.encodeComponent(postList.category!)}';
            if (postList.target is String) query = '$query&target=${postList.target}';
            if (postList.keyword is String) query = '$query&keyword=${Uri.encodeComponent(postList.keyword!)}';
            if (postList.recommend is bool) query = '$query&recommend=${postList.recommend}';

            Navigator.pushNamedAndRemoveUntil(context, '/community?$query', (_) => false);
          },
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(postList.pageNum == pageNum ? Colors.white : Colors.black),
            backgroundColor: MaterialStateProperty.all(postList.pageNum == pageNum ? Colors.green : Colors.transparent),
            elevation: MaterialStateProperty.all(0.0),
            padding: MaterialStateProperty.all(EdgeInsets.zero),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
          ),
          child: Text(pageNum.toString()),
        ),
      ),
    );
  }

  static Widget _firstPageButton(BuildContext context, CommunityPostList postList) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizedBox(
        width: 30.0,
        height: 30.0,
        child: ElevatedButton(
          onPressed: () {
            String query = 'page=1';
            if (postList.category is String) query = '$query&category=${Uri.encodeComponent(postList.category!)}';
            if (postList.target is String) query = '$query&target=${postList.target}';
            if (postList.keyword is String) query = '$query&keyword=${Uri.encodeComponent(postList.keyword!)}';
            if (postList.recommend is bool) query = '$query&recommend=${postList.recommend}';

            Navigator.pushNamedAndRemoveUntil(context, '/community?$query', (_) => false);
          },
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.black),
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            elevation: MaterialStateProperty.all(0.0),
            padding: MaterialStateProperty.all(EdgeInsets.zero),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
          ),
          child: const Icon(Icons.keyboard_double_arrow_left),
        ),
      ),
    );
  }

  static Widget _lastPageButton(BuildContext context, CommunityPostList postList) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizedBox(
        width: 30.0,
        height: 30.0,
        child: ElevatedButton(
          onPressed: () {
            String query = 'page=${postList.pageCount}';
            if (postList.category is String) query = '$query&category=${Uri.encodeComponent(postList.category!)}';
            if (postList.target is String) query = '$query&target=${postList.target}';
            if (postList.keyword is String) query = '$query&keyword=${Uri.encodeComponent(postList.keyword!)}';
            if (postList.recommend is bool) query = '$query&recommend=${postList.recommend}';

            Navigator.pushNamedAndRemoveUntil(context, '/community?$query', (_) => false);
          },
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.black),
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            elevation: MaterialStateProperty.all(0.0),
            padding: MaterialStateProperty.all(EdgeInsets.zero),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
          ),
          child: const Icon(Icons.keyboard_double_arrow_right),
        ),
      ),
    );
  }

  static Widget _previousButton(BuildContext context, CommunityPostList postList) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizedBox(
        width: 30.0,
        height: 30.0,
        child: ElevatedButton(
          onPressed: () {
            String query = '';

            if (postList.pageNum - 10 < 1) {
              query = 'page=1';
            } else {
              query = 'page=${postList.pageNum - 10}';
            }

            if (postList.category is String) query = '$query&category=${Uri.encodeComponent(postList.category!)}';
            if (postList.target is String) query = '$query&target=${postList.target}';
            if (postList.keyword is String) query = '$query&keyword=${Uri.encodeComponent(postList.keyword!)}';
            if (postList.recommend is bool) query = '$query&recommend=${postList.recommend}';

            Navigator.pushNamedAndRemoveUntil(context, '/community?$query', (_) => false);
          },
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.black),
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            elevation: MaterialStateProperty.all(0.0),
            padding: MaterialStateProperty.all(EdgeInsets.zero),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
          ),
          child: const Icon(Icons.keyboard_arrow_left),
        ),
      ),
    );
  }

  static Widget _nextButton(BuildContext context, CommunityPostList postList) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizedBox(
        width: 30.0,
        height: 30.0,
        child: ElevatedButton(
          onPressed: () {
            String query = '';

            if (postList.pageNum + 10 > postList.pageCount!) {
              query = 'page=${postList.pageCount}';
            } else {
              query = 'page=${postList.pageNum + 10}';
            }

            if (postList.category is String) query = '$query&category=${Uri.encodeComponent(postList.category!)}';
            if (postList.target is String) query = '$query&target=${postList.target}';
            if (postList.keyword is String) query = '$query&keyword=${Uri.encodeComponent(postList.keyword!)}';
            if (postList.recommend is bool) query = '$query&recommend=${postList.recommend}';

            Navigator.pushNamedAndRemoveUntil(context, '/community?$query', (_) => false);
          },
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.black),
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            elevation: MaterialStateProperty.all(0.0),
            padding: MaterialStateProperty.all(EdgeInsets.zero),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
          ),
          child: const Icon(Icons.keyboard_arrow_right),
        ),
      ),
    );
  }
}

class WritePostPage extends StatefulWidget {
  final Map<String, dynamic> query;

  const WritePostPage(this.query, {super.key});

  @override
  State<WritePostPage> createState() => _WritePostPageState();
}

class _WritePostPageState extends State<WritePostPage> {
  @override
  void initState() {
    for (var element in widget.query.keys) {
      if (element != 'additional') {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Navigator.pushNamedAndRemoveUntil(context, '/community/post', (_) => false);
        });
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.widget(context),
      body: WritePost.widget(context, widget.query['additional']),
    );
  }
}

class WritePost {
  static String? selectedCategory;

  static Widget widget(BuildContext context, Map<String, dynamic>? query) {
    List<Widget> list = [];

    final StreamController<String?> selectedCategoryStreamController = StreamController<String?>.broadcast();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();

    list.add(_postForm(context, query, selectedCategoryStreamController, titleController, contentController));
    list.add(const SizedBox(height: 10.0));
    list.add(_buttons(context, query, titleController, contentController));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(200.0, 10.0, 200.0, 10.0),
      itemBuilder: (BuildContext context, int index) {
        return list[index];
      },
      itemCount: list.length,
    );
  }

  static Widget _buttons(BuildContext context, Map<String, dynamic>? query, TextEditingController titleController,
      TextEditingController contentController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _cancelButton(context),
        const SizedBox(width: 10),
        _submitButton(context, query, titleController, contentController),
      ],
    );
  }

  static Widget _cancelButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Navigator.pushNamedAndRemoveUntil(context, '/community', (_) => false);
        });
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        fixedSize: const Size(80.0, 40.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      child: const Text('취소'),
    );
  }

  static Widget _submitButton(BuildContext context, Map<String, dynamic>? query, TextEditingController titleController,
      TextEditingController contentController) {
    return ElevatedButton(
      onPressed: () async {
        if (accountManager.get().name is! String && context.mounted) {
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('권한 없음'),
                content: const Text('회원가입 및 로그인 후 회원만 이용 가능합니다.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('취소'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await HandleAccount.signIn(context);
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(80.0, 40.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: const Text('로그인'),
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

        if (selectedCategory is String && titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
          if (accountManager.accountArguments.name is String) {
            if (query == null) {
              int? postSuccess;
              if (context.mounted) {
                postSuccess = await HandleCommunity.postPost(
                    context, selectedCategory!, titleController.text, contentController.text);
              }
              if (postSuccess is int && context.mounted) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  Navigator.pushNamedAndRemoveUntil(context, '/community?post=$postSuccess', (_) => false);
                });
              } else {
                await HandleError.ifErroredPushError(context);
              }
            } else {
              late bool patchSuccess;
              if (context.mounted) {
                patchSuccess = await HandleCommunity.patchPost(
                    context, query['postNum']!, selectedCategory!, titleController.text, contentController.text);
              }
              if (patchSuccess && context.mounted) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/community?post=${query['postNum'].toString()}', (_) => false);
                });
              } else {
                await HandleError.ifErroredPushError(context);
              }
            }
          }
        } else {
          if (context.mounted) {
            await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('작성 오류'),
                  content: const Text('카테고리 선택이 안되었거나\n제목 및 본문이 입력되지 않았습니다.\n선택 및 입력 후 작성 버튼을 누르세요.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('확인'),
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
      },
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(80.0, 40.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      child: const Text('작성'),
    );
  }

  static Widget _postForm(
      BuildContext context,
      Map<String, dynamic>? query,
      StreamController<String?> selectedCategoryStreamController,
      TextEditingController titleController,
      TextEditingController contentController) {
    return Material(
      elevation: 8.0,
      color: Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _categorySelect(context, query, selectedCategoryStreamController),
            _titleField(query, titleController),
            const SizedBox(height: 10.0),
            _contentField(query, contentController),
          ],
        ),
      ),
    );
  }

  static Widget _categorySelect(
      BuildContext context, Map<String, dynamic>? query, StreamController<String?> selectedCategoryStreamController) {
    return FutureBuilder(
      future: HandleCommunity.getCategoryList(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<String> categoryList = snapshot.data!;

          return StreamBuilder(
              stream: selectedCategoryStreamController.stream,
              builder: (context, snapshot) {
                selectedCategory = snapshot.data;
                List<Widget> children = [];
                if (query != null && selectedCategory == null) {
                  selectedCategoryStreamController.add(query['category']);
                }

                for (var element in categoryList) {
                  children.add(
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: snapshot.data == element ? Colors.white : Colors.black,
                          backgroundColor: snapshot.data == element ? Colors.green : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        onPressed: () {
                          selectedCategoryStreamController.add(element);
                        },
                        child: Text(element),
                      ),
                    ),
                  );
                }

                return Wrap(
                  children: children,
                );
              });
        } else {
          return const SizedBox();
        }
      },
    );
  }

  static Widget _titleField(Map<String, dynamic>? query, TextEditingController titleController) {
    titleController.text = query == null ? '' : query['title']!;
    return TextFormField(
      controller: titleController,
      readOnly: query?['isAdmin'] ?? false,
      textAlignVertical: TextAlignVertical.center,
      decoration: const InputDecoration(
        hintText: '제목',
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
    );
  }

  static Widget _contentField(Map<String, dynamic>? query, TextEditingController contentController) {
    contentController.text = query == null ? '' : query['content']!;
    return TextFormField(
      controller: contentController,
      readOnly: query?['isAdmin'] ?? false,
      textAlignVertical: TextAlignVertical.top,
      decoration: const InputDecoration(
        hintText: '본문 입력',
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          borderSide: BorderSide(color: Colors.green),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        isDense: true,
      ),
      style: const TextStyle(fontSize: 14.0),
      keyboardType: TextInputType.multiline,
      minLines: 30,
      maxLines: null,
    );
  }
}

class ModifyCategory {
  static void dialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _alertDialog(context);
      },
      barrierDismissible: true,
    );
  }

  static AlertDialog _alertDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('카테고리 관리'),
      content: SizedBox(width: 400.0, height: 300.0, child: _content()),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('닫기'),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
  }

  static Widget _content() {
    StreamController<List<String>> categoryListController = StreamController<List<String>>.broadcast();

    return StreamBuilder(
      stream: categoryListController.stream,
      builder: (context, snapshot) {
        List<Widget> categoryList = [];

        if (snapshot.hasData) {
          for (var element in snapshot.data!) {
            categoryList.add(_item(context, categoryListController, element));
          }
        } else {
          HandleCommunity.getCategoryList(context).then((value) {
            categoryListController.add(value!);
          });
        }

        categoryList.add(_addCategory(context, categoryListController));

        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return categoryList[index];
          },
          itemCount: categoryList.length,
        );
      },
    );
  }

  static Widget _item(
      BuildContext context, StreamController<List<String>> categoryListController, String categoryName) {
    StreamController<bool> modifyController = StreamController<bool>.broadcast();

    return StreamBuilder(
      stream: modifyController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!) {
            TextEditingController textEditingController = TextEditingController();
            textEditingController.text = categoryName;
            return Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              child: Material(
                elevation: 8.0,
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  width: double.infinity,
                  height: 70.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: textEditingController,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: const InputDecoration(
                              hintText: '카테고리 수정',
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
                        ),
                        IconButton(
                          onPressed: () {
                            modifyController.add(false);
                          },
                          padding: EdgeInsets.zero,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: const Icon(Icons.close, size: 20.0, color: Colors.red),
                        ),
                        IconButton(
                          onPressed: () async {
                            if (textEditingController.text.isNotEmpty) {
                              List<String>? categoryList = await HandleCommunity.patchCategory(
                                  context, categoryName, textEditingController.text);
                              if (categoryList != null) {
                                categoryListController.add(categoryList);
                                modifyController.add(false);
                              }
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('카테고리 수정 오류'),
                                    content: const Text('카테고리명을 입력해주세요.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('확인'),
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
                          },
                          padding: EdgeInsets.zero,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: const Icon(Icons.check, size: 20.0, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              child: Material(
                elevation: 8.0,
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  width: double.infinity,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(categoryName),
                        const Expanded(child: SizedBox()),
                        IconButton(
                          onPressed: () {
                            modifyController.add(true);
                          },
                          padding: EdgeInsets.zero,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: const Icon(Icons.edit, size: 20.0, color: Colors.amber),
                        ),
                        IconButton(
                          onPressed: () async {
                            List<String>? categoryList = await HandleCommunity.deleteCategory(context, categoryName);
                            if (categoryList != null) {
                              categoryListController.add(categoryList);
                            }
                          },
                          padding: EdgeInsets.zero,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: const Icon(Icons.delete, size: 20.0, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        } else {
          modifyController.add(false);
          return const SizedBox();
        }
      },
    );
  }

  static Widget _addCategory(BuildContext context, StreamController<List<String>> categoryListController) {
    StreamController<bool> modifyController = StreamController<bool>.broadcast();

    return StreamBuilder(
      stream: modifyController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!) {
            TextEditingController textEditingController = TextEditingController();

            return Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              child: Material(
                elevation: 8.0,
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  width: double.infinity,
                  height: 70.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: textEditingController,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: const InputDecoration(
                              hintText: '카테고리 생성',
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
                        ),
                        IconButton(
                          onPressed: () {
                            modifyController.add(false);
                          },
                          padding: EdgeInsets.zero,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: const Icon(Icons.close, size: 20.0, color: Colors.red),
                        ),
                        IconButton(
                          onPressed: () async {
                            if (textEditingController.text.isNotEmpty) {
                              List<String>? categoryList =
                                  await HandleCommunity.postCategory(context, textEditingController.text);
                              if (categoryList != null) {
                                categoryListController.add(categoryList);
                                modifyController.add(false);
                              }
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('카테고리 생성 오류'),
                                    content: const Text('카테고리명을 입력해주세요.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('확인'),
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
                          },
                          padding: EdgeInsets.zero,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: const Icon(Icons.check, size: 20.0, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              child: Material(
                elevation: 8.0,
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  width: double.infinity,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(child: SizedBox()),
                        IconButton(
                          onPressed: () {
                            modifyController.add(true);
                          },
                          padding: EdgeInsets.zero,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: const Icon(Icons.add, size: 30.0, color: Colors.green),
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        } else {
          modifyController.add(false);
          return const SizedBox();
        }
      },
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
