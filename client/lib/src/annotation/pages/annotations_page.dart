import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:banananator/src/annotation/models/annotation.dart';
import 'package:banananator/src/annotation/annotation_network_repository.dart';
import 'package:banananator/src/annotation/annotation_service.dart';
import 'package:banananator/src/unsubmitted_jobs_sliver.dart';
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
  late final Future<AnnotationService> service = getIt.getAsync();

  _onConnectedChange(BuildContext context, ValueNotifier<bool?> connected,
      IsMounted isMounted, ValueNotifier<Flushbar?> networkWarningFlushbar) {
    if (connected.value == null) return () {};
    if (!connected.value!) {
      networkWarningFlushbar.value = Flushbar(
        title: "👀 Warning",
        message:
            "You've lost your internet connection. You can still use the app to annotate previously downloaded jobs.",
        duration: const Duration(days: 365),
        isDismissible: false,
        backgroundColor: Colors.yellow[900]!,
      );
      networkWarningFlushbar.value?.show(context);
    } else {
      // If never got disconnected, don't bother showing reconnection.
      final flushbarShowing = networkWarningFlushbar.value?.isShowing() ?? false;
      if (!flushbarShowing) return;
      networkWarningFlushbar.value?.dismiss();
      Flushbar(
        title: "🎂 Hooray!",
        message: "You got your internet connection back.",
        duration: const Duration(seconds: 8),
        backgroundColor: Colors.green,
      ).show(context);
    }
  }

  void showNotSubmittedWarning(BuildContext context, IsMounted isMounted) {
    if (!isMounted()) return;
    Flushbar(
      message:
          "Your last annotation was only saved locally because of a network issue.",
      duration: const Duration(seconds: 8),
      backgroundColor: Colors.red[900]!,
    ).show(context);
  }

  // TODO refactor into ViewModel
  Set<String> errors = {};
  bool errorShown = false;

  FutureOr<T> showError<T>(Object anyError, T result, BuildContext context,
      IsMounted isMounted) async {
    // Expecting only RepositoryException
    if (anyError.runtimeType != RepositoryException) return result;
    final error = anyError as RepositoryException;
    errors.add(error.message);
    if (!isMounted()) return result;
    if (errorShown) return result;
    errorShown = true;
    showDialog(
            context: context,
            builder: (BuildContext context) => ErrorAlertDialog(errors: errors))
        .then((_) => errorShown = false);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final isMounted = useIsMounted();
    final networkWarningFlushbar = useState<Flushbar?>(null);
    final annotationJobs = useState<List<AnnotationJob>>([]);
    final annotations = useState<List<Annotation>>([]);
    final connected = useIsNetworkConnected(uri: Constants.apiUrl);

    Future<void> updateState() async {
      // Try to get annotations to annotate.
      (await service)
          .fetchJobs()
          .then((jobs) => annotationJobs.value = jobs)
          .catchError(
              (e) => showError(e, <AnnotationJob>[], context, isMounted),
              test: (o) {
        return o.runtimeType == RepositoryException;
      });
      (await service)
          .getAnnotations()
          .then((a) => annotations.value = a)
          .catchError((e) => showError(e, <Annotation>[], context, isMounted));
    }

    useEffect(() {
      updateState();
      // Update UI if connection changes
      connectionListener() => _onConnectedChange(context, connected, isMounted, networkWarningFlushbar);
      connected.addListener(connectionListener);
      return () {
        connected.removeListener(connectionListener);
      };
    }, [isMounted]);

    useEffect(() {
      return null;
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: updateState),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              (await service)
                  .deleteAnnotations()
                  .catchError((e) => showError(e, null, context, isMounted));
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
          UnsubmittedJobsSliver(),
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
