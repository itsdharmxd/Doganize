import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class Storage {
  String file;
  Storage({@required this.file});
  Future<String> get localpath async {
    final dir = await getExternalStorageDirectory();
    return dir.path;
  }

  Future<File> get localfile async {
    final path = await localpath;
    return File('$path/${this.file}');
  }

  Future<String> readData() async {
    try {
      final file = await localfile;
      String body = await file.readAsString();
      return body;
    } catch (e) {
      return e.toString();
    }
  }

  Future<File> writedata(String data) async {
    final file = await localfile;
    return file.writeAsString('$data');
  }
}
