import 'package:banananator/src/annotation/annotation_service.dart';
import 'package:banananator/src/annotation/models/annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:timeago/timeago.dart' as timeago;

class AnnotationJobsSliver extends HookWidget {
  late final ValueNotifier<List<AnnotationJob>> jobsValueNotifier;
  final Function() onStartAnnotating;

  final getIt = GetIt.instance;
  late final AnnotationService service = getIt();

  AnnotationJobsSliver({
    super.key,
    required ValueNotifier<List<AnnotationJob>> jobs,
    required this.onStartAnnotating,
  }) {
    jobsValueNotifier = jobs;
  }

  @override
  Widget build(BuildContext context) {
    useListenable(service);
    final jobs = useValueListenable(jobsValueNotifier);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SelectableText("Annotation jobs.",
              style: Theme.of(context).textTheme.headline5),
          SelectableText(
              "You have ${jobs.length} annotation ${(jobs.length == 1) ? "job" : "jobs"} to finish."),
          Text("Jobs downloaded: ${service.jobsDownloaded.length}"),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                    onPressed: service.downloadAllJobs,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("Download all jobs"),
                    )),
                ElevatedButton(
                    onPressed: service.deleteDownloadedJobs,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("Delete downloaded jobs"),
                    )),
              ],
            ),
          ),
          Wrap(
            children: jobs
                .map((job) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SelectableText(timeago.format(job.createdOn)),
                              IconButton(
                                  onPressed: () async {
                                    await service.deleteJob(job.id);
                                  },
                                  icon: const Icon(Icons.delete))
                            ],
                          ),
                          const SizedBox(height: 8),
                          Image.network(
                            job.imageUrl,
                            width: 160,
                          ),
                          // SelectableText("Job ID: ${job.id}"),
                        ],
                      ),
                    ))
                .toList(),
          ),
          (jobs.isEmpty)
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
