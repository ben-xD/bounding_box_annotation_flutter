import 'dart:async';
import 'package:banananator/src/annotation/annotation_network_repository.dart';

import 'annotation.dart';

class AnnotationService {
  final AnnotationNetworkRepository networkRepository;

  AnnotationService({required this.networkRepository});

  // Future<List<Image>> downloadImages(int maxQuantity) {
  //
  // }
  // Challenge: persist images for later use.
  // Future<List<Path>> downloadImages(int maxQuantity) {
  //
  // }

  final StreamController<AnnotationJob> _jobsStreamController = StreamController();
  Stream<AnnotationJob> get jobs => _jobsStreamController.stream;

  Future<void> submitAnnotation(Annotation annotation) async {
    networkRepository.submitAnnotation(annotation);
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<List<AnnotationJob>> fetchAnnotationJobs() async {
    return networkRepository.fetchAnnotationJobs();
  }
}