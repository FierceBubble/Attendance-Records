// ignore_for_file: file_names, constant_identifier_names
import 'package:shared_preferences/shared_preferences.dart';

class UserOptions {
  static const String _Introduction = 'introduction';
  static const String _DateFormat = 'dateformat';

  static Future getDoneIntrocution() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_Introduction);
  }

  static Future<bool> setDoneIntrocution(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return await prefs.setBool(_Introduction, value);
  }

  static Future getDateFormat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_DateFormat);
  }

  static Future<bool> setDateFormat(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return await prefs.setBool(_DateFormat, value);
  }
}
