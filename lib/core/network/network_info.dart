/// Abstract class defining the network information interface
abstract class NetworkInfo {
  /// Returns true if the device is connected to the internet
  Future<bool> get isConnected;
}

/// Implementation of NetworkInfo
class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // For simplicity, we'll assume the device is always connected
    // In a real app, you would use a package like connectivity_plus to check
    return true;
  }
}
