import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Shared {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _prefs = await SharedPreferences.getInstance();
  }

  String? get userId => _prefs.getString("userId");

  Future<void> setUserId(String userId) async {
    await _prefs.setString("userId", userId);
  }

  Future<void> deleteUserId() async {
    await _prefs.remove("userId");
  }
}
