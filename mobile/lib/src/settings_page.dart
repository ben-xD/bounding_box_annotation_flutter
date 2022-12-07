import 'package:banananator/src/connectivity/connectivity.dart';
import 'package:banananator/src/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

import 'constants.dart';

class SettingsPage extends HookWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isConnected = useIsNetworkConnected(uri: Constants.apiUrl);
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_circle_left_outlined),
            onPressed: () => context.go(Routes.root),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Settings"),
            Text("Connected: ${isConnected.value}")
          ],
        ));
  }
}
