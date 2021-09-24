import 'dart:convert';

import 'package:http/http.dart' as http;
const String baseURL = "https://api.github.com/repos/";
class ApiManager{
  static Future<http.Response> getCommits() async {
    final response = await http.get( Uri.parse(baseURL + "flutter/flutter/commits"),);
    return response;
  }
}
