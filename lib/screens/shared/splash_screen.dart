import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../data/models/user_model.dart';
import '../auth/login_screen.dart';
import '../student/student_shell.dart';
import '../startup/startup_shell.dart';
import '../shared/onboarding_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          );
        } else if (state.status == AuthStatus.authenticated && state.user != null) {
          Widget destination;
          if (!state.user!.onboardingComplete) {
            destination = const OnboardingScreen();
          } else if (state.user!.role == UserRole.student) {
            destination = const StudentShell();
          } else {
            destination = const StartupShell();
          }
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => destination),
            (_) => false,
          );
        }
      },
      child: const Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 56),
              SizedBox(height: 16),
              Text('LaunchPad ALU',
                  style: TextStyle(
                      color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 24),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
