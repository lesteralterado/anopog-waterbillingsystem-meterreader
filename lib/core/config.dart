/// Simple runtime-config for API base URL.
/// Update this to point to your backend (use device-accessible host/IP for physical devices).
class Config {
  /// Default base URL. Change this to your server address.
  /// For Android emulator use `http://10.0.2.2:3000`.
  /// For a physical device on the same LAN, use your machine IP, e.g. `http://192.168.1.42:3000`.
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'https://anopog-waterbillingsystem-backend.onrender.com');
}
