import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:rmts/core/providers.dart';
import 'package:rmts/data/models/hive/flex_data.dart';
import 'package:rmts/data/models/hive/fsr_data.dart';
import 'package:rmts/data/models/hive/mpu_data.dart';
import 'package:rmts/data/models/hive/ppg_data.dart';
import 'package:rmts/data/repositories/glove_repository.dart';
import 'package:rmts/ui/responsive/mobile_screen_layout.dart';
import 'package:rmts/ui/responsive/responsive_layout_screen.dart';
import 'package:rmts/ui/responsive/web_screen_layout.dart';
import 'package:rmts/ui/themes/theme.dart';
import 'package:rmts/ui/views/auth/login_view.dart';
import 'package:rmts/ui/views/auth/splashScreens/SplashView.dart';
import 'package:rmts/utils/helpers/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(MpuDataAdapter());
  await Hive.openBox<MpuData>('mpu_data');
  Hive.registerAdapter(PpgDataAdapter());
  await Hive.openBox<PpgData>('ppg_data');
  Hive.registerAdapter(FlexDataAdapter());
  await Hive.openBox<FlexData>('flex_data');
  Hive.registerAdapter(FSRDataAdapter());
  await Hive.openBox<FSRData>('fsr_data');

  final gloveRepository = GloveRepository();

  final prefs = await SharedPreferences.getInstance();
  final themeStr = prefs.getString('display_mode') ?? 'system';
  const langCode = 'en';

  ThemeMode themeMode = switch (themeStr) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  final appSettings = AppSettings();
  appSettings.setThemeMode(themeMode);
  appSettings.setLocale(const Locale(langCode));

  runApp(
    MultiProvider(
      providers: [
        ...appProviders(gloveRepository),
        ChangeNotifierProvider(
            create: (_) => appSettings), // Use configured instance
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RMTS System',
      theme: const MaterialTheme(TextTheme()).light(),
      darkTheme: const MaterialTheme(TextTheme()).dark(),
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('tr'),
      ],
      localizationsDelegates: const [
        // Add localization delegates
      ],
      home: const AuthWrapper(),
    );
  }
}

// 🔹 Handles authentication state and redirects accordingly
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else {
          if (snapshot.hasData) {
            return const ResponsiveLayout(
              mobileScreenLayout: MobileScreenLayout(),
              webScreenLayout: WebScreenLayout(),
            );
          }
          return const LoginView(); // Show Splash Screen
        }
      },
    );
  }
}
