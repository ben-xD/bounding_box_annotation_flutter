import 'package:banananator/src/annotation/annotate_page.dart';
import 'package:banananator/src/annotation/annotations_page.dart';
import 'package:go_router/go_router.dart';

import 'settings_page.dart';

class Routes {
  static const root = "/";
  static const annotate = "annotate";
  static const settings = "settings";
}

GoRouter createRouterConfig() {
  return GoRouter(
    // debugLogDiagnostics: kDebugMode,
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
                return AnnotatePage(jobId: state.params['jobId'],);
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
