import 'package:banananator/src/annotation/annotation_local_repository.dart';
import 'package:banananator/src/annotation/annotation_network_repository.dart';
import 'package:banananator/src/annotation/annotation_service.dart';
import 'package:banananator/src/routes.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:url_strategy/url_strategy.dart';

import 'src/app.dart';

void main() async {
  setPathUrlStrategy();
  registerServices();
  runApp(const MyApp());
}

void registerServices() {
  final getIt = GetIt.instance;
  getIt.registerSingleton<GoRouter>(createRouterConfig());
  getIt.registerSingletonAsync<AnnotationService>(() async =>
      AnnotationService(networkRepository: AnnotationNetworkRepository(),
      localRepository: await AnnotationLocalRepository.init()));
}
