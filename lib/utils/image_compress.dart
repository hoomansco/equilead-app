import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<File> compressImageAndGetFile(File file, String targetPath) async {
  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 88,
    rotate: 180,
  );

  return File(result!.path);
}
