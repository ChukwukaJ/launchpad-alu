import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/models/user_model.dart';
import 'signup_screen.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join LaunchPad ALU')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How will you use LaunchPad?', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('This determines what you\'ll see first — you can\'t switch roles later.',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 28),
            _RoleCard(
              icon: Icons.school_rounded,
              title: 'I\'m a Student',
              subtitle: 'Discover internships and apply to student-led startups.',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const SignupScreen(role: UserRole.student),
              )),
            ),
            const SizedBox(height: 16),
            _RoleCard(
              icon: Icons.rocket_launch_rounded,
              title: 'I run a Startup',
              subtitle: 'Post opportunities and find talented ALU students.',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const SignupScreen(role: UserRole.startup),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
