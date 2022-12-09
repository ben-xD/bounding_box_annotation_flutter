import 'package:banananator/src/annotation/models/annotation.dart';
import 'package:banananator/src/annotation/models/hive_adapters.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../persistence.dart';

class AnnotationLocalRepository {
  // Async constructor pattern, following https://stackoverflow.com/a/59304510/7365866
  AnnotationLocalRepository._init();

  late Box<Annotation> _hiveBox;

  _asyncInit() async {
    _hiveBox = await Hive.openBox<Annotation>(HiveBoxes.annotations.name);
  }

  static Future<AnnotationLocalRepository> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AnnotationAdapter());
    Hive.registerAdapter(BoundingBoxAdapter());
    Hive.registerAdapter(SizeAdapter());
    Hive.registerAdapter(OffsetAdapter());
    final self = AnnotationLocalRepository._init();
    await self._asyncInit();
    return self;
  }

  Iterable<Annotation> getAnnotations() {
    return _hiveBox.values;
  }

  void saveAnnotation(Annotation annotation) {
    _hiveBox.put(annotation.localId, annotation);
  }

  void removeAnnotation(Annotation annotation) {
    _hiveBox.delete(annotation.localId);
  }
}
