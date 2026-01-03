import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

typedef ProviderCategoryInfo = Map<String, String>;

class ProviderProfileService {
  static const _storageKey = 'provider_profile';

  static Future<Map<String, ProviderCategoryInfo>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return {};

    final decoded = json.decode(raw);
    if (decoded is! Map<String, dynamic>) return {};

    final result = <String, ProviderCategoryInfo>{};
    decoded.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final info = <String, String>{};
        value.forEach((fieldKey, fieldValue) {
          if (fieldValue is String) {
            info[fieldKey] = fieldValue;
          }
        });
        result[key] = info;
      }
    });
    return result;
  }

  static Future<void> saveProfile(
    Map<String, ProviderCategoryInfo> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, json.encode(data));
  }

  static Future<bool> hasProfile() async {
    final data = await getProfile();
    return data.isNotEmpty;
  }

  static Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
