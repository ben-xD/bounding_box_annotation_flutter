import 'package:banananator/src/persistence.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SizeAdapter extends TypeAdapter<Size> {
  @override
  final typeId = HiveTypeIds.size;

  @override
  Size read(BinaryReader reader) {
    final elements = reader.read();
    return Size(elements[0], elements[1]);
  }

  @override
  void write(BinaryWriter writer, Size obj) {
    writer.write([obj.width, obj.height]);
  }
}
class OffsetAdapter extends TypeAdapter<Offset> {
  @override
  final typeId = HiveTypeIds.offset;

  @override
  Offset read(BinaryReader reader) {
    final elements = reader.read();
    return Offset(elements[0], elements[1]);
  }

  @override
  void write(BinaryWriter writer, Offset obj) {
    writer.write([obj.dx, obj.dy]);
  }
}