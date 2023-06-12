import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ketodiet_flutter_project/modules/handle.dart';

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(errorManager.get()?.error is String ? errorManager.get()!.error : 'null'),
              Text(errorManager.get()?.file is String ? errorManager.get()!.file : 'null'),
              Text(errorManager.get()?.method is String ? errorManager.get()!.method : 'null'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  Navigator.pushNamedAndRemoveUntil(context, currentPath is String ? currentPath! : '/', (_) => false);
                });
              },
              child: const Text('CLOSE', style: TextStyle(color: Colors.red)),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
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
