import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme.dart';
import '../../cubits/application/application_cubit.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/bookmark/bookmark_cubit.dart';
import '../../cubits/opportunity/opportunity_cubit.dart';
import '../../data/models/application_model.dart';
import 'notifications_screen.dart';
import 'profile_sub_screens.dart';
import 'student_bookmarks_screen.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user!;
    final applications = context.watch<ApplicationCubit>().state.myApplications;
    final total = applications.length;
    final shortlisted =
        applications.where((a) => a.status == ApplicationStatus.interview).length;
    final accepted =
        applications.where((a) => a.status == ApplicationStatus.accepted).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), automaticallyImplyLeading: false),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: CircleAvatar(
                radius: 38,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 26, color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(user.fullName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            Center(
              child: Text(user.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(child: _StatBlock(label: 'Applications', value: '$total')),
                _divider(),
                Expanded(child: _StatBlock(label: 'Shortlisted', value: '$shortlisted')),
                _divider(),
                Expanded(child: _StatBlock(label: 'Accepted', value: '$accepted')),
              ],
            ),
            const SizedBox(height: 26),
            _MenuTile(
              icon: Icons.person_outline_rounded,
              label: 'My Profile',
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const ProfileDetailScreen())),
            ),
            _MenuTile(
              icon: Icons.star_border_rounded,
              label: 'Skills & Interests',
              onTap: () =>
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SkillsScreen())),
            ),
            _MenuTile(
              icon: Icons.bookmark_border_rounded,
              label: 'Saved Opportunities',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (routeContext) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: context.read<BookmarkCubit>()),
                      BlocProvider.value(value: context.read<OpportunityCubit>()),
                      BlocProvider.value(value: context.read<ApplicationCubit>()),
                    ],
                    child: const StudentBookmarksScreen(),
                  ),
                ),
              ),
            ),
            _MenuTile(
              icon: Icons.notifications_none_rounded,
              label: 'Notifications',
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const NotificationsScreen())),
            ),
            _MenuTile(
              icon: Icons.help_outline_rounded,
              label: 'Help & Support',
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
            ),
            _MenuTile(
              icon: Icons.logout_rounded,
              label: 'Logout',
              isDestructive: true,
              onTap: () => context.read<AuthCubit>().signOut(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 36, color: const Color(0xFFE3E0F0));
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  const _StatBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.primary),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}