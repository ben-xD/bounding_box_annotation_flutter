import 'package:banananator/src/annotation/pages/annotate_page.dart';
import 'package:banananator/src/annotation/pages/missing_data_page.dart';
import 'package:banananator/src/home/home_page.dart';
import 'package:flutter/foundation.dart';
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
    errorBuilder: (context, state) => const ErrorPage(),
    routes: [
      GoRoute(
          path: Routes.root,
          builder: (context, state) => HomePage(),
          routes: [
            GoRoute(
              path: "${Routes.annotate}/:jobId",
              builder: (context, state) {
                return AnnotatePage(jobId: state.pathParameters["jobId"]!);
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
