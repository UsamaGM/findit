import 'dart:convert' show jsonEncode;
import 'dart:developer';

import 'package:http/http.dart';

class HttpService {
  static const host = "localhost";
  static const port = 3000;
  // static const server = "https://outgoing-endlessly-locust.ngrok-free.app";
  static const server = "http://$host:$port";
  static const headers = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  };

  final Client http = Client();

  Future<Response> get({
    required String route,
    Map<String, dynamic>? queryParams,
  }) async {
    final Uri uri =
        Uri.parse("$server/$route").replace(queryParameters: queryParams);
    return await http.get(uri, headers: headers);
  }

  Future<Response> post({
    required String route,
    required Map<String, dynamic> body,
  }) async {
    log(body.toString());
    return await http.post(
      Uri.parse("$server/$route"),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<Response> put({
    required String route,
    required Map<String, dynamic> body,
  }) async {
    return await http.put(
      Uri.parse("$server/$route"),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<Response> delete({
    required String route,
    required Map<String, dynamic> body,
  }) async {
    return await http.delete(
      Uri.parse("$server/$route"),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  void close() => http.close();
}
