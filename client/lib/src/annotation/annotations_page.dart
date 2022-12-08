import 'package:banananator/src/annotation/annotation.dart';
import 'package:banananator/src/annotation/annotation_service.dart';
import 'package:banananator/src/connectivity/connectivity.dart';
import 'package:banananator/src/constants.dart';
import 'package:banananator/src/routes.dart';
import 'package:banananator/src/widgets/annotation_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

class AnnotationsPage extends HookWidget {
  AnnotationsPage({super.key});

  final getIt = GetIt.instance;
  late final AnnotationService service = getIt();

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
      _persistentDisconnectedSnackBarController;

  _onConnectedChange(BuildContext context, ValueNotifier<bool?> connected) {
    if (connected.value == null) return () {};
    if (!connected.value!) {
      const snackBar = SnackBar(
        content: Text("You've lost your internet connection."),
        backgroundColor: Colors.red,
        duration: Duration(days: 365),
      );
      _persistentDisconnectedSnackBarController =
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      // If never got disconnected, don't bother showing reconnection.
      if (_persistentDisconnectedSnackBarController == null) return;
      _persistentDisconnectedSnackBarController!.close();
      const snackBar = SnackBar(
        content: Text("You got your internet connection back."),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 6),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMounted = useIsMounted();
    final annotationJobs = useState<List<AnnotationJob>>([]);
    final annotations = useState<List<Annotation>>([]);
    final connected = useIsNetworkConnected(uri: Constants.apiUrl);

    useEffect(() {
      // Try to get annotations to annotate.
      service.fetchJobs().then((jobs) => annotationJobs.value = jobs);
      service.getAnnotations().then((a) => annotations.value = a);
      handler() => _onConnectedChange(context, connected);
      connected.addListener(handler);
      return () {
        connected.removeListener(handler);
      };
    }, [isMounted]);

    useEffect(() {
      return null;
      // return () {
      //   snackBarController.close();
      // };
    }, []);

    void onStartAnnotating() {
      final jobs = annotationJobs.value;
      if (!isMounted()) return;
      final jobId = jobs[0].id;
      context.go("${Routes.root}${Routes.annotate}/$jobId");
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Banananator 🍌📸"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final newAnnotations = await service.getAnnotations();
              annotations.value = newAnnotations;
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await service.deleteAnnotations();
              annotations.value = [];
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go("/${Routes.settings}"),
          )
        ],
      ),
      body: ListView(
        children: [
          buildAnnotationJobsSliver(context, annotationJobs, onStartAnnotating),
          buildAnnotationsSliver(context, annotations),
        ],
      ),
    );
  }

  Padding buildAnnotationsSliver(
      BuildContext context,
      ValueNotifier<List<Annotation>> annotations) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SelectableText("Annotations.",
              style: Theme.of(context).textTheme.headline5),
        SelectableText(
            "There are ${annotations.value.length} ${(annotations.value.length == 1) ? "annotation" : "annotations"} uploaded by all users."),
          const SelectableText("The same image may appear more than once if annotated more than once."),
          AnnotationsWidget(
            annotations: annotations.value,
          ),
        ],
      ),
    );
  }

  Padding buildAnnotationJobsSliver(
      BuildContext context,
      ValueNotifier<List<AnnotationJob>> annotationJobs,
      void Function() onStartAnnotating) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SelectableText("Annotation jobs.",
              style: Theme.of(context).textTheme.headline5),
          SelectableText(
              "You have ${annotationJobs.value.length} annotation ${(annotationJobs.value.length == 1) ? "job" : "jobs"} to finish."),
          ListView.builder(
            shrinkWrap: true,
            itemCount: annotationJobs.value.length,
            itemBuilder: (BuildContext context, int index) {
              final job = annotationJobs.value[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 16.0,
                  children: [
                    SelectableText("Job ID: ${job.id}"),
                    SelectableText(
                        "Created on: ${timeago.format(job.createdOn)}")
                  ],
                ),
              );
            },
          ),
          (annotationJobs.value.isEmpty)
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                      onPressed: onStartAnnotating,
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("Start annotating"),
                      )),
                ),
        ],
      ),
    );
  }
}
