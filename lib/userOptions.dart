// ignore_for_file: file_names, constant_identifier_names

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _DateFormat = 'dateformat';

Future<bool> getDateFormat() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.getBool(_DateFormat) ?? true;
}

/// ----------------------------------------------------------
/// Method that saves the user language code
/// ----------------------------------------------------------
Future<bool> setDateFormat(bool value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.setBool(_DateFormat, value);
}
