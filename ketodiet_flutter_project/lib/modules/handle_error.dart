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
  ErrorArgs? errorArgs;

  ErrorManager() {
    streamController.stream.listen((event) {
      errorArgs = event;
    });
  }

  ErrorArgs? get() {
    return errorArgs;
  }

  void set([ErrorArgs? errorArgs]) {
    streamController.add(errorArgs);
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
        return const AlertDialog(
          title: Text(
            'ERROR!!!',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        );
      },
    );
  }

  static Future<void> ifErroredPushError(BuildContext context) async {
    if (isErrored()) await pushError(context);
  }
}
