import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  MyApp({
    super.key,
  });

  final getIt = GetIt.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getIt.allReady(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                  body: Container(
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator())),
            );
          }

          final GoRouter router = getIt();
          return MaterialApp.router(
            routerConfig: router,
            restorationScopeId: 'app',
            theme: ThemeData(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.system,
          );
        });
  }
}
