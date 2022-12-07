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

  Future<void> submitAnnotation(Annotation annotation) async {
    return networkRepository.submitAnnotation(annotation);
  }

  FutureOr<AnnotationJob?> popNextJob() async {
    AnnotationJob? job = _inCompleteJobByJobId.pop();
    // if (job == null) {
    //   await fetchJobs();
    //   job = _inCompleteJobByJobId.pop();
    // }
    return job;
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

  AnnotationJob? getJob(String? jobId) => _inCompleteJobByJobId[jobId];
}

extension PopMap<K, V> on Map<K, V> {
  V? pop() {
    if (isNotEmpty) {
      final key = keys.elementAt(0);
      final job = remove(key)!;
      return job;
    }
    return null;
  }
}