import 'package:banananator/src/annotation/annotate_page.dart';
import 'package:banananator/src/annotation/annotations_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'settings_page.dart';

class Routes {
  static const root = "/";
  static const annotate = "annotate";
  static const settings = "settings";
}

GoRouter createRouterConfig() {
  return GoRouter(
    debugLogDiagnostics: kDebugMode,
    // For easier debugging, change the initial location
    // to the page you are working on.
    // initialLocation: "/${Routes.annotate}",
    initialLocation: Routes.root,
    restorationScopeId: "app",
    routes: [
      GoRoute(
          path: Routes.root,
          builder: (context, state) => AnnotationsPage(),
          routes: [
            GoRoute(
              path: "${Routes.annotate}/:jobId",
              builder: (context, state) {
                final jobId = state.params["jobId"];
                if (jobId != null) {
                  return AnnotatePage(
                    jobId: jobId,
                  );
                }
                return const Scaffold(body: Text("Couldn't find that job."));
              },
            ),
          ]),
      GoRoute(
        path: "/${Routes.settings}",
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}
