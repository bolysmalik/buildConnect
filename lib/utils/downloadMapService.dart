import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Один метод: докачивает файл с места остановки.
/// Если ETag/Last-Modified/размер на сервере изменились — начинает с нуля.
Future<File> downloadWithResume(Uri url, File dest) async {
  final metaFile = File('${dest.path}.meta');

  // читаем сохранённые ETag/Last-Modified
  String? etagSaved, lmSaved;
  if (await metaFile.exists()) {
    final m = jsonDecode(await metaFile.readAsString()) as Map<String, dynamic>;
    etagSaved = m['etag'] as String?;
    lmSaved   = m['lastModified'] as String?;
  }

  // узнаём текущие заголовки сервера
  final head = await http.head(url);
  if (head.statusCode >= 400) {
    throw Exception('HEAD failed: ${head.statusCode}');
  }
  final etag = head.headers['etag'];
  final lastModified = head.headers['last-modified'];
  final serverLen = int.tryParse(head.headers['content-length'] ?? '');

  // определяем оффсет и нужно ли перекачать
  final exists = await dest.exists();
  var offset = exists ? await dest.length() : 0;
  final changed = (etagSaved != null && etag != null && etagSaved != etag) ||
      (lmSaved != null && lastModified != null && lmSaved != lastModified) ||
      (serverLen != null && offset > serverLen);

  if (changed) {
    if (exists) await dest.delete();
    offset = 0;
  }

  // готовим Range/If-Range
  final headers = <String, String>{};
  if (offset > 0) {
    headers['Range'] = 'bytes=$offset-';
    if (etag != null) headers['If-Range'] = etag;
    else if (lastModified != null) headers['If-Range'] = lastModified;
  }

  final resp = await http.get(url, headers: headers);
  if (resp.statusCode != 200 && resp.statusCode != 206) {
    throw Exception('GET failed: ${resp.statusCode}');
  }

  // если пришёл 200 при offset>0 — сервер не дал частичный: перезаписываем
  final raf = await dest.open(mode: FileMode.append);
  try {
    if (resp.statusCode == 200 && offset > 0) {
      await raf.setPosition(0);
      await raf.truncate(0);
      offset = 0;
    }
    await raf.writeFrom(resp.bodyBytes);
  } finally {
    await raf.close();
  }

  // сохраняем мету для следующих докачек
  await metaFile.writeAsString(jsonEncode({
    'etag': etag,
    'lastModified': lastModified,
    'size': serverLen,
  }));

  return dest;
}