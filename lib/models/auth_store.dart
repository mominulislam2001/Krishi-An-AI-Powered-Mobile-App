// Simple in-memory auth store.
// Replace with secure storage / backend calls in production.

class AuthStore {
  // mobile → {name, password, district, upazila, crops}
  static final Map<String, Map<String, dynamic>> _users = {};
  static String? currentMobile;

  // FR-01: Register with mobile number
  static bool register(String mobile, String password) {
    if (_users.containsKey(mobile)) return false;
    _users[mobile] = {
      'name': '',
      'password': password,
      'district': '',
      'upazila': '',
      'crops': <String>[],
    };
    return true;
  }

  // FR-02: Authenticate user
  static bool login(String mobile, String password) {
    final user = _users[mobile];
    if (user == null) return false;
    if (user['password'] != password) return false;
    currentMobile = mobile;
    return true;
  }

  static Map<String, dynamic>? get currentUser =>
      currentMobile != null ? _users[currentMobile] : null;

  // FR-03: Update profile
  static void updateProfile({
    required String name,
    required String district,
    required String upazila,
    required List<String> crops,
  }) {
    if (currentMobile == null) return;
    _users[currentMobile]!['name']     = name;
    _users[currentMobile]!['district'] = district;
    _users[currentMobile]!['upazila']  = upazila;
    _users[currentMobile]!['crops']    = crops;
  }

  static void logout() => currentMobile = null;
}
