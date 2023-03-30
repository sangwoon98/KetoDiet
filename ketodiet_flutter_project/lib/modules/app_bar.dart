import 'package:flutter/material.dart';

AppBar appBar(context) {
  return AppBar(
    automaticallyImplyLeading: false,
    toolbarHeight: AppBar().preferredSize.height,
    title: Row(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        homeButton(context),
        pageButton(context, '/test', 'TestPage'),
        pageButton(context, '/test', 'TestPage'),
        pageButton(context, '/test', 'TestPage'),
        pageButton(context, '/test', 'TestPage'),
      ],
    ),
  );
}

Widget homeButton(context) {
  return Padding(
    padding: const EdgeInsets.only(left: 10),
    child: SizedBox(
      height: AppBar().preferredSize.height,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/');
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0.0, 2.0, 4.0, 2.0),
                child: Image(
                  image: AssetImage('assets/images/beef.png'),
                ),
              ),
              Text(
                'KetoDiet',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: AppBar().preferredSize.height / 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget pageButton(context, String path, String displayedName) {
  return Padding(
    padding: const EdgeInsets.only(left: 10),
    child: SizedBox(
      height: AppBar().preferredSize.height,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, path);
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          child: Text(
            displayedName,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  );
}
