import 'package:banananator/src/connectivity/check_internet.dart';
import 'package:banananator/src/connectivity/check_internet_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// This hook makes a DNS request to the domain provided in the URL every
/// [checkInterval] to check for network connectivity.
ValueNotifier<bool?> useIsNetworkConnected(
    {required Uri uri, Duration checkInterval = defaultCheckInterval}) {
  return use(_IsNetworkConnectedHook(host: uri.host, interval: checkInterval));
}

class _IsNetworkConnectedHook extends Hook<ValueNotifier<bool?>> {
  final String host;
  final Duration interval;

  const _IsNetworkConnectedHook({required this.host, required this.interval});

  @override
  HookState<ValueNotifier<bool?>, Hook<ValueNotifier<bool?>>> createState() {
    return IsNetworkConnectedHookState();
  }
}

class IsNetworkConnectedHookState
    extends HookState<ValueNotifier<bool?>, _IsNetworkConnectedHook> {
  late final ValueNotifier<bool?> _notifier;

  @override
  void initHook() {
    super.initHook();
    _notifier = CheckInternetNotifier.instance
        .regularly(interval: hook.interval, domain: hook.host)
      ..addListener(_listener);
  }

  @override
  ValueNotifier<bool?> build(BuildContext context) => _notifier;

  void _listener() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    CheckInternetNotifier.instance.dispose(_notifier);
  }
}
