import 'package:banananator/src/annotation/models/annotation.dart';
import 'package:banananator/src/annotation/annotation_service.dart';
import 'package:banananator/src/annotation/bounding_box_widget.dart';
import 'package:banananator/src/unsubmitted_jobs_sliver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:timeago/timeago.dart' as timeago;

class AnnotationsSliver extends HookWidget {
  late final ValueNotifier<List<Annotation>> annotationsValueNotifier;

  AnnotationsSliver(
      {required ValueNotifier<List<Annotation>> annotations, super.key}) {
    annotationsValueNotifier = annotations;
  }

  final getIt = GetIt.instance;
  late final AnnotationService service = getIt();

  @override
  Widget build(BuildContext context) {
    final annotations = useValueListenable(annotationsValueNotifier);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SelectableText("Annotations.",
                  style: Theme.of(context).textTheme.headline5),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await service.deleteAnnotations();
                },
              )
            ],
          ),
          UnsubmittedJobsSliver(),
          const SelectableText("Most recent shown first."),
          SelectableText(
              "There are ${annotations.length} ${(annotations.length == 1) ? "annotation" : "annotations"} uploaded by all users."),
          const SelectableText(
              "The same image may appear more than once if annotated more than once."),
          AnnotationsWidget(
            annotations: annotations,
          ),
        ],
      ),
    );
  }
}

class AnnotationsWidget extends HookWidget {
  final List<Annotation> annotations;

  const AnnotationsWidget({required this.annotations, super.key});

  @override
  Widget build(BuildContext context) {
    return
      Wrap(
      children: annotations
          .map((e) => AnnotationWidget(
                annotation: e,
                key: ValueKey(e.annotatedOn),
              ))
          .toList(),
    );
  }
}

class AnnotationWidget extends HookWidget {
  final Annotation annotation;

  AnnotationWidget({
    required this.annotation,
    Key? key,
  }) : super(key: key);

  final getIt = GetIt.instance;
  late final AnnotationService service = getIt();

  @override
  Widget build(BuildContext context) {
    final job = useState<AnnotationJob?>(null);
    useEffect(() {
      service
          .getJob(annotation.annotationJobId)
          .then((value) => job.value = value);
      return null;
    }, []);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Text(e.annotationJobID),
          Text(timeago.format(annotation.annotatedOn)),
          const SizedBox(height: 16),
          IntrinsicWidth(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              (job.value == null)
                  ? const SizedBox.shrink()
                  : ScaledBoundingBoxesWidget(
                      annotation: annotation,
                      imageUrl: job.value!.imageUriThumbnail,
                    ),
            ]),
          ),
        ],
      ),
    );
  }
}

class ScaledBoundingBoxesWidget extends StatefulWidget {
  final Annotation annotation;
  final String imageUrl;

  const ScaledBoundingBoxesWidget(
      {required this.annotation, required this.imageUrl, super.key});

  @override
  State<StatefulWidget> createState() => _ScaledBoundingBoxesWidgetState();
}

class _ScaledBoundingBoxesWidgetState extends State<ScaledBoundingBoxesWidget> {
  final _imageKey = GlobalKey();
  Size imageSize = Size.zero;

  void _updateImageSize(Duration _) {
    final size = _imageKey.currentContext?.size;
    if (size == null) return;
    if (imageSize != size) {
      imageSize = size;
      // When the window is resized using keyboard shortcuts (e.g. Rectangle.app),
      // The widget won't rebuild AFTER this callback. Therefore, the new
      // image size is not used to update the bounding box drawing.
      // So we call setState

      // Width is 0 here, so bounding boxes are not drawn.
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Trigger rebuild when window is resized. This updates the bounding box sizes.
    MediaQuery.of(context);
    final image = buildImage();
    WidgetsBinding.instance.addPostFrameCallback(_updateImageSize);

    return Stack(
      children: [
        image,
        ...widget.annotation.boundingBoxes
            .map((e) => BoundingBoxWidget(
                  box: e,
                  color: Colors.red,
                  scaleTo: imageSize,
                ))
            .toList(),
      ],
    );
  }

  bool loaded = false;

  Widget buildImage() {
    return Image.network(
      widget.imageUrl,
      key: _imageKey,
      width: 160,
      frameBuilder: (context, child, frame, _) {
        if (frame != null && !loaded) {
          Future.delayed(
              Duration.zero,
              () => setState(() {
                    loaded = true;
                  }));
        }
        return child;
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        // Taken from https://stackoverflow.com/a/58048926/7365866
        return SizedBox(
          height: 160,
          child: Align(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }
}
