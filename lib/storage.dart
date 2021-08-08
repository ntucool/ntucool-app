import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<File> getApplicationDocumentsDirectoryFile(
    Iterable<String> parts) async {
  var directory = await getApplicationDocumentsDirectory();
  return File(p.joinAll([directory.path, ...parts]));
}

const cookieParts = ['cookies.json'];

Future<File> get cookieFile =>
    getApplicationDocumentsDirectoryFile(cookieParts);
