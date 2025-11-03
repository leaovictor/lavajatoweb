import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart'; // Contains kIsWeb
import 'package:lavajato/firebase_options.dart';
import 'package:lavajato/services/auth_gate.dart';
import 'package:lavajato/services/stripe_service.dart'; // <-- IMPORTAÇÃO ADICIONADA
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Firebase
  await Firebase.initializeApp(
    options: kIsWeb ? DefaultFirebaseOptions.web : DefaultFirebaseOptions.currentPlatform,
  );
  
  // 2. Initialize Stripe SDK (needs to be done once per app launch)
  if (!kIsWeb) {
    Stripe.publishableKey = StripeService.publishableKey;
    await Stripe.instance.applySettings();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LavaJato App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // Localization settings for Brazilian Portuguese
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
