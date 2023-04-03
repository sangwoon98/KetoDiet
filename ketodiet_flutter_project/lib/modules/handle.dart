import 'package:flutter/material.dart';

class ErrorArgs {
  final String error;
  final String route;
  final String file;
  final String method;

  ErrorArgs(this.error, this.route, this.file, this.method);
}

Future handleError(context, error, file, method) async {
  await Navigator.popAndPushNamed(
    context,
    '/error',
    arguments: ErrorArgs(
      '$error',
      '${ModalRoute.of(context)?.settings.name}',
      '$file',
      '$method',
    ),
  );
}

class SignArgs {
  final String signType;

  SignArgs(this.signType);
}

void handleSign(context, signType) {
  Navigator.pushNamed(
    context,
    '/sign',
    arguments: SignArgs('$signType'),
  );
}
