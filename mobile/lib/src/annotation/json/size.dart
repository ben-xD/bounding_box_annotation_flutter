import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';

class SizeToJson extends JsonConverter<Size, Map<String, dynamic>> {
  const SizeToJson();

  @override
  Size fromJson(Map<String, dynamic> json) {
    return Size(json["width"], json["height"]);
  }

  @override
  Map<String, dynamic> toJson(Size object) {
    return {"width": object.width, "height": object.height};
  }
}

/// You could also create your own class instead of implementing a JsonConverter
/// for external class, Size.
/// Coordinates2, because it is 2-dimensional.
// class Coordinates2 {}
