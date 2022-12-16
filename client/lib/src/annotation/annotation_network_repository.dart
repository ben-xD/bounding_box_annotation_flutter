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
      if (response.statusCode != 200) {
        print("Error: ${response.body}");
      }
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
      final result = await http.post(endpoint, body: jsonString);
      if (result.statusCode != 201) {
        print("Error: ${result.body}");
      }
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
      await http.get(Uri.parse(imageUrl));
      return;
    }
    final uri = Uri.parse(imageUrl);
    final response = await http.get(uri);
    final documentDirectory = await getApplicationDocumentsDirectory();
    final imageDirectory = "${documentDirectory.path}/images";
    await Directory(imageDirectory).create(recursive: true);
    final file = File(imageDirectory + uri.pathSegments.last);
    await file.writeAsBytes(response.bodyBytes);
  }

  Future<String?> getImagePathFor(AnnotationJob job) async {
    final uri = Uri.parse(job.imageUriOriginal);
    final documentDirectory = await getApplicationDocumentsDirectory();
    final imageDirectory = "${documentDirectory.path}/images";
    final file = File(imageDirectory + uri.pathSegments.last);
    if (!(await file.exists())) return null;
    return file.path;
  }

  Future<void> createJobWithImage(String name,
      {Uint8List? bytes, String? path}) async {
    if (bytes == null) {
      if (path == null) {
        throw RepositoryException(
            "Both path and bytes were null. There is no image to upload.");
      }
      // Read from the path if we don't have the raw bytes.
      bytes = await File(path).readAsBytes();
    }
    // file.bytes is null on Desktop, and used on web.
    // file.path is null on Web, and used on Desktop.
    final endpoint = Constants.apiUrl.resolve("/images/$name");
    try {
      final response = await http.put(endpoint, body: bytes);
      if (response.statusCode == 201) {
        // Seems to cause an exception: I don't have permissions?
        // final ext = await getExternalStorageDirectory();
        // Useful debugging code to write file to disk. Run on desktop build
        // final documentDirectory = await getApplicationDocumentsDirectory();
        // final imageDirectory = "${documentDirectory.path}/images";
        // final file = File("$imageDirectory/downloaded-$name");
        // file.writeAsBytesSync(response.bodyBytes, flush: true);
        return;
      } else {
        print(response.body);
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

  Future<void> deleteJobs() async {
    final endpoint = Constants.apiUrl.resolve("api/annotations/jobs");
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
