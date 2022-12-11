import 'package:banananator/src/connectivity/check_internet.dart';
import 'package:flutter/foundation.dart';

class CheckInternetNotifier {
  CheckInternetNotifier._();

  static CheckInternetNotifier instance = CheckInternetNotifier._();

  static final Map<ValueNotifier<bool?>, void Function(bool)>
      _listenerByValueNotifier = {};
  static final Map<ValueNotifier<bool?>, _Params> _paramsByValueNotifier = {};

  ValueNotifier<bool?> regularly(
      {Duration interval = defaultCheckInterval,
      String domain = defaultDomain}) {
    final isConnected = CheckInternet.instance.isConnected(domain: domain);
    final valueNotifier = ValueNotifier<bool?>(isConnected);
    _paramsByValueNotifier[valueNotifier] =
        _Params(domain: domain, interval: interval);
    final listener = _listenerByValueNotifier.putIfAbsent(valueNotifier,
        () => (bool isConnected) => valueNotifier.value = isConnected);
    CheckInternet.instance.regularly(
      onIsConnected: listener,
      interval: interval,
      domain: domain,
      useDnsOverHttps: kIsWeb,
    );
    return valueNotifier;
  }

  /// Disposes the previously requested internet checks.
  dispose(ValueNotifier<bool?> valueNotifier) {
    final listener = _listenerByValueNotifier.remove(valueNotifier);
    if (listener == null) {
      throw Exception("Listener doesn't exist for that valueNotifier");
    }
    final params = _paramsByValueNotifier.remove(valueNotifier);
    if (params == null) {
      throw Exception("Params doesn't exist for that valueNotifier");
    }

    CheckInternet.instance.dispose(
      onIsConnected: listener,
      domain: params.domain,
      interval: params.interval,
    );

    valueNotifier.dispose();
  }
}

@immutable
class _Params {
  const _Params({required this.domain, required this.interval});

  final String domain;
  final Duration interval;

  @override
  int get hashCode => domain.hashCode ^ interval.hashCode;

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }
}
