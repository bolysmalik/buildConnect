// import 'dart:io';
// import 'package:archive/archive.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:path_provider/path_provider.dart';
//
// Future<String> extractTarTilesFromAssets(String assetPath) async {
//   final dir = await getTemporaryDirectory();
//   final outputDir = Directory('${dir.path}/map_tiles');
//   if (outputDir.existsSync()) {
//     print('❌ Удаляю старые тайлы');
//     await outputDir.delete(recursive: true);
//   }
//   await outputDir.create(recursive: true);
//
//   final tarBytes = await rootBundle.load(assetPath);
//   final archive = TarDecoder().decodeBytes(tarBytes.buffer.asUint8List());
//
//   for (final file in archive.files) {
//     if (file.isFile) {
//       final outFile = File('${outputDir.path}/${file.name}');
//       await outFile.create(recursive: true);
//       await outFile.writeAsBytes(file.content as List<int>);
//     }
//   }
//
//   print('✅ Распаковано в ${outputDir.path}');
//   return outputDir.path;
// }
