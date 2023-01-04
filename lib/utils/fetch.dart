import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

generateAuthorizationHeader({ required String token }) {
  return {'Authorization': 'Bearer $token'};
}

Future<String> getTokenFromStorage() async {
  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'token');
  if (token == null) throw Exception('Token not found');
  return token;
}

const String apiUrl = 'https://protec-api.cchampou.me/api';

const String unauthorized = 'Unauthorized';

Future<dynamic> getFromApi({ required String path }) async {
  final String token = await getTokenFromStorage();
  print('token ready for request');
  final http.Response response = await http.get(Uri.parse('$apiUrl$path'), headers: generateAuthorizationHeader(token: token));
  final statusCode = response.statusCode;
  print('request executed with code $statusCode');
  if (statusCode == 401) throw Exception(unauthorized);
  final json = jsonDecode(response.body);
  return json;
}
