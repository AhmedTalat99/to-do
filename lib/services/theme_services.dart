import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeServices {
  final  GetStorage _box = GetStorage(); // GetStorage is used to store date,and is used with Getx
  final _key= 'isDarkMode';

  _saveThemeTOBox(bool isDarkMode)=> _box.write(_key, isDarkMode); // saving data in box
  bool _loadThemeFromBox()=>_box.read<bool>(_key)??false;
  /*
   + _loadThemeFromBox showing data in box
   + initially  _loadThemeFromBox  = null,so i put ?? after (_key) and wil return false
   */

  // Getter return ThemeMode
  ThemeMode get theme=>_loadThemeFromBox()?ThemeMode.dark:ThemeMode.light;

  void switchTheme(){
    Get.changeThemeMode(_loadThemeFromBox()?ThemeMode.light:ThemeMode.dark);// if _loadThemeFromBox=true ,this mean mode= dark,so i put ThemeMode.light
    _saveThemeTOBox(!_loadThemeFromBox()); // i put ! before _loadThemeFromBox because mode had changed
  }

}
