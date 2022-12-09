import 'dart:async';
import 'package:banananator/src/annotation/annotation_network_repository.dart';

import 'annotation.dart';

class AnnotationService {
  final AnnotationNetworkRepository networkRepository;

  final Map<String, AnnotationJob> _inCompleteJobByJobId = {};

  AnnotationService({required this.networkRepository});

  // Future<List<Image>> downloadImages(int maxQuantity) {
  //
  // }
  // Challenge: persist images for later use.
  // Future<List<Path>> downloadImages(int maxQuantity) {
  //
  // }

  // final StreamController<AnnotationJob> _jobsStreamController = StreamController();
  // Stream<AnnotationJob> get jobs => _jobsStreamController.stream;

  Future<void> skipAnnotationJob(jobId) async {
    _inCompleteJobByJobId.remove(jobId);
  }

  Future<bool> submitAnnotation(Annotation annotation) async {
    _inCompleteJobByJobId.remove(annotation.annotationJobID);
    return networkRepository.submitAnnotation(annotation);
  }

  Future<List<Annotation>> getAnnotations() async {
    final annotations = await networkRepository.getAnnotations();
    annotations.sort((a, b) => a.annotatedOn.compareTo(b.annotatedOn));
    return annotations.reversed.toList();
  }

  FutureOr<AnnotationJob?> getNextJob() async {
    // if (_inCompleteJobByJobId.isNotEmpty) {
    //   await fetchJobs();
    // }
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
    throw Exception("Job $jobId was not found");
    // throw AnnotationRepositoryException
  }

  Future<void> deleteAnnotations() async {
    await networkRepository.deleteAnnotations();
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