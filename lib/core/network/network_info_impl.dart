import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'network_info.dart';

final class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl(this._internetConnection);

  final InternetConnection _internetConnection;

  @override
  Future<bool> get isConnected {
    return _internetConnection.hasInternetAccess;
  }
}
