import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'cubits/auth/auth_cubit.dart';
import 'screens/shared/splash_screen.dart';
import 'screens/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LaunchPadApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class LaunchPadApp extends StatelessWidget {
  const LaunchPadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) =>
        previous.status != AuthStatus.unauthenticated &&
            current.status == AuthStatus.unauthenticated,
        listener: (context, state) {
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
          );
        },
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'LaunchPad ALU',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}