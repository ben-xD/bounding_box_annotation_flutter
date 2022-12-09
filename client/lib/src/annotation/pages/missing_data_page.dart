import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final String? errorMessage;

  const ErrorPage({this.errorMessage, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Oops, we can't find that.", style: Theme.of(context).textTheme.headline4,),
        (errorMessage == null) ? const SizedBox.shrink() : Text(errorMessage!),
      ],
    ));
  }
}
