import 'package:flutter/material.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '페이지를 찾을 수\n없습니다!',
                  style: TextStyle(color: Colors.green, fontSize: 48.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.0),
                Text(
                  '잘못된 페이지를 입력하였거나\n오류가 발생했습니다.',
                  style: TextStyle(fontSize: 18.0),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                });
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(80.0, 40.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: const Text('홈으로'),
            ),
          ],
        ),
      ),
    );
  }
}
