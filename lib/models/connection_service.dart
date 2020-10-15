import 'package:connectivity/connectivity.dart';

enum ConnectionStatus { CONNECTED, DISCONNECTED }

class ConnectionService {
  final Connectivity _connectivity = new Connectivity();

  Future<ConnectionStatus> checkConnectionStatus() async {
    var connectivityResult = await _connectivity.checkConnectivity();

    return (connectivityResult == ConnectivityResult.mobile ||
            connectivityResult == ConnectivityResult.wifi)
        ? ConnectionStatus.CONNECTED
        : ConnectionStatus.DISCONNECTED;
  }
}
