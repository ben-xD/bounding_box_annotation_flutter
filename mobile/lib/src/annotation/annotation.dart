import 'dart:ui';

import 'package:banananator/src/annotation/json/offset.dart';
import 'package:banananator/src/annotation/json/size.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Unusual syntax in this file just follows https://pub.dev/packages/freezed#creating-a-model-using-freezed
// to help generate code like converting into JSON.

part 'annotation.freezed.dart';

part 'annotation.g.dart';

@freezed
class BoundingBox with _$BoundingBox {
  /// Normalised coordinates, from 0 to 1.

  const factory BoundingBox({
    @OffsetToJson() required Offset topLeft,
    @SizeToJson() required Size size,
  }) = _BoundingBox;

  factory BoundingBox.fromJson(Map<String, Object?> json) =>
      _$BoundingBoxFromJson(json);
}

@freezed
class Annotation with _$Annotation {
  const factory Annotation(
      {required String annotationJobID,
      required List<BoundingBox> boundingBoxes,
      required DateTime annotatedOn}) = _Annotation;

  factory Annotation.fromJson(Map<String, Object?> json) =>
      _$AnnotationFromJson(json);
}

@freezed
class AnnotationJob with _$AnnotationJob {
  const factory AnnotationJob(
      String id,
      @JsonKey(name: 'ImageURL') String imageUrl,
      @JsonKey(name: 'CreatedOn') DateTime createdOn) = _AnnotationJob;

  factory AnnotationJob.fromJson(Map<String, Object?> json) =>
      _$AnnotationJobFromJson(json);
}
