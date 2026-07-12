import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'cubits/auth/auth_cubit.dart';
import 'screens/shared/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LaunchPadApp());
}

class LaunchPadApp extends StatelessWidget {
  const LaunchPadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // AuthCubit lives at the root because both the splash screen and every
      // nested shell (student/startup) need to read the current AppUser
      // (role, uid, onboarding status) without re-fetching it.
      create: (_) => AuthCubit(),
      child: MaterialApp(
        title: 'LaunchPad ALU',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
