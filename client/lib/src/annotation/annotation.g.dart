// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'annotation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_BoundingBox _$$_BoundingBoxFromJson(Map<String, dynamic> json) =>
    _$_BoundingBox(
      topLeft: const OffsetToJson()
          .fromJson(json['topLeft'] as Map<String, dynamic>),
      size: const SizeToJson().fromJson(json['size'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_BoundingBoxToJson(_$_BoundingBox instance) =>
    <String, dynamic>{
      'topLeft': const OffsetToJson().toJson(instance.topLeft),
      'size': const SizeToJson().toJson(instance.size),
    };

_$_Annotation _$$_AnnotationFromJson(Map<String, dynamic> json) =>
    _$_Annotation(
      annotationJobID: json['AnnotationJobID'] as String,
      boundingBoxes: const BoundingBoxesConverter()
          .fromJson(json['BoundingBoxes'] as String),
      annotatedOn: DateTime.parse(json['AnnotatedOn'] as String),
    );

Map<String, dynamic> _$$_AnnotationToJson(_$_Annotation instance) =>
    <String, dynamic>{
      'AnnotationJobID': instance.annotationJobID,
      'BoundingBoxes':
          const BoundingBoxesConverter().toJson(instance.boundingBoxes),
      'AnnotatedOn': instance.annotatedOn.toIso8601String(),
    };

_$_AnnotationJob _$$_AnnotationJobFromJson(Map<String, dynamic> json) =>
    _$_AnnotationJob(
      json['id'] as String,
      json['ImageURL'] as String,
      DateTime.parse(json['CreatedOn'] as String),
    );

Map<String, dynamic> _$$_AnnotationJobToJson(_$_AnnotationJob instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ImageURL': instance.imageUrl,
      'CreatedOn': instance.createdOn.toIso8601String(),
    };
