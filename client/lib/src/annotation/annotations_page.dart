import 'dart:async';

import 'package:banananator/src/annotation/annotation.dart';
import 'package:banananator/src/annotation/annotation_network_repository.dart';
import 'package:banananator/src/annotation/annotation_service.dart';
import 'package:banananator/src/connectivity/connectivity.dart';
import 'package:banananator/src/constants.dart';
import 'package:banananator/src/routes.dart';
import 'package:banananator/src/utilities/error_alert_dialog.dart';
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

    Set<String> errors = {};
    bool errorShown = false;
    FutureOr<T> showError<T>(Object anyError, T result) async {
      // Expecting only RepositoryException
      if (anyError.runtimeType != RepositoryException) return result;
      final error = anyError as RepositoryException;
      errors.add(error.message);
      if (!isMounted()) return result;
      if (errorShown) return result;
      errorShown = true;
      showDialog(
          context: context,
          builder: (BuildContext context) =>
              ErrorAlertDialog(errors: errors)).then((_) => errorShown = false);
      return result;
    }

    Future<void> updateState() async {
      // Try to get annotations to annotate.
      service
          .fetchJobs()
          .then((jobs) => annotationJobs.value = jobs)
          .catchError((e) => showError(e, <AnnotationJob>[]), test: (o) {
        return o.runtimeType == RepositoryException;
      });
      service
          .getAnnotations()
          .then((a) => annotations.value = a)
          .catchError((e) => showError(e, <Annotation>[]));
    }

    useEffect(() {
      updateState();
      // Update UI if connection changes
      connectionListener() => _onConnectedChange(context, connected);
      connected.addListener(connectionListener);
      return () {
        connected.removeListener(connectionListener);
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
            onPressed: updateState
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await service.deleteAnnotations().catchError((e) => showError(e, null));
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
      BuildContext context, ValueNotifier<List<Annotation>> annotations) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SelectableText("Annotations.",
              style: Theme.of(context).textTheme.headline5),
          const SelectableText("Most recent shown first."),
          SelectableText(
              "There are ${annotations.value.length} ${(annotations.value.length == 1) ? "annotation" : "annotations"} uploaded by all users."),
          const SelectableText(
              "The same image may appear more than once if annotated more than once."),
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
          Wrap(
            children: annotationJobs.value
                .map((e) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                              "Requested ${timeago.format(e.createdOn)}"),
                          const SizedBox(height: 8),
                          Image.network(
                            e.imageUrl,
                            width: 160,
                          ),
                          // SelectableText("Job ID: ${job.id}"),
                        ],
                      ),
                    ))
                .toList(),
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
