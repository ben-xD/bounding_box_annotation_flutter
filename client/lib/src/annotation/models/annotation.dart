// ignore_for_file: invalid_annotation_target

import 'dart:convert';
import 'dart:ui';

import 'package:banananator/src/annotation/json/offset.dart';
import 'package:banananator/src/annotation/json/size.dart';
import 'package:banananator/src/persistence.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Unusual syntax in this file just follows https://pub.dev/packages/freezed#creating-a-model-using-freezed
// to help generate code like converting into JSON.

part 'annotation.freezed.dart';

part 'annotation.g.dart';

@freezed
@HiveType(typeId: HiveTypeIds.boundingBox)
class BoundingBox with _$BoundingBox {
  /// Normalised coordinates, from 0 to 1.

  const factory BoundingBox({
    @HiveField(0)
    @OffsetToJson() required Offset topLeft,
    @HiveField(1)
    @SizeToJson() required Size size,
  }) = _BoundingBox;

  factory BoundingBox.fromJson(Map<String, Object?> json) =>
      _$BoundingBoxFromJson(json);
}

@freezed
@HiveType(typeId: HiveTypeIds.annotation)
class Annotation with _$Annotation {
  const factory Annotation(
      {@JsonKey(name: 'AnnotationJobID')
      @HiveField(0)
          required String annotationJobID,
      @BoundingBoxesConverter()
      @JsonKey(name: 'BoundingBoxes')
      @HiveField(1)
          required List<BoundingBox> boundingBoxes,
      @JsonKey(name: 'AnnotatedOn')
      @HiveField(2)
          required DateTime annotatedOn,
        @JsonKey(ignore: true)
        @HiveField(3)
        String? localId}) = _Annotation;

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

class BoundingBoxesConverter extends JsonConverter<List<BoundingBox>, String> {
  const BoundingBoxesConverter();

  @override
  List<BoundingBox> fromJson(String json) {
    final elements = jsonDecode(json) as List<dynamic>;
    return elements.map((e) => BoundingBox.fromJson(e)).toList();
  }

  @override
  String toJson(List<BoundingBox> object) {
    return jsonEncode(object.map((e) => e.toJson()).toList());
  }
}
