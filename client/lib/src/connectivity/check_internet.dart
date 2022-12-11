import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';

const defaultCheckInterval = Duration(seconds: 10);
const defaultDomain = "cloudflare.com";

class CheckInternet {
  CheckInternet._();

  // TODO convert to a map?
  static final dnsWebCloudflare =
      Uri.https("1.1.1.1", "dns-query", {"name": defaultDomain});
  static final Map<String, _Worker> _workersByDomainName = {};

  static CheckInternet instance = CheckInternet._();

  regularly(
      {Duration interval = defaultCheckInterval,
      String domain = defaultDomain,
      required void Function(bool) onIsConnected,
      bool useDnsOverHttps = false}) {
    print("Setting up listener: $onIsConnected");
    // register this domain to be checked regularly if not already.
    final worker = _workersByDomainName.putIfAbsent(
      domain,
      () => _Worker(host: domain, useDnsOverHttps: useDnsOverHttps),
    );
    worker._addListener(onIsConnected, interval);
  }

  dispose(
      {Duration interval = defaultCheckInterval,
      String domain = defaultDomain,
      required void Function(bool) onIsConnected}) {
    print("Disposing listener: $onIsConnected");
    final worker = _workersByDomainName[domain];
    if (worker == null) {
      throw Exception("InternetCheck Worker was not found that domain. "
          "Did you set up a regular internet check with that domain?");
    }
    worker._removeListener(onIsConnected, interval);
  }

  bool? isConnected({required String domain}) {
    // Returns a value only if it has been set up in the past.
    final worker = _workersByDomainName[domain];
    return worker?._isConnected;
  }
}

class _Worker {
  final String host;
  bool? _isConnected;
  final PriorityQueue<Duration> _requestedDurations = PriorityQueue();
  final Set<void Function(bool)> _listeners = {};
  final bool useDnsOverHttps;

  bool? get isConnected => _isConnected;

  // TODO consider using a setter instead of this function.
  void setIsConnected(bool isConnected) {
    _isConnected = isConnected;
    for (final l in _listeners) {
      l(isConnected);
    }
  }

  _Worker({required this.host, required this.useDnsOverHttps});

  // Timer triggers internet connectivity check.
  Timer? _timer;

  _setShortestInterval(Duration? interval) {
    _timer?.cancel();
    if (_isConnected == null) {
      // If we don't have any connectivity data, check it immediately.
      // Otherwise we wait. We wouldn't want to check connectivity whenever
      // a new listener is added, that might accidentally DOS someone's
      // DNS servers.
      _checkInternetConnectivity();
    }
    if (interval != null) {
      _timer =
          Timer.periodic(interval, (timer) => _checkInternetConnectivity());
    }
  }

  _addListener(void Function(bool) listener, Duration interval) {
    _requestedDurations.add(interval);
    // TODO are listeners that look the same in dart, the "same" listener?
    _listeners.add(listener);
    if (_requestedDurations.length == 1 ||
        interval < _requestedDurations.first) {
      _setShortestInterval(interval);
    }
  }

  _removeListener(void Function(bool) listener, Duration interval) {
    if (!_requestedDurations.contains(interval)) {
      throw Exception(
          "Tried to remove interval $interval but it did not exist");
    }
    if (!_listeners.contains(listener)) {
      throw Exception(
          "Tried to remove listener $listener but it did not exist");
    }
    // Removes 1 instance of the duration, even if there are multiple of the same.
    _requestedDurations.remove(interval);
    _listeners.remove(listener);
    if (_requestedDurations.isEmpty) {
      _setShortestInterval(null);
    } else {
      _setShortestInterval(_requestedDurations.first);
    }
  }

  Future<void> _checkInternetConnectivity() async {
    try {
      if (useDnsOverHttps) {
        await _lookupUsingDnsOverHttp(host);
      } else {
        await InternetAddress.lookup(host);
      }
      setIsConnected(true);
      // For some reason,  _notifierByKey.values.map((notifier) {...}); doesn't work
    } on SocketException catch (_) {
      // Did you add internet access to your application?
      setIsConnected(false);
    } on http.ClientException catch (_) {
      // XMLHttpRequest error on web.
      setIsConnected(false);
    }
  }

  Future<void> _lookupUsingDnsOverHttp(String host) async {
    final dnsEndpoint = Uri.https("1.1.1.1", "dns-query", {"name": host});
    // For example, try run `curl -H "accept: application/dns-json" "https://cloudflare-dns.com/dns-query?name=orth.uk`
    await http.get(dnsEndpoint, headers: {"accept": "application/dns-json"});
  }
}
