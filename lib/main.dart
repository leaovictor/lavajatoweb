import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:lavajato/data/repositories/appointment_repository_impl.dart';
import 'package:lavajato/data/repositories/auth_repository_impl.dart';
import 'package:lavajato/data/repositories/service_repository_impl.dart';
import 'package:lavajato/data/repositories/plan_repository_impl.dart';
import 'package:lavajato/domain/repositories/appointment_repository.dart';
import 'package:lavajato/domain/repositories/auth_repository.dart';
import 'package:lavajato/domain/repositories/plan_repository.dart';
import 'package:lavajato/domain/repositories/service_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lavajato/blocs/admin/admin_bloc.dart';
import 'package:lavajato/blocs/auth/auth_bloc.dart';
import 'package:lavajato/data/repositories/payment_repository_impl.dart';
import 'package:lavajato/data/repositories/stripe_repository_impl.dart';
import 'package:lavajato/data/repositories/admin_repository_impl.dart';
import 'package:lavajato/data/repositories/payment_repository_impl.dart';
import 'package:lavajato/data/repositories/stripe_repository_impl.dart';
import 'package:lavajato/data/repositories/user_repository_impl.dart';
import 'package:lavajato/domain/repositories/admin_repository.dart';
import 'package:lavajato/domain/repositories/payment_repository.dart';
import 'package:lavajato/domain/repositories/stripe_repository.dart';
import 'package:lavajato/domain/repositories/user_repository.dart';
import 'package:lavajato/blocs/theme/theme_bloc.dart';
import 'package:lavajato/firebase_options.dart';
import 'package:lavajato/screens/main_screen.dart';
import 'package:lavajato/services/auth_gate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lavajato/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set Stripe publishable key
  Stripe.publishableKey = 'pk_test_YOUR_PUBLISHABLE_KEY'; // Replace with your key

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(),
        ),
        BlocProvider(
          create: (context) => AuthBloc(
            authRepository: context.read<AuthRepository>(),
          ),
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
        Provider<UserRepository>(
          create: (_) => UserRepositoryImpl(FirebaseFirestore.instance),
        ),
        Provider<StripeRepository>(
          create: (_) => StripeRepositoryImpl(),
        ),
        Provider<PaymentRepository>(
          create: (_) => PaymentRepositoryImpl(FirebaseFirestore.instance),
        ),
        Provider<AdminRepository>(
          create: (_) => AdminRepositoryImpl(),
        ),
        BlocProvider(
          create: (context) => AdminBloc(
            userRepository: context.read<UserRepository>(),
            appointmentRepository: context.read<AppointmentRepository>(),
            stripeRepository: context.read<StripeRepository>(),
            paymentRepository: context.read<PaymentRepository>(),
            adminRepository: context.read<AdminRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => ThemeBloc(),
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
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'LavaJato App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: state.themeMode,
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
      },
    );
  }
}
