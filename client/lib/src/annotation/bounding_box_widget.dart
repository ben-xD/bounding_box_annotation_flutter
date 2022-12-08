import 'package:banananator/src/annotation/annotation.dart';
import 'package:flutter/material.dart';

class FinishedBoundingBox {
  final Color color;
  final BoundingBox box;
  final DateTime createdAt;

  const FinishedBoundingBox(
      {required this.color, required this.box, required this.createdAt});
}

class BoundingBoxWidget extends StatelessWidget {
  final BoundingBox box;
  final Color color;
  final Size scaleTo;
  const BoundingBoxWidget({required this.box, required this.color, required this.scaleTo, super.key});

  @override
  Widget build(BuildContext context) {
    final scaledBox = scaleBoundingBox(box, scaleTo.width, scaleTo.height);
    return Positioned(
      left: scaledBox.topLeft.dx,
      top: scaledBox.topLeft.dy,
      child: Container(
        color: color.withOpacity(0.5),
        width: scaledBox.size.width,
        height: scaledBox.size.height,
      ),
    );
  }


  BoundingBox scaleBoundingBox(
      BoundingBox box, double widthScale, double heightScale) =>
      BoundingBox(
        topLeft:
        Offset(box.topLeft.dx * widthScale, box.topLeft.dy * heightScale),
        size: Size(box.size.width * widthScale, box.size.height * heightScale),
      );
}