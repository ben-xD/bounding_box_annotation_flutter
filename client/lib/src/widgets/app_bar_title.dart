import 'package:flutter/material.dart';
import 'package:twemoji/twemoji.dart';

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TwemojiTextSpan(
        text: 'Banananator 🍌📸',
        style:
            Theme.of(context).textTheme.titleLarge!.apply(color: Colors.white),
      ),
    );
  }
}
