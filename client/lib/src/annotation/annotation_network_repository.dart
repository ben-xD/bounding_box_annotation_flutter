import 'dart:convert';

import 'package:banananator/src/annotation/annotation.dart';
import 'package:banananator/src/constants.dart';
import 'package:http/http.dart' as http;

class AnnotationNetworkRepository {
  Future<List<AnnotationJob>> fetchAnnotationJobs() async {
    final endpoint = Constants.apiUrl.resolve("api/annotations/jobs");
    final response = await http.get(endpoint);
    final List<dynamic> json = jsonDecode(response.body);
    return json.map((e) => AnnotationJob.fromJson(e)).toList();
  }

  Future<void> submitAnnotation(Annotation annotation) async {
    final endpoint = Constants.apiUrl.resolve("api/annotations");
    final json = annotation.toJson();
    final jsonString = jsonEncode(json);
    await http.post(endpoint, body: jsonString);
    return;
  }

  Future<List<Annotation>> getAnnotations() async {
    final endpoint = Constants.apiUrl.resolve("/api/annotations");
    try {
      final response = await http.get(endpoint);
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => Annotation.fromJson(e)).toList();
    } on http.ClientException catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> deleteAnnotations() async {
    final endpoint = Constants.apiUrl.resolve("/api/annotations");
    try {
      final response = await http.delete(endpoint);
      if (response.statusCode == 200) {
        return;
      }
      throw Exception("Unexpected status code: ${response.statusCode}");
    } on http.ClientException catch (e) {
      print(e);
    }
  }
}
