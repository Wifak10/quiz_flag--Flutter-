import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  
  static Stream<bool> get connectionStream => _connectionStatusController.stream;
  static bool _isOnline = true;
  
  static bool get isOnline => _isOnline;

  static Future<void> initialize() async {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _updateConnectionStatus(result);
    });
    
    // Vérifier le statut initial
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  static void _updateConnectionStatus(ConnectivityResult result) {
    bool wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;
    
    if (wasOnline != _isOnline) {
      _connectionStatusController.add(_isOnline);
    }
  }

  static Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  static void dispose() {
    _connectionStatusController.close();
  }
}