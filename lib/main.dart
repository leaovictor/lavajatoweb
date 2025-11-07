import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lavajato/data/repositories/appointment_repository_impl.dart';
import 'package:lavajato/data/repositories/auth_repository_impl.dart';
import 'package:lavajato/data/repositories/service_repository_impl.dart';
import 'package:lavajato/data/repositories/plan_repository_impl.dart';
import 'package:lavajato/domain/repositories/appointment_repository.dart';
import 'package:lavajato/domain/repositories/auth_repository.dart';
import 'package:lavajato/domain/repositories/plan_repository.dart';
import 'package:lavajato/domain/repositories/service_repository.dart';
import 'package:lavajato/firebase_options.dart';
import 'package:lavajato/screens/main_screen.dart';
import 'package:lavajato/services/auth_gate.dart';
import 'package:lavajato/theme/app_theme.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // For development, create a .env file from .env.example and add your keys.
  await dotenv.load(fileName: "assets/.env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set Stripe publishable key
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(),
        ),
        Provider<AppointmentRepository>(
          create: (_) => AppointmentRepositoryImpl(FirebaseFirestore.instance),
        ),
        Provider<ServiceRepository>(
          create: (_) => ServiceRepositoryImpl(FirebaseFirestore.instance),
        ),
        Provider<PlanRepository>(
          create: (_) => PlanRepositoryImpl(FirebaseFirestore.instance),
        ),
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
      title: 'LavaJato App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      locale: const Locale('pt', 'BR'),
      home: const AuthGate(),
    );
  }
}
