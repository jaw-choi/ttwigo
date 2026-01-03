import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { user, provider }

class UserRoleService {
  static const _storageKey = 'user_role';
  static UserRole? _cached;

  static Future<UserRole?> getRole() async {
    if (_cached != null) {
      return _cached;
    }
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_storageKey);
    _cached = _fromStorage(value);
    return _cached;
  }

  static Future<void> setRole(UserRole role) async {
    _cached = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, role.name);
  }

  static Future<void> clearRole() async {
    _cached = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  static UserRole? _fromStorage(String? value) {
    if (value == null) return null;
    for (final role in UserRole.values) {
      if (role.name == value) {
        return role;
      }
    }
    return null;
  }
}
