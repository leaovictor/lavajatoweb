import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart';
import 'package:lavajato/firebase_options.dart';
import 'package:lavajato/services/auth_gate.dart';
import 'package:lavajato/stripe_keys.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // NOTE: You need to configure Firebase for your project.
  // You can generate the configuration file by following the instructions here:
  // https://firebase.google.com/docs/flutter/setup
  await Firebase.initializeApp(
    options: kIsWeb ? DefaultFirebaseOptions.web : DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Stripe
  Stripe.publishableKey = stripePublishableKey;
  await Stripe.instance.applySettings();

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
      // New localization settings
      localizationsDelegates: [
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
