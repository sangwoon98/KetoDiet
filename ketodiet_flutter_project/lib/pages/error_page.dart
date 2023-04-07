// import 'package:flutter/material.dart';
// import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

// import '../modules/handle.dart';

// // TODO: ErrorPage 수정 (로직, 디자인);

// class ErrorPage extends StatefulWidget {
//   const ErrorPage({super.key});

//   @override
//   State<ErrorPage> createState() => _ErrorPageState();
// }

// class _ErrorPageState extends State<ErrorPage> {
//   @override
//   Widget build(BuildContext context) {
//     ErrorArgs? errorArgs =
//         ModalRoute.of(context)?.settings.arguments as ErrorArgs?;

//     if (errorArgs == null) {
//       reset(context);
//     } else {
//       // ignore: avoid_print
//       print('ERROR!!!\n\nMassage: ${errorArgs.error}\n\nFrom:\n -Route: ${errorArgs.route}\n -File: ${errorArgs.file}\n -method: ${errorArgs.method}');
//     }

//     return Scaffold(
//       body: Center(
//         child: Container(
//           color: Colors.red,
//           width: double.maxFinite,
//           height: double.maxFinite,
//         ),
//       ),
//     );
//   }
// }

// Future<void> reset(context) async {
//   print('야 너 토큰 가지고 있냐??');
//   if (await AuthApi.instance.hasToken()) {
//     print('그거 불법 토큰이야 내놔');
//     await TokenManagerProvider.instance.manager.clear();
//     print('토큰 압수~');
//   }
//   // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//   //   print('메인 페이지로 돌아가쇼.');
//   //   Navigator.pushReplacementNamed(context, '/');
//   // });
// }
