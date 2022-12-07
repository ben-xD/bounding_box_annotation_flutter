import 'dart:async';
import 'package:banananator/src/annotation/annotation_network_repository.dart';

import 'annotation.dart';

class AnnotationService {
  final AnnotationNetworkRepository networkRepository;

  final Map<String, AnnotationJob> _jobByJobId = {};

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

  Future<List<AnnotationJob>> fetchAnnotationJobs() async {
    final jobs = await networkRepository.fetchAnnotationJobs();
    for (final job in jobs) {
      _jobByJobId[job.id] = job;
    }
    return jobs;
  }

  AnnotationJob? getJob(String? jobId) => _jobByJobId[jobId];
}