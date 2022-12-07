import 'dart:async';
import 'dart:math';

import 'package:banananator/src/annotation/annotation.dart';
import 'package:banananator/src/annotation/annotation_service.dart';
import 'package:banananator/src/routes.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class AnnotatePage extends StatefulWidget {
  static const routeName = '/annotation';
  final getIt = GetIt.instance;
  late final AnnotationService service = getIt();

  late final String jobId;
  late final Future<AnnotationJob> job;

  AnnotatePage({required this.jobId, super.key}) {
    job = service.getJob(jobId);
  }

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

  Future<void> onSubmitAnnotation() async {
    final job = await widget.job;
    finishedBoundingBoxes = {};
    imageSizeWhenDrawn = Size.zero;
    imageSize = Size.zero;
    final boxes = finishedBoundingBoxes.values.map((e) => e.box).toList();
    final annotation = Annotation(
        annotationJobID: job.id,
        boundingBoxes: boxes,
        annotatedOn: DateTime.now());
    widget.service.submitAnnotation(annotation);
    final nextJob = await widget.service.getNextJob();
    if (nextJob == null && mounted) {
      // Could navigate to a "complete page"
      context.go(Routes.root);
    } else {
      final nextJob = await widget.service.getNextJob();
      if (!mounted) return;
      if (nextJob == null) {
        // TODO show error to user
      } else {
        context.go("${Routes.root}${Routes.annotate}/${nextJob.id}");
      }
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
    return FutureBuilder(
        future: widget.job,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(body: Align(child: CircularProgressIndicator()));
          }
          if (snapshot.hasError) {
            return Scaffold(body: SelectableText("Error. ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const SelectableText("No job found");
          }
          final AnnotationJob job = snapshot.data!;
          MediaQuery.of(
              context); // Trigger rebuild when window is resized. This updates the bounding box sizes.
          final image = Image.network(job.imageUrl, key: _imageKey);
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
                              : buildBoundingBoxWidget(
                                  boundingBox, currentColor),
                          ...finishedBoundingBoxes.entries
                              .map((e) => buildBoundingBoxWidget(
                                  e.value.box, e.value.color))
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
        });
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
                SelectableText("Your task", style: Theme.of(context).textTheme.headline5),
                const SelectableText("Draw a box around all groups of bananas."),
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
                    onPressed: onSubmitAnnotation,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("Continue"),
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
      elements = const [SelectableText("No bounding boxes drawn")];
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
                    label: const SelectableText("Bounding box"),
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
                child: SelectableText("Drawn bounding boxes",
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
