import 'dart:html';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TestGround extends StatefulWidget {
  const TestGround({super.key});

  @override
  State<TestGround> createState() => _TestGroundState();
}

class _TestGroundState extends State<TestGround> {
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500.0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: TextField(
              controller: myController,
              decoration: const InputDecoration(
                labelText: 'Value',
                hintText: 'Enter Value for Test',
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(width: 2, color: Colors.green),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(width: 1, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              var myValue = myController.text;
              var myUri = Uri.http(
                '127.0.0.1:8001',
                '/api/test',
                {'value': myValue},
              );
              var response = await http.get(myUri);

              print(response);
            },
            style: ButtonStyle(
              fixedSize: MaterialStateProperty.all(const Size.fromHeight(50.0)),
              shape: MaterialStateProperty.all(
                const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
            child: const Text('SEND'),
          ),
        ],
      ),
    );
  }
}
