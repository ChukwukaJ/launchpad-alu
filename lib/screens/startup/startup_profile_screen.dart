import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/startup/startup_cubit.dart';
import '../../data/models/startup_model.dart';
import '../../widgets/common_widgets.dart';

class StartupProfileScreen extends StatelessWidget {
  const StartupProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final startup = context.watch<StartupCubit>().state.myStartup!;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Startup')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  startup.name.isNotEmpty ? startup.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 28, color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(startup.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            Center(child: Text(startup.tagline, style: const TextStyle(color: AppColors.textSecondary))),
            const SizedBox(height: 10),
            Center(child: _VerificationChip(status: startup.status)),
            const SizedBox(height: 24),
            Text('About', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(startup.description, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 16),
            Row(
              children: [
                Chip(label: Text(startup.industry)),
                const SizedBox(width: 8),
                Chip(label: Text('${startup.teamSize} team members')),
              ],
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Sign Out',
              onPressed: () => context.read<AuthCubit>().signOut(),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationChip extends StatelessWidget {
  final VerificationStatus status;
  const _VerificationChip({required this.status});

  @override
  Widget build(BuildContext context) {
    late Color color;
    late String label;
    late IconData icon;
    switch (status) {
      case VerificationStatus.verified:
        color = AppColors.success;
        label = 'Verified by ALU';
        icon = Icons.verified_rounded;
        break;
      case VerificationStatus.pending:
        color = AppColors.warning;
        label = 'Pending Verification';
        icon = Icons.hourglass_top_rounded;
        break;
      case VerificationStatus.rejected:
        color = AppColors.error;
        label = 'Verification Rejected';
        icon = Icons.error_outline_rounded;
        break;
    }
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }
}
