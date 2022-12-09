import 'dart:async';
import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:banananator/src/annotation/models/annotation.dart';
import 'package:banananator/src/annotation/annotation_network_repository.dart';
import 'package:banananator/src/annotation/annotation_service.dart';
import 'package:banananator/src/annotation/bounding_box_widget.dart';
import 'package:banananator/src/annotation/pages/missing_data_page.dart';
import 'package:banananator/src/routes.dart';
import 'package:banananator/src/utilities/error_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

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

  Map<DateTime, FinishedBoundingBox> finishedBoundingBoxes = {};

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

  onSkip() async {
    final jobId = (await widget.job).id;
    widget.service.skipAnnotationJob(jobId);
    navigateToNextJob();
  }

  bool errorShown = false;

  FutureOr<T> showError<T>(Object anyError, T result) async {
    // Expecting only RepositoryException
    if (anyError.runtimeType != RepositoryException) return result;
    final error = anyError as RepositoryException;
    if (!mounted) return result;
    if (errorShown) return result;
    errorShown = true;
    showDialog(
            context: context,
            builder: (BuildContext context) =>
                ErrorAlertDialog(errors: {error.message}))
        .then((_) => errorShown = false);
    return result;
  }

  Future<void> onSubmitAnnotation() async {
    final job = await widget.job;
    imageSizeWhenDrawn = Size.zero;
    imageSize = Size.zero;
    final boxes = finishedBoundingBoxes.values.map((e) => e.box).toList();
    final annotation = Annotation(
        annotationJobID: job.id,
        boundingBoxes: boxes,
        annotatedOn: DateTime.now(),
        localId: const Uuid().toString());
    final submitted = await widget.service
        .submitAnnotation(annotation)
        .catchError((e) => showError(e, false));
    if (!submitted) {
      showNotSubmittedWarning();
    }
    await navigateToNextJob();
  }

  void showNotSubmittedWarning() {
    if (!mounted) return;
    Flushbar(
      message:
          "Your last annotation was only saved locally because of a network issue.",
      duration: const Duration(seconds: 8),
      backgroundColor: Colors.red[900]!,
    ).show(context);
  }

  navigateToNextJob() async {
    finishedBoundingBoxes = {};
    final nextJob = await widget.service.getNextJob();
    if (!mounted) return;
    if (nextJob == null) {
      context.go(Routes.root); // TODO navigate to a "complete page"
    } else {
      context.go("${Routes.root}${Routes.annotate}/${nextJob.id}");
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
    finishedBoundingBoxes[currentTime] = FinishedBoundingBox(
        color: currentColor, box: box, createdAt: currentTime);
    first = Offset.zero;
    last = Offset.zero;
    colorIndex = ((colorIndex + 1) % colors.length);
    currentColor = colors.elementAt(colorIndex);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Disable swiping back to previous page, as per https://stackoverflow.com/a/49162131/7365866
    return WillPopScope(
      onWillPop: () async => false,
      child: FutureBuilder(
          future: widget.job,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                  body: Align(child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              if (snapshot.error.runtimeType == RepositoryException) {
                final e = snapshot.error as RepositoryException;
                return ErrorPage(
                  errorMessage: e.message,
                );
              } else {
                return const ErrorPage(
                  errorMessage: "Unexpected error: $e",
                );
              }
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
                title: const Text("Banananator 🍌📸"),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_circle_left_outlined),
                  onPressed: () => context.go(Routes.root),
                ),
              ),
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildTaskWidget(context),
                    Flexible(
                      child: Listener(
                        onPointerDown: onPointerDown,
                        onPointerUp: onPointerUp,
                        onPointerMove: onPointerMove,
                        child: Stack(
                          alignment: Alignment.center,
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
                                : BoundingBoxWidget(
                                    box: boundingBox,
                                    color: currentColor,
                                    scaleTo: imageSize,
                                  ),
                            ...finishedBoundingBoxes.values
                                .map((e) => BoundingBoxWidget(
                                      box: e.box,
                                      color: e.color,
                                      scaleTo: imageSize,
                                    ))
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
          }),
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
                SelectableText("Your task",
                    style: Theme.of(context).textTheme.headline5),
                const SelectableText(
                    "Draw a box around all groups of bananas."),
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
                    onPressed: onSkip,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("Skip"),
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
    return Container(
      constraints:
          BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.16),
      child: Padding(
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
}
