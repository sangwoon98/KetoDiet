import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    Map<String, dynamic> params = widget.params;
    CommunityPostList query = CommunityPostList(0);

    if (params.isEmpty) {
      query.pageNum = 1;
    } else if (params.containsKey('page')) {
      query.pageNum = int.parse(params['page']);
      if (params.containsKey('category')) query.category = params['category'];
      if (params.containsKey('target')) query.target = params['target'];
      if (params.containsKey('keyword')) query.keyword = params['keyword'];
      if (params.containsKey('recommend')) query.recommend = true;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushReplacementNamed(context, '/community?page=1');
      });
    }

    if (query.pageNum == 0) {
      return Scaffold(
        appBar: CustomAppBar.widget(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        appBar: CustomAppBar.widget(context),
        body: FutureBuilder(
          future: HandleCommunity.getPostList(context, query),
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
}

class ForumWidget {
  static Widget widget(BuildContext context, CommunityPostList postList) {
    List<Widget> listItem = _initListItem(context, postList);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(200.0, 50.0, 200.0, 100.0),
      itemBuilder: (BuildContext context, int index) {
        return listItem[index];
      },
      itemCount: listItem.length,
    );
  }

  static List<Widget> _initListItem(BuildContext context, CommunityPostList postList) {
    List<Widget> list = [];

    list.addAll(PostListWidget.widgetList(context, postList));

    return list;
  }
}

class PostWidget {}

class CommentWidget {}

class PostListWidget {
  static List<Widget> widgetList(BuildContext context, CommunityPostList postList) {
    List<Widget> list = [];

    list.add(_menu(context, postList));
    list.add(const SizedBox(height: 10.0));
    list.add(Material(
      elevation: 8.0,
      color: Colors.white,
      borderRadius: const BorderRadius.all(Radius.circular(20.0)),
      child: Column(
        children: [
          const SizedBox(height: 5.0),
          _postList(context, postList),
          const SizedBox(height: 5.0),
          _pageNavigator(context, postList),
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
        _postButton(),
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
            Navigator.pushReplacementNamed(context, '/community?page=1');
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
            Navigator.pushReplacementNamed(context, '/community?page=1&recommend=true');
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

                      Navigator.pushReplacementNamed(context, '/community?$query');
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

                    Navigator.pushReplacementNamed(context, '/community?$query');
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

  static Widget _postButton() {
    return ElevatedButton(
      onPressed: () {
        // TODO: 글쓰기
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

  static Widget _postList(BuildContext context, CommunityPostList postList) {
    List<Widget> list = List<Widget>.empty(growable: true);

    list.add(_categoryButtons(context, postList));
    list.add(_headerRow());

    if (postList.list == null) {
      list.add(Column(
        children: [
          const SizedBox(height: 10.0),
          const Text('글이 존재하지 않습니다.'),
          const SizedBox(height: 10.0),
          Container(width: 1040.0, height: 1.0, color: Colors.grey),
        ],
      ));
    } else if (postList.list!.isEmpty) {
      list.add(Column(
        children: [
          const SizedBox(height: 10.0),
          const Text('글이 존재하지 않습니다.'),
          const SizedBox(height: 10.0),
          Container(width: 1040.0, height: 1.0, color: Colors.grey),
        ],
      ));
    } else {
      for (var element in postList.list!) {
        list.add(_postRow(element));
      }
    }
    list.add(Container(width: 1040.0, height: 1.0, color: Colors.grey));

    return Column(
      children: list,
    );
  }

  static Widget _categoryButtons(BuildContext context, CommunityPostList postList) {
    // TODO: GET category
    List<String> categoryList = ['한글됨?', 'test2', 'test3', 'test4', 'test5'];
    List<Widget> categoryButtons = [const SizedBox(width: 10.0), _allCategoryButton(context, postList)];

    for (var element in categoryList) {
      categoryButtons.add(_categoryButton(context, postList, element));
    }

    return SizedBox(
      height: 30.0,
      child: Stack(
        children: [
          Positioned(bottom: 0.0, child: Container(width: 1040.0, height: 2.0, color: Colors.grey)),
          Positioned(top: 0.0, child: Row(children: categoryButtons)),
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

          Navigator.pushReplacementNamed(context, '/community?$query');
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

        Navigator.pushReplacementNamed(context, '/community?$query');
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

  static Widget _postRow(CommunityPost communityPost) {
    DateTime createDate = communityPost.createDate;
    late String createDateString;

    if (createDate.difference(DateTime.now()).inHours > -24) {
      createDateString = DateFormat('HH:dd').format(createDate);
    } else {
      createDateString = DateFormat('yyyy-MM-dd').format(createDate);
    }

    return Column(
      children: [
        const SizedBox(height: 10.0),
        Row(
          children: [
            _expanded(Text(communityPost.postNum.toString(), textAlign: TextAlign.center)),
            // TODO: TITLE 클릭 시 글로 이동
            _expanded(Text(communityPost.title), 6),
            // TODO: NAME 클릭 시 글쓴이 검색으로 이동
            _expanded(Text(communityPost.name), 2),
            _expanded(Text(createDateString, textAlign: TextAlign.center)),
            _expanded(Text(communityPost.hit.toString(), textAlign: TextAlign.center)),
            _expanded(Text(communityPost.recommend.toString(), textAlign: TextAlign.center)),
          ],
        ),
        const SizedBox(height: 10.0),
        Container(width: 1040.0, height: 1.0, color: Colors.grey),
      ],
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
            String query = 'page=${postList.pageNum.toString()}';
            if (postList.category is String) query = '$query&category=${Uri.encodeComponent(postList.category!)}';
            if (postList.target is String) query = '$query&target=${postList.target}';
            if (postList.keyword is String) query = '$query&keyword=${Uri.encodeComponent(postList.keyword!)}';
            if (postList.recommend is bool) query = '$query&recommend=${postList.recommend}';

            Navigator.pushReplacementNamed(context, '/community?$query');
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

            Navigator.pushReplacementNamed(context, '/community?$query');
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

            Navigator.pushReplacementNamed(context, '/community?$query');
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

            Navigator.pushReplacementNamed(context, '/community?$query');
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

            Navigator.pushReplacementNamed(context, '/community?$query');
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
