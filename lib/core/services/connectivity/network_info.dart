import "dart:io";

import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

abstract interface class INetworkInfo {
  Future<bool> get isConnected;
}

// provider 
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(connectivity: Connectivity());
}); 

class NetworkInfo implements INetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo({required Connectivity connectivity})
      : _connectivity = connectivity;

  @override
  Future<bool> get isConnected async{

    final result = await _connectivity.checkConnectivity(); // wifi / mobiledata
    if(result.contains(ConnectivityResult.none)){
      return false;
    } 

    return await isInternetAvailable();

  }
      
  Future<bool> isInternetAvailable() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }

  }
}