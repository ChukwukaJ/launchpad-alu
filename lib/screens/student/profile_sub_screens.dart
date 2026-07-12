import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../widgets/common_widgets.dart';

class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user!;
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _Row(label: 'Full name', value: user.fullName),
            _Row(label: 'Email', value: user.email),
            _Row(label: 'Bio', value: (user.bio == null || user.bio!.isEmpty) ? '—' : user.bio!),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class SkillsScreen extends StatelessWidget {
  const SkillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final skills = context.watch<AuthCubit>().state.user?.skills ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Skills & Interests')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: skills.isEmpty
              ? const EmptyState(
                  icon: Icons.star_border_rounded,
                  title: 'No skills added yet',
                  subtitle: 'Skills you add during onboarding power your match score.',
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills.map((s) => Chip(label: Text(s))).toList(),
                ),
        ),
      ),
    );
  }
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            ListTile(
              leading: Icon(Icons.email_outlined, color: AppColors.primary),
              title: Text('Email support'),
              subtitle: Text('support@launchpad-alu.app'),
            ),
            ListTile(
              leading: Icon(Icons.help_outline_rounded, color: AppColors.primary),
              title: Text('FAQs'),
              subtitle: Text('Common questions about applying and verification'),
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
              title: Text('Privacy & Terms'),
            ),
          ],
        ),
      ),
    );
  }
}
