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
      jobId: json['jobId'] as String,
      boundingBox: (json['boundingBox'] as List<dynamic>)
          .map((e) => BoundingBox.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_AnnotationToJson(_$_Annotation instance) =>
    <String, dynamic>{
      'jobId': instance.jobId,
      'boundingBox': instance.boundingBox,
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