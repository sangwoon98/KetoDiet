import 'dart:async';

import 'package:flutter/material.dart';

ErrorManager errorManager = ErrorManager();

class ErrorArgs {
  final String error;
  final String file;
  final String method;

  ErrorArgs(this.error, this.file, this.method);
}

class ErrorManager {
  StreamController<ErrorArgs?> streamController = StreamController<ErrorArgs?>.broadcast();
  ErrorArgs? errorArguments;

  ErrorManager() {
    streamController.stream.listen((event) {
      errorArguments = event;
    });
  }

  ErrorArgs? get() {
    return errorArguments;
  }

  void set([ErrorArgs? errorArgs]) {
    streamController.add(errorArgs);
    errorArguments = errorArgs;
  }

  void clear() {
    streamController.add(null);
  }
}

class HandleError {
  static bool isErrored() {
    if (errorManager.get() is ErrorArgs) {
      return true;
    } else {
      return false;
    }
  }

  static Future<void> pushError(BuildContext context) async {
    // TODO: Dialog 디자인
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'ERROR!!!',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(errorManager.get()?.error is String ? errorManager.get()!.error : 'null'),
              Text(errorManager.get()?.file is String ? errorManager.get()!.file : 'null'),
              Text(errorManager.get()?.method is String ? errorManager.get()!.method : 'null'),
            ],
          ),
        );
      },
      barrierDismissible: false,
    );
  }

  static Future<void> ifErroredPushError(BuildContext context) async {
    if (isErrored()) await pushError(context);
  }
}
