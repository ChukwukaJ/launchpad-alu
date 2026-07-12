import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme.dart';
import '../../cubits/startup/startup_cubit.dart';
import '../../data/models/startup_model.dart';
import '../../widgets/common_widgets.dart';

/// Reachable only by accounts whose AppUser.role == UserRole.admin (route
/// guard lives in main.dart). Keeping this as its own screen — rather than
/// folding review into the startup profile screen — means the trust
/// boundary between "self-reported" and "ALU-approved" data is a distinct,
/// auditable step rather than a toggle a startup could flip on itself.
class AdminVerificationScreen extends StatefulWidget {
  const AdminVerificationScreen({super.key});

  @override
  State<AdminVerificationScreen> createState() => _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends State<AdminVerificationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StartupCubit>().watchAdminQueue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Startup Verification Queue')),
      body: BlocBuilder<StartupCubit, StartupState>(
        builder: (context, state) {
          if (state.pendingStartups.isEmpty) {
            return const EmptyState(
              icon: Icons.task_alt_rounded,
              title: 'Queue is empty',
              subtitle: 'New startup registrations awaiting review will appear here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.pendingStartups.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final s = state.pendingStartups[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(s.tagline, style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Text(s.description, style: const TextStyle(height: 1.4)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(label: Text(s.industry)),
                          const SizedBox(width: 8),
                          Chip(label: Text('${s.teamSize} members')),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                              ),
                              onPressed: () => context.read<StartupCubit>().reject(s.id),
                              child: const Text('Reject'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => context.read<StartupCubit>().approve(s.id),
                              child: const Text('Approve'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
