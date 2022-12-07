import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

const defaultCheckInterval = Duration(seconds: 8);

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
  late final _Worker _worker;
  late final ValueNotifier<bool?> _notifier;
  late final Key _key;

  @override
  void initHook() {
    super.initHook();
    _Worker._workersByDomainName
        .putIfAbsent(hook.host, () => _Worker(host: hook.host));
    _worker = _Worker._workersByDomainName[hook.host]!;
    _key = UniqueKey(); // Identifies specific calls to the hook.
    final notifier = ValueNotifier<bool?>(_worker.latestIsConnected)
      ..addListener(_listener);
    _notifier = notifier;
    _worker._addNotifier(_key, _notifier, hook.interval);
  }

  @override
  ValueNotifier<bool?> build(BuildContext context) => _notifier;

  void _listener() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _worker._removeNotifier(_key);
    _notifier.dispose();
  }
}

class _Worker {
  static final Map<String, _Worker> _workersByDomainName = {};
  final String host;
  bool? _latestIsConnected;
  final Map<Key, Duration> _requestedDurationsByKey = {};
  final Map<Key, ValueNotifier<bool?>> _notifierByKey = {};

  bool? get latestIsConnected => _latestIsConnected;

  _Worker({required this.host});

  // Timer triggers internet connectivity check.
  Timer? _timer;

  // Interval to check internet connectivity.
  Duration? _shortestInterval;

  _setShortestInterval(Duration? interval) {
    _shortestInterval = interval;
    _timer?.cancel();
    if (_latestIsConnected == null) {
      // If we don't have any connectivity data, get it immediately.
      // Otherwise we wait. We wouldn't want to check connectivity whenever
      // a new hook is created, that would be accidentally DOS'ing someone's
      // DNS servers.
      _checkInternetConnectivity();
    }
    if (interval != null) {
      _timer =
          Timer.periodic(interval, (timer) => _checkInternetConnectivity());
    }
  }

  Future<void> _checkInternetConnectivity() async {
    try {
      if (!kIsWeb) {
        await InternetAddress.lookup(host);
      }
      // debugPrint("Addresses: ${await InternetAddress.lookup(host)}");
      for (final notifier in _notifierByKey.values) {
        _latestIsConnected = true;
        notifier.value = true;
      }

      // For some reason,  _notifierByKey.values.map((notifier) {...}); doesn't work
    } on SocketException catch (_) {
      // Did you add internet access to your application?
      for (final notifier in _notifierByKey.values) {
        _latestIsConnected = false;
        notifier.value = false;
      }
    }
  }

  _addNotifier(Key key, ValueNotifier<bool?> notifier, Duration interval) {
    // Check not yet stored.
    if (_requestedDurationsByKey.containsKey(key)) {
      throw Exception(
          "Key was already saved in internet connectivity checking worker (_requestedDurationsByKey).");
    }
    if (_notifierByKey.containsKey(key)) {
      throw Exception(
          "Key was already saved in internet connectivity checking worker (_notifierByKey).");
    }

    // Check internet connectivity at shortest interval
    if (_shortestInterval == null || interval < _shortestInterval!) {
      _setShortestInterval(interval);
    }
    _notifierByKey[key] = notifier;
    _requestedDurationsByKey[key] = interval;
  }

  _removeNotifier(Key key) {
    // Check already stored.
    if (!_requestedDurationsByKey.containsKey(key)) {
      throw Exception(
          "Key does not exist in internet connectivity checking worker (_requestedDurationsByKey).");
    }
    if (!_notifierByKey.containsKey(key)) {
      throw Exception(
          "Key does not exist in internet connectivity checking worker (_notifierByKey).");
    }
    // Check internet connectivity at new shortest interval
    _requestedDurationsByKey.remove(key);
    _notifierByKey.remove(key);

    // Update shortestInterval
    // Finding the minimum duration is O(N), where N is the number of concurrent
    // usages of this hook.
    if (_requestedDurationsByKey.isEmpty) {
      _setShortestInterval(null);
    } else {
      _setShortestInterval(_requestedDurationsByKey.values.min);
    }
  }
}

// Allows us to get the min value from a Iterable<Duration>, like List<Duration>
extension IterableDuration on Iterable<Duration> {
  Duration get max =>
      reduce((value, element) => (value >= element) ? value : element);

  Duration get min =>
      reduce((value, element) => (value >= element) ? element : value);
}
