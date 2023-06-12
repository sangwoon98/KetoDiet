import 'dart:async';

import 'package:flutter/material.dart';

import '../modules/handle.dart';
import '../modules/layout.dart';

class AdminPage extends StatefulWidget {
  final Map<String, dynamic> query;

  const AdminPage(this.query, {super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  void initState() {
    if (widget.query.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.pushNamedAndRemoveUntil(context, '/admin', (_) => false);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold.scaffold(
      context: context,
      body: AdminPageWidget.widget(context),
    );
  }
}

class AdminPageWidget {
  static Widget widget(BuildContext context) {
    return StreamBuilder(
      stream: accountManager.isAdminStreamController.stream,
      builder: (context, snapshot) {
        if (snapshot.data != accountManager.accountArguments.isAdmin) {
          accountManager.isAdminStreamController.add(accountManager.accountArguments.isAdmin);
        }

        if (snapshot.data == true) {
          return _accountListWidget(context);
        } else if (snapshot.data == false) {
          return const Center(child: Text('관리자 권한이 없습니다.'));
        } else {
          return const Center(child: Text('로그인 후 관리자만 접근 가능한 페이지 입니다.'));
        }
      },
    );
  }

  static Widget _accountListWidget(BuildContext context) {
    StreamController<Future<UserList>> userListController = StreamController<Future<UserList>>.broadcast();

    return StreamBuilder(
      stream: userListController.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          userListController.add(UserList.init(page: 1));
          return const Center(child: CircularProgressIndicator());
        } else {
          return FutureBuilder(
            future: snapshot.data,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Widget> list = [];
                double deviceSize = MediaQuery.of(context).size.width;
                ScrollController scrollController = ScrollController();

                list.add(_searchBar(context, snapshot.data!, userListController));
                list.add(
                  Card(
                    color: Colors.white,
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    child: Column(
                      children: [
                        const SizedBox(height: 5.0),
                        SizedBox(
                            width: deviceSize >= desktop ? 1024.0 : null,
                            child: _userList(context, snapshot.data!, userListController)),
                        const SizedBox(height: 5.0),
                        SizedBox(
                            width: deviceSize >= desktop ? 1024.0 : null,
                            child: _pageNavigator(context, snapshot.data!, userListController, scrollController)),
                        const SizedBox(height: 5.0),
                      ],
                    ),
                  ),
                );

                return ListView.builder(
                  controller: scrollController,
                  padding: deviceSize >= 1024
                      ? EdgeInsets.only(left: (deviceSize - 1024) / 2, right: (deviceSize - 1024) / 2)
                      : null,
                  itemBuilder: (BuildContext context, int index) {
                    return list[index];
                  },
                  itemCount: list.length,
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
        }
      },
    );
  }

  static Widget _searchBar(BuildContext context, UserList userList, StreamController userListController) {
    final searchController = TextEditingController();
    searchController.text = userList.keyword != null ? userList.keyword! : '';

    return Card(
      color: Colors.white,
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: SizedBox(
        height: 40.0,
        child: Stack(
          children: [
            Positioned(
              left: 0.0,
              right: 70.0,
              child: SizedBox(
                width: 200.0,
                height: 40.0,
                child: TextFormField(
                  controller: searchController,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                    hintText: '닉네임 검색어 입력',
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
                    contentPadding: EdgeInsets.only(left: 10.0, right: 10.0),
                  ),
                  onFieldSubmitted: (value) async {
                    if (searchController.text.isNotEmpty) {
                      userListController.add(UserList.init(page: 1, keyword: searchController.text));
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
              top: 0.0,
              right: 0.0,
              bottom: 0.0,
              width: 70.0,
              child: ElevatedButton(
                onPressed: () async {
                  if (searchController.text.isNotEmpty) {
                    userListController.add(UserList.init(page: 1, keyword: searchController.text));
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

  static Widget _userList(BuildContext context, UserList userList, StreamController userListController) {
    List<Widget> list = List<Widget>.empty(growable: true);

    list.add(_headerRow(context));

    for (var element in userList.list!) {
      list.add(_userRow(context, userList, element, userListController));
    }

    list.add(const Divider(height: 2.0, thickness: 2.0, color: Colors.grey));

    return Column(
      children: list,
    );
  }

  static Widget _headerRow(BuildContext context) {
    double deviceSize = MediaQuery.of(context).size.width;
    if (deviceSize >= tablet) {
      return Column(
        children: [
          const SizedBox(height: 10.0),
          Row(
            children: [
              _expanded(const Text('회원번호', textAlign: TextAlign.center), 3),
              _expanded(const Text('닉네임'), 5),
              _expanded(const Text('관리자 설정/해제', textAlign: TextAlign.center), 3),
              const SizedBox(width: 10.0),
              _expanded(const Text('강제 탈퇴', textAlign: TextAlign.center), 3),
              const SizedBox(width: 10.0),
            ],
          ),
          const SizedBox(height: 10.0),
          Container(width: 1040.0, height: 2.0, color: Colors.grey),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  static Widget _userRow(
      BuildContext context, UserList userList, UserInfo userInfo, StreamController userListController) {
    double deviceSize = MediaQuery.of(context).size.width;

    if (deviceSize >= tablet) {
      return Column(
        children: [
          const SizedBox(height: 10.0),
          Row(
            children: [
              _expanded(
                Text(
                  userInfo.uid.toString(),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  softWrap: false,
                ),
                3,
              ),
              _expanded(Text(userInfo.name, overflow: TextOverflow.fade, maxLines: 1, softWrap: false), 5),
              _expanded(_adminSettingButton(userList, userInfo, userListController), 3),
              const SizedBox(width: 10.0),
              _expanded(_userDropButton(context, userList, userInfo, userListController), 3),
              const SizedBox(width: 10.0),
            ],
          ),
          const SizedBox(height: 10.0),
          userInfo.uid == userList.list!.last.uid
              ? const SizedBox()
              : const Divider(height: 1.0, thickness: 1.0, color: Colors.grey),
        ],
      );
    } else {
      return Column(
        children: [
          const SizedBox(height: 10.0),
          Row(
            children: [
              _expanded(
                Text(
                  userInfo.uid.toString(),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  softWrap: false,
                ),
                3,
              ),
              _expanded(Text(userInfo.name, overflow: TextOverflow.fade, maxLines: 1, softWrap: false), 5),
              _expanded(
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: double.maxFinite,
                      child: _adminSettingButton(userList, userInfo, userListController),
                    ),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      width: double.maxFinite,
                      child: _userDropButton(context, userList, userInfo, userListController),
                    ),
                  ],
                ),
                3,
              ),
              const SizedBox(width: 10.0),
            ],
          ),
          const SizedBox(height: 10.0),
          userInfo.uid == userList.list!.last.uid
              ? const SizedBox()
              : const Divider(height: 1.0, thickness: 1.0, color: Colors.grey),
        ],
      );
    }
  }

  static Widget _adminSettingButton(UserList userList, UserInfo userInfo, StreamController userListController) {
    return ElevatedButton(
      onPressed: () async {
        userListController.add(HandleAdmin.patchAdmin(userList, userInfo));
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: userInfo.isAdmin ? Colors.white : Colors.black,
        backgroundColor: userInfo.isAdmin ? Colors.green : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
      child: Text(userInfo.isAdmin ? '관리자 해제' : '관리자 설정'),
    );
  }

  static Widget _userDropButton(
      BuildContext context, UserList userList, UserInfo userInfo, StreamController userListController) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                '정말 탈퇴 시키겠습니까?',
                style: TextStyle(color: Colors.red),
              ),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('UID: '),
                          Text('닉네임: '),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${userInfo.uid}'),
                          Text(userInfo.name),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        userListController.add(HandleAdmin.deleteUser(userList, userInfo));
                        if (context.mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        fixedSize: const Size(200.0, 50.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      child: const Text('네, 탈퇴 처리합니다.'),
                    ),
                  ),
                  _padding(_closeButton(context), 10, 10, 10, 0),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
      child: const Text('강제 탈퇴'),
    );
  }

  static Widget _padding(Widget child, double left, double top, double right, double bottom) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: child,
    );
  }

  static Widget _closeButton(BuildContext context) {
    return TextButton(
      onPressed: () async {
        Navigator.pop(context);
      },
      child: const Text('돌아가기', style: TextStyle(color: Colors.grey)),
    );
  }

  static Widget _expanded(Widget child, [int flex = 1]) {
    return Expanded(
      flex: flex,
      child: child,
    );
  }

  static Widget _pageNavigator(
      BuildContext context, UserList userList, StreamController userListController, ScrollController scrollController) {
    List<Widget> pageButtons = [];

    if (userList.pageCount == null) {
      return const SizedBox();
    }

    double deviceSize = MediaQuery.of(context).size.width;

    int minPage = userList.pageNum - (deviceSize >= tablet ? 4 : 2);
    int maxPage = userList.pageNum + (deviceSize >= tablet ? 5 : 2);

    while (true) {
      if (minPage < 1 && maxPage >= userList.pageCount!) {
        minPage = 1;
        maxPage = userList.pageCount!;
      } else if (minPage < 1) {
        minPage++;
        maxPage++;
      } else if (maxPage > userList.pageCount!) {
        minPage--;
        maxPage--;
      } else {
        break;
      }
    }

    if (minPage > 1) {
      pageButtons.add(_firstPageButton(context, userList, userListController, scrollController));
      pageButtons.add(_previousButton(context, userList, userListController, scrollController));
    }

    for (int i = minPage; i <= maxPage; i++) {
      pageButtons.add(_pageButton(context, userList, userListController, i, scrollController));
    }

    if (maxPage < userList.pageCount!) {
      pageButtons.add(_nextButton(context, userList, userListController, scrollController));
      pageButtons.add(_lastPageButton(context, userList, userListController, scrollController));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pageButtons,
    );
  }

  static Widget _pageButton(BuildContext context, UserList userList, StreamController userListController, int pageNum,
      ScrollController scrollController) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizedBox(
        width: pageNum < 1000 ? 30.0 : null,
        height: 30.0,
        child: ElevatedButton(
          onPressed: () {
            userListController.add(UserList.init(page: pageNum, keyword: userList.keyword));

            scrollController.jumpTo(0.0);
          },
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(userList.pageNum == pageNum ? Colors.white : Colors.black),
            backgroundColor: MaterialStateProperty.all(userList.pageNum == pageNum ? Colors.green : Colors.transparent),
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

  static Widget _firstPageButton(
      BuildContext context, UserList userList, StreamController userListController, ScrollController scrollController) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizedBox(
        width: 30.0,
        height: 30.0,
        child: ElevatedButton(
          onPressed: () {
            userListController.add(UserList.init(page: 1, keyword: userList.keyword));

            scrollController.jumpTo(0.0);
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

  static Widget _lastPageButton(
      BuildContext context, UserList userList, StreamController userListController, ScrollController scrollController) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizedBox(
        width: 30.0,
        height: 30.0,
        child: ElevatedButton(
          onPressed: () {
            userListController.add(UserList.init(page: userList.pageCount!, keyword: userList.keyword));

            scrollController.jumpTo(0.0);
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

  static Widget _previousButton(
      BuildContext context, UserList userList, StreamController userListController, ScrollController scrollController) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizedBox(
        width: 30.0,
        height: 30.0,
        child: ElevatedButton(
          onPressed: () {
            double deviceSize = MediaQuery.of(context).size.width;

            if (userList.pageNum - (deviceSize >= tablet ? 10 : 5) < 1) {
              userListController.add(UserList.init(page: 1, keyword: userList.keyword));
            } else {
              userListController.add(
                  UserList.init(page: userList.pageNum - (deviceSize >= tablet ? 10 : 5), keyword: userList.keyword));
            }

            scrollController.jumpTo(0.0);
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

  static Widget _nextButton(
      BuildContext context, UserList userList, StreamController userListController, ScrollController scrollController) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizedBox(
        width: 30.0,
        height: 30.0,
        child: ElevatedButton(
          onPressed: () {
            double deviceSize = MediaQuery.of(context).size.width;

            if (userList.pageNum + (deviceSize >= tablet ? 10 : 5) > userList.pageCount!) {
              userListController.add(UserList.init(page: userList.pageCount!, keyword: userList.keyword));
            } else {
              userListController.add(
                  UserList.init(page: userList.pageNum + (deviceSize >= tablet ? 10 : 5), keyword: userList.keyword));
            }

            scrollController.jumpTo(0.0);
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
