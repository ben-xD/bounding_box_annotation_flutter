import 'package:banananator/src/annotation/annotation_local_repository.dart';
import 'package:banananator/src/annotation/annotation_network_repository.dart';
import 'package:banananator/src/annotation/annotation_service.dart';
import 'package:banananator/src/routes.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  setPathUrlStrategy();
  await registerServices();

  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowManager.instance.setMinimumSize(const Size(400, 400));

  runApp(const App());
}

Future<void> registerServices() async {
  final getIt = GetIt.instance;
  getIt.registerSingleton<GoRouter>(createRouterConfig());
  getIt.registerSingleton(AnnotationService(
      networkRepository: AnnotationNetworkRepository(),
      localRepository: await AnnotationLocalRepository.init()));
}

class App extends StatelessWidget {
  const App({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: GetIt.instance<GoRouter>(),
      restorationScopeId: 'app',
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
    );
  }
}
