import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capitulo05_sharedpreferences/app_constants/shared_preferences_constants.dart';

class AppPreferences {
  static setWelcomeRead({@required bool status}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(kWelcomeRead, status);
  }

  static getWelcomeRead() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(kWelcomeRead) ?? false;
  }
}
