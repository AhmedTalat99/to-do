import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:to_do/services/theme_services.dart';
import 'package:to_do/ui/theme.dart';
import 'db/db_helper.dart';
import 'ui/pages/home_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDB();
  await  GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // I changed MaterialApp to GetMaterialApp to give permissions to Get to control state
    return  GetMaterialApp(
      theme: Themes.light,
      darkTheme: Themes.dark,
     // themeMode: ThemeMode.light, // controller of theme
      themeMode: ThemeServices().theme, // i created object of ThemeServices,then calling of theme
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home:const HomePage(), // payload loads text
    );
  }
}
