import 'dart:async';
import 'package:banananator/src/annotation/annotation_local_repository.dart';
import 'package:banananator/src/annotation/annotation_network_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'models/annotation.dart';

class AnnotationService extends ChangeNotifier {
  final AnnotationNetworkRepository networkRepository;
  final AnnotationLocalRepository localRepository;

  final Map<String, AnnotationJob> _jobByJobId = {};
  final _completedJobIds = <String>{};

  List<AnnotationJob> get jobsDownloaded => localRepository.getJobs();

  AnnotationService(
      {required this.networkRepository, required this.localRepository});

  Iterable<Annotation> getNotSubmittedAnnotations() {
    return localRepository.getAnnotations();
  }

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
    final jobDownloadFutures = <Future<void>>[];
    for (final job in jobs) {
      jobDownloadFutures.add(localRepository.saveJob(job));
    }
    final imageDownloadFutures =
        jobs.map((j) => networkRepository.downloadImage(j.imageUrl));
    // Download jobs and images in parallel
    await Future.wait([...jobDownloadFutures, ...imageDownloadFutures]);
    notifyListeners();
  }

  FutureOr<AnnotationJob?> getNextJob() async {
    // Take one that hasn't been completed:
    final unfinishedJobs =
        _jobByJobId.keys.toSet().difference(_completedJobIds);
    if (unfinishedJobs.isEmpty) {
      // Fall back to downloaded jobs:
      final unfinishedDownloadedJobs =
          jobsDownloaded.map((e) => e.id).toSet().difference(_completedJobIds);
      if (unfinishedDownloadedJobs.isEmpty) return null;
      return localRepository.getJob(unfinishedDownloadedJobs.first);
    }
    return _jobByJobId[unfinishedJobs.first];
  }

  Future<List<AnnotationJob>> fetchJobs() async {
    final jobs = await networkRepository.fetchAnnotationJobs();
    for (final job in jobs) {
      _jobByJobId[job.id] = job;
    }
    return jobs;
  }

  Future<AnnotationJob> getJob(String jobId) async {
    AnnotationJob? job;
    try {
      await fetchJobs(); // Doesn't exist locally, so fetch it.
      if (_jobByJobId.containsKey(jobId)) {
        job = _jobByJobId[jobId];
      }
    } on RepositoryException catch (_) {
      // Fall back to locally stored ones
      job = localRepository.getJob(jobId);
    }
    if (job != null) {
      return job;
    }
    throw RepositoryException("Job $jobId was not found");
  }

  Future<void> deleteAnnotations() async {
    await localRepository.deleteAnnotations();
    notifyListeners();
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

  Future<void> createJobWithImage(PlatformFile file) async {
    await networkRepository.createJobWithImage(file);
  }

  Future<void> deleteJob(String id) async {
    try {
      await networkRepository.deleteJob(id);
      notifyListeners();
    } on RepositoryException catch (_) {
      notifyListeners();
    }
  }

  Future<void> deleteDownloadedJobs() async {
    await localRepository.deleteJobs();
    notifyListeners();
  }

  Future<String?> getSavedJobImage(AnnotationJob job) {
    return networkRepository.getImagePathFor(job);
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
