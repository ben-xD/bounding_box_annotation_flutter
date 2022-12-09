// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'annotation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BoundingBoxAdapter extends TypeAdapter<BoundingBox> {
  @override
  final int typeId = 2;

  @override
  BoundingBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BoundingBox(
      topLeft: fields[0] as Offset,
      size: fields[1] as Size,
    );
  }

  @override
  void write(BinaryWriter writer, BoundingBox obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.topLeft)
      ..writeByte(1)
      ..write(obj.size);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoundingBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AnnotationAdapter extends TypeAdapter<Annotation> {
  @override
  final int typeId = 1;

  @override
  Annotation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Annotation(
      annotationJobID: fields[0] as String,
      boundingBoxes: (fields[1] as List).cast<BoundingBox>(),
      annotatedOn: fields[2] as DateTime,
      localId: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Annotation obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.annotationJobID)
      ..writeByte(1)
      ..write(obj.boundingBoxes)
      ..writeByte(2)
      ..write(obj.annotatedOn)
      ..writeByte(3)
      ..write(obj.localId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnnotationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
