import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageHelper {

  static Future<File> compress(
      File file,
      ) async {

    final dir =
    await getTemporaryDirectory();

    final targetPath =
        "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final result =
    await FlutterImageCompress.compressAndGetFile(

      file.absolute.path,

      targetPath,

      quality: 80,

      minWidth: 1280,

      minHeight: 1280,

    );

    return File(result!.path);
  }
}