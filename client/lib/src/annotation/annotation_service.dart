import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:banananator/src/annotation/annotation_local_repository.dart';
import 'package:banananator/src/annotation/annotation_network_repository.dart';
import 'package:flutter/material.dart';

import 'models/annotation.dart';

class AnnotationService extends ChangeNotifier {
  final AnnotationNetworkRepository networkRepository;
  final AnnotationLocalRepository localRepository;

  final Map<String, AnnotationJob> _jobByJobId = {};
  final _completedJobIds = <String>{};

  int get jobsDownloaded => localRepository.getJobs().length;

  AnnotationService(
      {required this.networkRepository, required this.localRepository});

  Iterable<Annotation> getNotSubmittedAnnotations() {
    return localRepository.getAnnotations();
  }

  // Future<List<Image>> downloadImages(int maxQuantity) {
  //
  // }
  // Challenge: persist images for later use.
  // Future<List<Path>> downloadImages(int maxQuantity) {
  //
  // }

  Future<void> skipAnnotationJob(jobId) async {
    _completedJobIds.add(jobId);
  }

  Future<bool> submitAnnotation(Annotation annotation) async {
    _completedJobIds.add(annotation.annotationJobID);
    localRepository.saveAnnotation(annotation); // Persist it in case it errors.
    try {
      await networkRepository.submitAnnotation(annotation);
      localRepository.removeAnnotation(annotation);
      notifyListeners();
      return true;
    } on RepositoryException catch (_) {
      notifyListeners();
      return false;
    }
  }

  Future<List<Annotation>> getAnnotations() async {
    final annotations = await networkRepository.getAnnotations();
    annotations.sort((a, b) => a.annotatedOn.compareTo(b.annotatedOn));
    return annotations.reversed.toList();
  }

  downloadAllJobs() async {
    final jobs = await fetchJobs();
    await _cacheImage(jobs);
    notifyListeners();
  }

  Future<void> _cacheImage(Iterable<AnnotationJob> jobs) async {
    // Download images in parallel:
    final futures =
        jobs.map((j) => networkRepository.downloadImage(j.imageUrl));
    await Future.wait(futures);
  }

  FutureOr<AnnotationJob?> getNextJob() async {
    // Take one that hasn't been completed:
    final jobIds = _jobByJobId.keys.toSet().difference(_completedJobIds);
    if (jobIds.isEmpty) return null;
    return _jobByJobId[jobIds.first];
  }

  Future<List<AnnotationJob>> fetchJobs() async {
    final jobs = await networkRepository.fetchAnnotationJobs();
    for (final job in jobs) {
      _jobByJobId[job.id] = job;
    }
    return jobs;
  }

  Future<AnnotationJob> getJob(String jobId) async {
    if (!_jobByJobId.containsKey(jobId)) {
      await fetchJobs(); // Doesn't exist locally, so fetch it.
    }
    final job = _jobByJobId[jobId];
    if (job != null) {
      return job;
    }
    throw RepositoryException("Job $jobId was not found");
  }

  Future<void> deleteAnnotations() async {
    await networkRepository.deleteAnnotations();
    await localRepository.deleteAnnotations();
  }

  /// Returns number of annotations that failed to upload.
  Future<int> submitNotSubmittedAnnotations() async {
    final annotations = localRepository.getAnnotations();
    final List<Future<bool>> successesFuture = [];
    for (final annotation in annotations) {
      successesFuture.add(submitAnnotation(annotation));
    }
    final successes = await Future.wait(successesFuture);
    notifyListeners();
    return successes
        .where((e) => !e)
        .toList()
        .length; // Number of failed requests
  }

  Future<void> uploadImage(String name, Uint8List bytes) async {
    await networkRepository.uploadImage(name, bytes);
  }

  Future<void> deleteJob(String id) async {
    try {
      await networkRepository.deleteJob(id);
      notifyListeners();
    } on RepositoryException catch (_) {
      notifyListeners();
    }
  }
}

extension PopMap<K, V> on Map<K, V> {
  V? pop() {
    if (isNotEmpty) {
      final key = keys.elementAt(0);
      final job = remove(key);
      return job;
    }
    return null;
  }

  V? get() {
    if (isNotEmpty) {
      final key = keys.elementAt(0);
      return this[key];
    }
    return null;
  }
}
