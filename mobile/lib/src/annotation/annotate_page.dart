import 'dart:math';

import 'package:banananator/src/annotation/annotation.dart';
import 'package:banananator/src/constants.dart';
import 'package:banananator/src/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnnotatePage extends StatefulWidget {
  static const routeName = '/annotation';

  // final String imageUrl;
  // TODO add image type
  const AnnotatePage({super.key});

  @override
  State<StatefulWidget> createState() => _AnnotatePageState();
}

class DrawableBoundingBox {
  final Color color;
  final BoundingBox box;
  final DateTime createdAt;

  const DrawableBoundingBox(
      {required this.color, required this.box, required this.createdAt});
}

class _AnnotatePageState extends State<AnnotatePage> {
  // static const imageUrl =
  //     "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%3Fid%3DOIP.nEZo2_0rlxKZe6on44xMPAHaGC%26pid%3DApi&f=1&ipt=e986e5da57a3cc674714c940c3ce01b95ce94aba485d5b0e5bab88a88813c794&ipo=images";

  final _imageKey = GlobalKey();

  Offset first = Offset.zero;
  Offset last = Offset.zero;
  Size imageSize = Size.zero;
  Size imageSizeWhenDrawn = Size.zero;
  Color currentColor = Colors.red;
  int colorIndex = 0;
  Set<Color> colors = {
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.pink
  };

  // List<BoundingBox> finishedBoundingBoxes = [];
  Map<DateTime, DrawableBoundingBox> finishedBoundingBoxes = {};

  void _updateImageSize(Duration _) {
    final size = _imageKey.currentContext?.size;
    if (size == null) return;
    if (imageSize != size) {
      imageSize = size;
      // When the window is resized using keyboard shortcuts (e.g. Rectangle.app),
      // The widget won't rebuild AFTER this callback. Therefore, the new
      // image size is not used to update the bounding box drawing.
      // So we call setState
      setState(() {});
    }
  }

  onPointerDown(PointerDownEvent event) {
    imageSizeWhenDrawn = imageSize;
    first = event.localPosition;
    last = event.localPosition; // Avoid glitches on future annotations)
    setState(() {});
  }

  onPointerMove(PointerMoveEvent event) {
    last = event.localPosition;
    setState(() {});
  }

  onPointerUp(PointerUpEvent event) {
    last = event.localPosition;
    final currentTime = DateTime.now();
    final box = getCurrentBoundingBox();
    if (box == null) {
      return;
    }
    const thresholdSize = 0.05;
    if (box.size.width < thresholdSize && box.size.height < thresholdSize) {
      return;
    }
    finishedBoundingBoxes[currentTime] = DrawableBoundingBox(
        color: currentColor, box: box, createdAt: currentTime);
    first = Offset.zero;
    last = Offset.zero;
    colorIndex = ((colorIndex + 1) % colors.length);
    currentColor = colors.elementAt(colorIndex);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    MediaQuery.of(
        context); // Trigger rebuild when window is resized. This updates the bounding box sizes.
    final image = Image.asset(Constants.imagePath1, key: _imageKey);
    // Yes, we call this every time the widget rebuilds, so we update our understanding of the image size.
    WidgetsBinding.instance.addPostFrameCallback(_updateImageSize);
    final boundingBox = getCurrentBoundingBox();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_circle_left_outlined),
          onPressed: () => context.go(Routes.root),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTaskWidget(context),
            Flexible(
              child: Listener(
                onPointerDown: onPointerDown,
                onPointerUp: onPointerUp,
                onPointerMove: onPointerMove,
                child: Stack(
                  children: [
                    // Can't use onTapDown because GestureTapDownCallback doesn't
                    // provide tracking the finger as it is tracked.
                    // We need to go lower level.
                    // GestureDetector(child: Image.asset(Constants.imagePath1), onTapDown: (gestureTapDown){
                    //   print("Local position: ${gestureTapDown.localPosition}");
                    // },),
                    image,
                    (boundingBox == null)
                        ? const SizedBox.shrink()
                        : buildBoundingBoxWidget(boundingBox, currentColor),
                    ...finishedBoundingBoxes.entries
                        .map((e) =>
                            buildBoundingBoxWidget(e.value.box, e.value.color))
                        .toList(),
                  ],
                ),
              ),
            ),
            buildBoundingBoxesList(),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView buildTaskWidget(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Your task", style: Theme.of(context).textTheme.headline5),
                const Text("Draw a box around all groups of bananas."),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              alignment: WrapAlignment.end,
              runAlignment: WrapAlignment.end,
              spacing: 16.0,
              runSpacing: 8.0,
              children: [
                OutlinedButton(
                    onPressed: () {},
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("No bananas"),
                    )),
                ElevatedButton(
                    onPressed: () {},
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("Continue (spacebar)"),
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildBoundingBoxesList() {
    final List<Widget> elements;
    if (finishedBoundingBoxes.isEmpty) {
      elements = const [Text("No bounding boxes drawn")];
    } else {
      elements = finishedBoundingBoxes.entries
          .map((e) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(
                    backgroundColor: e.value.color,
                    onDeleted: () {
                      finishedBoundingBoxes.remove(e.key);
                      setState(() {});
                    },
                    label: const Text("Bounding box"),
                  ),
                ],
              ))
          .toList();
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text("Drawn bounding boxes",
                    style: Theme.of(context).textTheme.headline5),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    finishedBoundingBoxes = {};
                  });
                },
              )
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: elements,
          ),
        ],
      ),
    );
  }

  Positioned buildBoundingBoxWidget(BoundingBox box, Color color) {
    final scaledBox = scaleBoundingBox(box, imageSize.width, imageSize.height);
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

  BoundingBox? getCurrentBoundingBox() {
    if (imageSizeWhenDrawn.height == 0 || imageSizeWhenDrawn.width == 0) {
      return null;
    }
    final widthScale = 1 / imageSizeWhenDrawn.width;
    final heightScale = 1 / imageSizeWhenDrawn.height;
    final top = min(first.dy, last.dy) * heightScale;
    final bottom = max(first.dy, last.dy) * heightScale;
    final left = min(first.dx, last.dx) * widthScale;
    final right = max(first.dx, last.dx) * widthScale;
    final width = right - left;
    final height = bottom - top;
    return BoundingBox(topLeft: Offset(left, top), size: Size(width, height));
  }

  BoundingBox scaleBoundingBox(
          BoundingBox box, double widthScale, double heightScale) =>
      BoundingBox(
        topLeft:
            Offset(box.topLeft.dx * widthScale, box.topLeft.dy * heightScale),
        size: Size(box.size.width * widthScale, box.size.height * heightScale),
      );
}
