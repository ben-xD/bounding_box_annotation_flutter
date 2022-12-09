import 'dart:convert';
import 'dart:io';

import 'package:banananator/src/annotation/models/annotation.dart';
import 'package:banananator/src/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';


class AnnotationNetworkRepository {
  Future<List<AnnotationJob>> fetchAnnotationJobs() async {
    final endpoint = Constants.apiUrl.resolve("api/annotations/jobs");
    try {
      final response = await http.get(endpoint);
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => AnnotationJob.fromJson(e)).toList();
    } on http.ClientException catch (e) {
      throw RepositoryException(e.message);
    }
  }

  Future<void> submitAnnotation(Annotation annotation) async {
    final endpoint = Constants.apiUrl.resolve("api/annotations");
    final json = annotation.toJson();
    final jsonString = jsonEncode(json);
    try {
      await http.post(endpoint, body: jsonString);
    } on http.ClientException catch (e) {
      throw RepositoryException(e.message);
    }
  }

  Future<List<Annotation>> getAnnotations() async {
    final endpoint = Constants.apiUrl.resolve("/api/annotations");
    try {
      final response = await http.get(endpoint);
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => Annotation.fromJson(e)).toList();
    } on http.ClientException catch (e) {
      throw RepositoryException(e.message);
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
      throw RepositoryException(e.message);
    }
  }

  Future<void> downloadImage(String imageUrl) async {
    if (kIsWeb) {
      // Manually download each image to use the browser cache.
      return http.get(Uri.parse(imageUrl)).then((response) => null);
    };
    final uri = Uri.parse(imageUrl);
    final response = await http.get(uri);
    final documentDirectory = await getApplicationDocumentsDirectory();
    final imageDirectory = "${documentDirectory.path}/images";
    await Directory(imageDirectory).create(recursive: true);
    final file = File(imageDirectory + uri.pathSegments.last);
    await file.writeAsBytes(response.bodyBytes);
  }

  Future<void> uploadImage(String name, Uint8List bytes) async {
    final endpoint = Constants.apiUrl.resolve("/images/$name");
    try {
      final response = await http.put(endpoint, body: bytes);
      if (response.statusCode == 201) {
        return;
      }
      throw Exception("Unexpected status code: ${response.statusCode}");
    } on http.ClientException catch (e) {
      throw RepositoryException(e.message);
    }
  }

  Future<void> deleteJob(String id) async {
    final endpoint = Constants.apiUrl.resolve("api/annotations/jobs/$id");
    try {
      final response = await http.delete(endpoint);
      if (response.statusCode == 200) {
        return;
      }
      throw Exception("Unexpected status code: ${response.statusCode}");
    } on http.ClientException catch (e) {
      throw RepositoryException(e.message);
    }
  }
}

class RepositoryException implements Exception {
  String message;

  RepositoryException(this.message);
}
