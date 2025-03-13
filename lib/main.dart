import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rmts/data/repositories/glove_repository.dart';
import 'package:rmts/ui/themes/theme.dart';
import 'package:rmts/ui/views/auth/splashScreens/SplashView.dart';
import 'package:rmts/ui/views/home_view.dart';
import 'package:rmts/viewmodels/appointment_viewmodel.dart';
import 'package:rmts/viewmodels/auth/auth_viewmodel.dart';
import 'package:rmts/viewmodels/auth/register_viewmodel.dart';
import 'package:rmts/viewmodels/glove_viewmodel.dart';

import 'viewmodels/reports_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ensure Firebase is initialized

  final gloveRepository = GloveRepository();

  // Run the app with MultiProvider for state management
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthViewModel()), // Authentication Provider
        ChangeNotifierProvider(
            create: (_) => RegisterViewModel()), // Registration Provider
        ChangeNotifierProvider(
            create: (_) => ReportsViewModel()), // Reports Provider
        ChangeNotifierProvider(
            create: (_) =>
                GloveViewModel(gloveRepository)), // Glove Data Provider
        ChangeNotifierProvider(
            create: (_) => AppointmentViewmodel()), // Appointment Management
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RMTS System',
      theme: const MaterialTheme(TextTheme()).light(), 
      darkTheme: const MaterialTheme(TextTheme()).dark(), 
      themeMode: ThemeMode.system, 
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
            return const HomeView(); // Show Home Screen
          }
          return const SplashView(); // Show Splash Screen
        }
      },
    );
  }
}
