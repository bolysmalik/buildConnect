import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Определяем тип для функции обратного вызова
typedef ProgressCallback = void Function(int downloaded, int total);

/// Один метод: докачивает файл с места остановки, используя потоковую передачу (Stream).
/// Если ETag/Last-Modified/размер на сервере изменились — начинает с нуля.
Future<File> downloadWithResume(Uri url, File dest, {ProgressCallback? onProgress}) async {
  final metaFile = File('${dest.path}.meta');

  // читаем сохранённые ETag/Last-Modified
  String? etagSaved, lmSaved;
  if (await metaFile.exists()) {
    final m = jsonDecode(await metaFile.readAsString()) as Map<String, dynamic>;
    etagSaved = m['etag'] as String?;
    lmSaved   = m['lastModified'] as String?;
  }

  // === 1. Получение метаданных ===
  // Используем GET с диапазоном (bytes=0-0) для имитации HEAD и получения заголовков
  final headResponse = await http.get(url, headers: {'Range': 'bytes=0-0'});

  if (headResponse.statusCode >= 400 && headResponse.statusCode != 200 && headResponse.statusCode != 206) {
    throw Exception('GET failed for HEAD check: ${headResponse.statusCode}');
  }

  final etag = headResponse.headers['etag'];
  final lastModified = headResponse.headers['last-modified'];
  final serverLen = int.tryParse(headResponse.headers['content-length'] ?? '');
  final totalBytes = serverLen ?? 0;

  // === 2. Проверка изменений и определение смещения ===
  final exists = await dest.exists();
  var offset = exists ? await dest.length() : 0;

  // 💡 НОВЫЙ БЛОК ЛОГИКИ: Сброс файла, если локальный размер больше или равен размеру сервера (Fix 416)
  if (exists && serverLen != null && serverLen > 0 && offset >= serverLen) {
    print('DEBUG: Local file size (${(offset / 1024 / 1024).toStringAsFixed(2)} MB) is equal to or larger than server size (${(serverLen / 1024 / 1024).toStringAsFixed(2)} MB). Deleting and restarting.');
    await dest.delete();
    offset = 0; // Начинаем с нуля
  }
  // 💡 КОНЕЦ НОВОГО БЛОКА

  // Старая логика проверки, которая включает ETag/Last-Modified
  final changed = (etagSaved != null && etag != null && etagSaved != etag) ||
      (lmSaved != null && lastModified != null && lmSaved != lastModified) ||
      (serverLen != null && offset > serverLen); // Эта строка теперь частично дублируется, но оставлена для ETag/LM

  if (changed) {
    if (exists) await dest.delete();
    offset = 0;
  }

  // Если после всех проверок файл оказался полным, выходим
  if (offset == totalBytes && totalBytes > 0) {
    print('DEBUG: File is already complete, skipping download.');
    onProgress?.call(offset, totalBytes);
    return dest;
  }

  // 💡 Вызов колбэка для отображения начального прогресса
  onProgress?.call(offset, totalBytes);

  // === 3. Подготовка запроса Range и клиента ===
  final headers = <String, String>{};
  if (offset > 0) {
    headers['Range'] = 'bytes=$offset-';
    if (etag != null) headers['If-Range'] = etag;
    else if (lastModified != null) headers['If-Range'] = lastModified;
  }

  final client = http.Client();
  final request = http.Request('GET', url);
  request.headers.addAll(headers);

  // === 4. ПОТОКОВАЯ ЗАГРУЗКА И ЗАПИСЬ ===
  final response = await client.send(request);

  if (response.statusCode != 200 && response.statusCode != 206) {
    client.close();
    throw Exception('GET failed: ${response.statusCode}');
  }

  // Если пришел 200 при offset>0 — сервер не дал частичный: перезаписываем
  final appendMode = (response.statusCode == 200 && offset > 0) ? FileMode.write : FileMode.append;

  final raf = await dest.open(mode: appendMode);
  if (response.statusCode == 200 && offset > 0) {
    // Сброс оффсета и файла при полном скачивании
    await raf.truncate(0);
    offset = 0;
  }

  try {
    await for (final chunk in response.stream) {
      await raf.writeFrom(chunk);
      offset += chunk.length;

      // 💡 Вызов колбэка при получении каждого куска данных
      onProgress?.call(offset, totalBytes);
    }
  } catch (e) {
    throw Exception('Stream download failed: $e');
  } finally {
    await raf.close();
    client.close(); // Закрываем клиент после завершения/ошибки
  }

  // === 5. Сохранение метаданных ===
  await metaFile.writeAsString(jsonEncode({
    'etag': etag,
    'lastModified': lastModified,
    'size': serverLen,
  }));

  return dest;
}