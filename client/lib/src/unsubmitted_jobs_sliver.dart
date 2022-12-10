import 'package:another_flushbar/flushbar.dart';
import 'package:banananator/src/annotation/annotation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';

class UnsubmittedJobsSliver extends HookWidget {
  UnsubmittedJobsSliver({super.key});

  final getIt = GetIt.instance;
  late final AnnotationService service = getIt();

  @override
  Widget build(BuildContext context) {
    final isMounted = useIsMounted();
    useListenable(service);
    final annotations = service.getNotSubmittedAnnotations();

    void showNotSubmittedWarning() {
      if (!isMounted()) return;
      Flushbar(
        message: "Not all annotations were published due to a network issue.",
        duration: const Duration(seconds: 8),
        backgroundColor: Colors.red[900]!,
      ).show(context);
    }

    onSubmit() async {
      final failedUploads = await service.submitNotSubmittedAnnotations();
      if (failedUploads != 0) showNotSubmittedWarning();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          onPressed: (annotations.isEmpty) ? null : onSubmit,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
                "Publish all ${annotations.length} locally stored annotations"),
          )),
    );
  }
}
