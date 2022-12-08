// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'annotation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

BoundingBox _$BoundingBoxFromJson(Map<String, dynamic> json) {
  return _BoundingBox.fromJson(json);
}

/// @nodoc
mixin _$BoundingBox {
  @OffsetToJson()
  Offset get topLeft => throw _privateConstructorUsedError;
  @SizeToJson()
  Size get size => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BoundingBoxCopyWith<BoundingBox> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BoundingBoxCopyWith<$Res> {
  factory $BoundingBoxCopyWith(
          BoundingBox value, $Res Function(BoundingBox) then) =
      _$BoundingBoxCopyWithImpl<$Res, BoundingBox>;
  @useResult
  $Res call({@OffsetToJson() Offset topLeft, @SizeToJson() Size size});
}

/// @nodoc
class _$BoundingBoxCopyWithImpl<$Res, $Val extends BoundingBox>
    implements $BoundingBoxCopyWith<$Res> {
  _$BoundingBoxCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topLeft = null,
    Object? size = null,
  }) {
    return _then(_value.copyWith(
      topLeft: null == topLeft
          ? _value.topLeft
          : topLeft // ignore: cast_nullable_to_non_nullable
              as Offset,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as Size,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_BoundingBoxCopyWith<$Res>
    implements $BoundingBoxCopyWith<$Res> {
  factory _$$_BoundingBoxCopyWith(
          _$_BoundingBox value, $Res Function(_$_BoundingBox) then) =
      __$$_BoundingBoxCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@OffsetToJson() Offset topLeft, @SizeToJson() Size size});
}

/// @nodoc
class __$$_BoundingBoxCopyWithImpl<$Res>
    extends _$BoundingBoxCopyWithImpl<$Res, _$_BoundingBox>
    implements _$$_BoundingBoxCopyWith<$Res> {
  __$$_BoundingBoxCopyWithImpl(
      _$_BoundingBox _value, $Res Function(_$_BoundingBox) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? topLeft = null,
    Object? size = null,
  }) {
    return _then(_$_BoundingBox(
      topLeft: null == topLeft
          ? _value.topLeft
          : topLeft // ignore: cast_nullable_to_non_nullable
              as Offset,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as Size,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_BoundingBox implements _BoundingBox {
  const _$_BoundingBox(
      {@OffsetToJson() required this.topLeft,
      @SizeToJson() required this.size});

  factory _$_BoundingBox.fromJson(Map<String, dynamic> json) =>
      _$$_BoundingBoxFromJson(json);

  @override
  @OffsetToJson()
  final Offset topLeft;
  @override
  @SizeToJson()
  final Size size;

  @override
  String toString() {
    return 'BoundingBox(topLeft: $topLeft, size: $size)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BoundingBox &&
            (identical(other.topLeft, topLeft) || other.topLeft == topLeft) &&
            (identical(other.size, size) || other.size == size));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, topLeft, size);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BoundingBoxCopyWith<_$_BoundingBox> get copyWith =>
      __$$_BoundingBoxCopyWithImpl<_$_BoundingBox>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_BoundingBoxToJson(
      this,
    );
  }
}

abstract class _BoundingBox implements BoundingBox {
  const factory _BoundingBox(
      {@OffsetToJson() required final Offset topLeft,
      @SizeToJson() required final Size size}) = _$_BoundingBox;

  factory _BoundingBox.fromJson(Map<String, dynamic> json) =
      _$_BoundingBox.fromJson;

  @override
  @OffsetToJson()
  Offset get topLeft;
  @override
  @SizeToJson()
  Size get size;
  @override
  @JsonKey(ignore: true)
  _$$_BoundingBoxCopyWith<_$_BoundingBox> get copyWith =>
      throw _privateConstructorUsedError;
}

Annotation _$AnnotationFromJson(Map<String, dynamic> json) {
  return _Annotation.fromJson(json);
}

/// @nodoc
mixin _$Annotation {
  @JsonKey(name: 'AnnotationJobID')
  String get annotationJobID => throw _privateConstructorUsedError;
  @BoundingBoxesConverter()
  @JsonKey(name: 'BoundingBoxes')
  List<BoundingBox> get boundingBoxes => throw _privateConstructorUsedError;
  @JsonKey(name: 'AnnotatedOn')
  DateTime get annotatedOn => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AnnotationCopyWith<Annotation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnnotationCopyWith<$Res> {
  factory $AnnotationCopyWith(
          Annotation value, $Res Function(Annotation) then) =
      _$AnnotationCopyWithImpl<$Res, Annotation>;
  @useResult
  $Res call(
      {@JsonKey(name: 'AnnotationJobID')
          String annotationJobID,
      @BoundingBoxesConverter()
      @JsonKey(name: 'BoundingBoxes')
          List<BoundingBox> boundingBoxes,
      @JsonKey(name: 'AnnotatedOn')
          DateTime annotatedOn});
}

/// @nodoc
class _$AnnotationCopyWithImpl<$Res, $Val extends Annotation>
    implements $AnnotationCopyWith<$Res> {
  _$AnnotationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? annotationJobID = null,
    Object? boundingBoxes = null,
    Object? annotatedOn = null,
  }) {
    return _then(_value.copyWith(
      annotationJobID: null == annotationJobID
          ? _value.annotationJobID
          : annotationJobID // ignore: cast_nullable_to_non_nullable
              as String,
      boundingBoxes: null == boundingBoxes
          ? _value.boundingBoxes
          : boundingBoxes // ignore: cast_nullable_to_non_nullable
              as List<BoundingBox>,
      annotatedOn: null == annotatedOn
          ? _value.annotatedOn
          : annotatedOn // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_AnnotationCopyWith<$Res>
    implements $AnnotationCopyWith<$Res> {
  factory _$$_AnnotationCopyWith(
          _$_Annotation value, $Res Function(_$_Annotation) then) =
      __$$_AnnotationCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'AnnotationJobID')
          String annotationJobID,
      @BoundingBoxesConverter()
      @JsonKey(name: 'BoundingBoxes')
          List<BoundingBox> boundingBoxes,
      @JsonKey(name: 'AnnotatedOn')
          DateTime annotatedOn});
}

/// @nodoc
class __$$_AnnotationCopyWithImpl<$Res>
    extends _$AnnotationCopyWithImpl<$Res, _$_Annotation>
    implements _$$_AnnotationCopyWith<$Res> {
  __$$_AnnotationCopyWithImpl(
      _$_Annotation _value, $Res Function(_$_Annotation) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? annotationJobID = null,
    Object? boundingBoxes = null,
    Object? annotatedOn = null,
  }) {
    return _then(_$_Annotation(
      annotationJobID: null == annotationJobID
          ? _value.annotationJobID
          : annotationJobID // ignore: cast_nullable_to_non_nullable
              as String,
      boundingBoxes: null == boundingBoxes
          ? _value._boundingBoxes
          : boundingBoxes // ignore: cast_nullable_to_non_nullable
              as List<BoundingBox>,
      annotatedOn: null == annotatedOn
          ? _value.annotatedOn
          : annotatedOn // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Annotation implements _Annotation {
  const _$_Annotation(
      {@JsonKey(name: 'AnnotationJobID')
          required this.annotationJobID,
      @BoundingBoxesConverter()
      @JsonKey(name: 'BoundingBoxes')
          required final List<BoundingBox> boundingBoxes,
      @JsonKey(name: 'AnnotatedOn')
          required this.annotatedOn})
      : _boundingBoxes = boundingBoxes;

  factory _$_Annotation.fromJson(Map<String, dynamic> json) =>
      _$$_AnnotationFromJson(json);

  @override
  @JsonKey(name: 'AnnotationJobID')
  final String annotationJobID;
  final List<BoundingBox> _boundingBoxes;
  @override
  @BoundingBoxesConverter()
  @JsonKey(name: 'BoundingBoxes')
  List<BoundingBox> get boundingBoxes {
    if (_boundingBoxes is EqualUnmodifiableListView) return _boundingBoxes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_boundingBoxes);
  }

  @override
  @JsonKey(name: 'AnnotatedOn')
  final DateTime annotatedOn;

  @override
  String toString() {
    return 'Annotation(annotationJobID: $annotationJobID, boundingBoxes: $boundingBoxes, annotatedOn: $annotatedOn)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Annotation &&
            (identical(other.annotationJobID, annotationJobID) ||
                other.annotationJobID == annotationJobID) &&
            const DeepCollectionEquality()
                .equals(other._boundingBoxes, _boundingBoxes) &&
            (identical(other.annotatedOn, annotatedOn) ||
                other.annotatedOn == annotatedOn));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, annotationJobID,
      const DeepCollectionEquality().hash(_boundingBoxes), annotatedOn);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_AnnotationCopyWith<_$_Annotation> get copyWith =>
      __$$_AnnotationCopyWithImpl<_$_Annotation>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_AnnotationToJson(
      this,
    );
  }
}

abstract class _Annotation implements Annotation {
  const factory _Annotation(
      {@JsonKey(name: 'AnnotationJobID')
          required final String annotationJobID,
      @BoundingBoxesConverter()
      @JsonKey(name: 'BoundingBoxes')
          required final List<BoundingBox> boundingBoxes,
      @JsonKey(name: 'AnnotatedOn')
          required final DateTime annotatedOn}) = _$_Annotation;

  factory _Annotation.fromJson(Map<String, dynamic> json) =
      _$_Annotation.fromJson;

  @override
  @JsonKey(name: 'AnnotationJobID')
  String get annotationJobID;
  @override
  @BoundingBoxesConverter()
  @JsonKey(name: 'BoundingBoxes')
  List<BoundingBox> get boundingBoxes;
  @override
  @JsonKey(name: 'AnnotatedOn')
  DateTime get annotatedOn;
  @override
  @JsonKey(ignore: true)
  _$$_AnnotationCopyWith<_$_Annotation> get copyWith =>
      throw _privateConstructorUsedError;
}

AnnotationJob _$AnnotationJobFromJson(Map<String, dynamic> json) {
  return _AnnotationJob.fromJson(json);
}

/// @nodoc
mixin _$AnnotationJob {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'ImageURL')
  String get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'CreatedOn')
  DateTime get createdOn => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AnnotationJobCopyWith<AnnotationJob> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnnotationJobCopyWith<$Res> {
  factory $AnnotationJobCopyWith(
          AnnotationJob value, $Res Function(AnnotationJob) then) =
      _$AnnotationJobCopyWithImpl<$Res, AnnotationJob>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'ImageURL') String imageUrl,
      @JsonKey(name: 'CreatedOn') DateTime createdOn});
}

