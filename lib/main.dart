import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/routes/app_routes.dart';
import 'app/data/models/case_model.dart';
import 'app/data/models/client_model.dart';
import 'app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // await Hive.box<CaseModel>('cases').clear();


  Hive.registerAdapter(CaseModelAdapter());
  Hive.registerAdapter(ClientModelAdapter());

  await Hive.openBox<CaseModel>('cases');
  await Hive.openBox<ClientModel>('clients');  

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Legal Case Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,   // 🌞 Light theme
      darkTheme: AppTheme.darkTheme, // 🌚 Dark theme
      themeMode: ThemeMode.system,   // 🌓 Follow system setting
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
