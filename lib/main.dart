import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/services/ad_service.dart';
import 'core/services/purchase_service.dart';
import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService().initialize();
  await PurchaseService().initialize();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.backgroundDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Lock to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const LumiEditApp());
}

class LumiEditApp extends StatelessWidget {
  const LumiEditApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LumiEdit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
