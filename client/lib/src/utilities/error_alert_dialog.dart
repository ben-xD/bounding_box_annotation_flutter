import 'package:flutter/material.dart';

class ErrorAlertDialog extends StatelessWidget {
  final Iterable<String> errors;
  const ErrorAlertDialog({required this.errors, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Oopsies? 💩"),
          const SizedBox(height: 16),
          Text(
              "${errors.length} unique ${(errors.length == 1) ? "error" : "errors"}."),
          const SizedBox(height: 8),
          ...errors.map((e) => Text(
                e,
                style: Theme.of(context).textTheme.titleMedium,
              )),
        ],
      ),
    );
  }
}
