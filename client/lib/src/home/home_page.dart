import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:banananator/src/annotation/annotation_network_repository.dart';
import 'package:banananator/src/annotation/annotation_service.dart';
import 'package:banananator/src/annotation/models/annotation.dart';
import 'package:banananator/src/connectivity/check_internet_hooks.dart';
import 'package:banananator/src/constants.dart';
import 'package:banananator/src/home/annotations_jobs_sliver.dart';
import 'package:banananator/src/routes.dart';
import 'package:banananator/src/utilities/error_alert_dialog.dart';
import 'package:banananator/src/home/annotations_sliver.dart';
import 'package:banananator/src/widgets/app_bar_title.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:twemoji/twemoji.dart';

class HomePage extends HookWidget {
  HomePage({super.key});

  final getIt = GetIt.instance;
  late final AnnotationService service = getIt();

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
      final flushbarShowing =
          networkWarningFlushbar.value?.isShowing() ?? false;
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

  @override
  Widget build(BuildContext context) {
    final isMounted = useIsMounted();
    final networkWarningFlushbar = useState<Flushbar?>(null);
    useListenable(service);
    final annotationJobs = useState<List<AnnotationJob>>([]);
    final annotations = useState<List<Annotation>>([]);
    final connected = useIsNetworkConnected(uri: Constants.apiUrl);

    final errors = useMemoized<Set<String>>(() => {});
    final errorShown = useRef(false);

    FutureOr<T> showError<T>(Object anyError, T result, BuildContext context,
        IsMounted isMounted) async {
      // Expecting only RepositoryException
      if (anyError.runtimeType != RepositoryException) return result;
      final error = anyError as RepositoryException;
      errors.add(error.message);
      if (!isMounted()) return result;
      if (errorShown.value) return result;
      errorShown.value = true;
      showDialog(
              context: context,
              builder: (BuildContext context) =>
                  ErrorAlertDialog(errors: errors))
          .then((_) => errorShown.value = false);
      return result;
    }

    Future<void> fetchData() async {
      service
          .fetchJobs()
          .then((jobs) => annotationJobs.value = jobs)
          .catchError(
              (e) {
                annotationJobs.value = service.jobsDownloaded;
                return showError(e, <AnnotationJob>[], context, isMounted);
              },
              test: (o) {
        return o.runtimeType == RepositoryException;
      });
      service
          .getAnnotations()
          .then((a) => annotations.value = a)
          .catchError((e) => showError(e, <Annotation>[], context, isMounted));
    }

    useEffect(() {
      // Update UI if connection changes
      connected.addListener(() => _onConnectedChange(
          context, connected, isMounted, networkWarningFlushbar));
      fetchData();
      return null;
    }, [isMounted]);

    void onStartAnnotating() {
      final jobs = annotationJobs.value;
      if (!isMounted()) return;
      final jobId = jobs[0].id;
      context.go("${Routes.root}${Routes.annotate}/$jobId");
    }

    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitle(),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchData),
          IconButton(
              icon: const Icon(Icons.add_a_photo),
              onPressed: () async {
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles(type: FileType.image);
                if (result != null) {
                  final files = result.files;
                  if (files.length != 1) {
                    print("Only 1 image can be uploaded at a time");
                    return;
                  }
                  final futures = files.map((f) => service.createJobWithImage(result.files[0]));
                  await Future.wait(futures).catchError(
                      (e) => showError(e, <void>[], context, isMounted));
                  // if (kIsWeb) {
                  // } else {
                  //   files.map((f) => service.uploadImage(f.name, File(f.path!)));
                  // }
                }
              }),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go("/${Routes.settings}"),
          )
        ],
      ),
      body: ListView(
        children: [
          AnnotationJobsSliver(
              jobs: annotationJobs, onStartAnnotating: onStartAnnotating),
          AnnotationsSliver(annotations: annotations),
        ],
      ),
    );
  }
}