/// @nodoc
class _$AnnotationJobCopyWithImpl<$Res, $Val extends AnnotationJob>
    implements $AnnotationJobCopyWith<$Res> {
  _$AnnotationJobCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imageUrl = null,
    Object? createdOn = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      createdOn: null == createdOn
          ? _value.createdOn
          : createdOn // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_AnnotationJobCopyWith<$Res>
    implements $AnnotationJobCopyWith<$Res> {
  factory _$$_AnnotationJobCopyWith(
          _$_AnnotationJob value, $Res Function(_$_AnnotationJob) then) =
      __$$_AnnotationJobCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'ImageURL') String imageUrl,
      @JsonKey(name: 'CreatedOn') DateTime createdOn});
}

/// @nodoc
class __$$_AnnotationJobCopyWithImpl<$Res>
    extends _$AnnotationJobCopyWithImpl<$Res, _$_AnnotationJob>
    implements _$$_AnnotationJobCopyWith<$Res> {
  __$$_AnnotationJobCopyWithImpl(
      _$_AnnotationJob _value, $Res Function(_$_AnnotationJob) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imageUrl = null,
    Object? createdOn = null,
  }) {
    return _then(_$_AnnotationJob(
      null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      null == createdOn
          ? _value.createdOn
          : createdOn // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_AnnotationJob implements _AnnotationJob {
  const _$_AnnotationJob(this.id, @JsonKey(name: 'ImageURL') this.imageUrl,
      @JsonKey(name: 'CreatedOn') this.createdOn);

  factory _$_AnnotationJob.fromJson(Map<String, dynamic> json) =>
      _$$_AnnotationJobFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'ImageURL')
  final String imageUrl;
  @override
  @JsonKey(name: 'CreatedOn')
  final DateTime createdOn;

  @override
  String toString() {
    return 'AnnotationJob(id: $id, imageUrl: $imageUrl, createdOn: $createdOn)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_AnnotationJob &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.createdOn, createdOn) ||
                other.createdOn == createdOn));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, imageUrl, createdOn);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_AnnotationJobCopyWith<_$_AnnotationJob> get copyWith =>
      __$$_AnnotationJobCopyWithImpl<_$_AnnotationJob>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_AnnotationJobToJson(
      this,
    );
  }
}

abstract class _AnnotationJob implements AnnotationJob {
  const factory _AnnotationJob(
      final String id,
      @JsonKey(name: 'ImageURL') final String imageUrl,
      @JsonKey(name: 'CreatedOn') final DateTime createdOn) = _$_AnnotationJob;

  factory _AnnotationJob.fromJson(Map<String, dynamic> json) =
      _$_AnnotationJob.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'ImageURL')
  String get imageUrl;
  @override
  @JsonKey(name: 'CreatedOn')
  DateTime get createdOn;
  @override
  @JsonKey(ignore: true)
  _$$_AnnotationJobCopyWith<_$_AnnotationJob> get copyWith =>
      throw _privateConstructorUsedError;
}
