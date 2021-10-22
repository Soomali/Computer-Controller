import 'dart:convert';
import 'dart:io';

import 'package:server_app/entities.dart';

class Client {
  static final _host = 'YOUR_LAN_IP';
  static final _port = 8080;
  static final _client = HttpClient();
  static Future<List<String>> getFileList({String path = 'C:\\'}) async {
    var req = await _client.post(_host, _port, "/get/");
    req.write(path);
    var resp = await req.close();
    return resp.transform(utf8.decoder).toList();
  }

  static Future<bool> deleteFile(ComputerFileData data) async {
    final ext = data.extension == '.' ? '' : data.extension;
    var completePath = '${data.path}\\${data.name}$ext';
    var req = await _client.post(_host, _port, '/delete/');
    req.write(completePath);
    var resp = await req.close();
    return (await resp.transform(utf8.decoder).toList()).first ==
        'File Deleted';
  }

  static Future<String> getFileContent(ComputerFileData data) async {
    final req = await _client.post(_host, _port, "/read/");
    req.write('${data.path}\\${data.name}${data.extension}');
    final resp = await req.close();
    final list = await resp.transform(utf8.decoder).toList();
    return list.first;
  }

  static Future<void> updateFileContent(
      ComputerFileData data, String newContent) async {
    final req = await _client.post(_host, _port, '/update/');
    final jsonMap = {'file': '${data.path}\\$data', 'content': newContent};
    final encodedJson = jsonEncode(jsonMap);
    req.write(encodedJson);
    try {
      await req.close();
    } catch (e) {
      return;
    }
  }
}
