import 'package:banananator/src/annotation/models/annotation.dart';
import 'package:banananator/src/annotation/models/hive_adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../persistence.dart';

class AnnotationLocalRepository {
  // Async constructor pattern, following https://stackoverflow.com/a/59304510/7365866
  AnnotationLocalRepository._init();

  late Box<Annotation> _annotationsBox;
  late Box<AnnotationJob> _jobBox;

  _asyncInit() async {
    _annotationsBox = await Hive.openBox(HiveBoxes.annotations.name);
    _jobBox = await Hive.openBox(HiveBoxes.annotationJobs.name);
  }

  static Future<AnnotationLocalRepository> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AnnotationAdapter());
    Hive.registerAdapter(AnnotationJobAdapter());
    Hive.registerAdapter(BoundingBoxAdapter());
    Hive.registerAdapter(SizeAdapter());
    Hive.registerAdapter(OffsetAdapter());
    final self = AnnotationLocalRepository._init();
    await self._asyncInit();
    return self;
  }

  Iterable<Annotation> getAnnotations() {
    return _annotationsBox.values;
  }

  void saveAnnotation(Annotation annotation) {
    _annotationsBox.put(annotation.localId, annotation);
  }

  void removeAnnotation(Annotation annotation) {
    _annotationsBox.delete(annotation.localId);
  }

  saveJob(AnnotationJob job) {
    _jobBox.add(job);
  }

  getJobs() {
    return _jobBox.values.toList();
  }

  deleteAnnotations() => _annotationsBox.clear();

  Future<void> deleteJobs() async {
    await _jobBox.clear();
  }
}
