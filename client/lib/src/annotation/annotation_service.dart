import 'dart:async';
import 'package:banananator/src/annotation/annotation_local_repository.dart';
import 'package:banananator/src/annotation/annotation_network_repository.dart';
import 'package:flutter/material.dart';

import 'models/annotation.dart';

class AnnotationService extends ChangeNotifier {
  final AnnotationNetworkRepository networkRepository;
  final AnnotationLocalRepository localRepository;

  final Map<String, AnnotationJob> _inCompleteJobByJobId = {};

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
    _inCompleteJobByJobId.remove(jobId);
  }

  Future<bool> submitAnnotation(Annotation annotation) async {
    _inCompleteJobByJobId.remove(annotation.annotationJobID);
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

  FutureOr<AnnotationJob?> getNextJob() async {
    return _inCompleteJobByJobId.get();
  }

  Future<List<AnnotationJob>> fetchJobs() async {
    final jobs = await networkRepository.fetchAnnotationJobs();
    _saveJobsLocally(jobs);
    return jobs;
  }

  _saveJobsLocally(List<AnnotationJob> jobs) {
    for (final job in jobs) {
      _inCompleteJobByJobId[job.id] = job;
    }
  }

  Future<AnnotationJob> getJob(String jobId) async {
    if (!_inCompleteJobByJobId.containsKey(jobId)) {
      await fetchJobs();
    }
    final job = _inCompleteJobByJobId[jobId];
    if (job != null) {
      return job;
    }
    throw RepositoryException("Job $jobId was not found");
  }

  Future<void> deleteAnnotations() async {
    await networkRepository.deleteAnnotations();
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
