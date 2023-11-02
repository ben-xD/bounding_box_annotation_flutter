import 'package:banananator/src/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorPage extends StatelessWidget {
  final String? errorMessage;

  const ErrorPage({this.errorMessage, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_circle_left_outlined),
            onPressed: () {
              context.go(Routes.root);
            },
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Oops, we can't find that.",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            (errorMessage == null)
                ? const SizedBox.shrink()
                : Text(errorMessage!),
          ],
        ));
  }
}
