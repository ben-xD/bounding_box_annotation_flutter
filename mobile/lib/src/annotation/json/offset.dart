import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

/// You could also create your own class instead of implementing a JsonConverter
/// for dart classes.
/// Coordinates2, because it is 2-dimensional.
// class Coordinates2 {}

class OffsetToJson extends JsonConverter<Offset, Map<String, dynamic>> {
  const OffsetToJson();

  @override
  Offset fromJson(Map<String, dynamic> json) {
    return Offset(json["dx"], json["dy"]);
  }

  @override
  Map<String, dynamic> toJson(Offset object) {
    return {"dx": object.dx, "dy": object.dy};
  }
}
