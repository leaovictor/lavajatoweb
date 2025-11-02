import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart'; // Contains kIsWeb
import 'package:lavajato/firebase_options.dart';
import 'package:lavajato/services/auth_gate.dart';
import 'package:lavajato/stripe_keys.dart'; // Assumed to contain stripePublishableKey

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Firebase, conditionally using web options if running in a browser.
  await Firebase.initializeApp(
    options: kIsWeb ? DefaultFirebaseOptions.web : DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Initialize Stripe
  Stripe.publishableKey = stripePublishableKey;
  await Stripe.instance.applySettings();
  
  // NOTE FOR WEB: On Flutter Web, the Stripe keys should also be configured 
  // by ensuring the Stripe SDK is loaded via a <script> tag in your index.html file.
  // The flutter_stripe package then bridges to the browser SDK automatically.

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
