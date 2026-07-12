import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme.dart';
import '../../cubits/opportunity/opportunity_cubit.dart';
import '../../data/models/opportunity_model.dart';
import '../../data/models/startup_model.dart';
import '../../widgets/common_widgets.dart';
import 'post_opportunity_screen.dart';

class StartupPostingsScreen extends StatelessWidget {
  final Startup startup;
  const StartupPostingsScreen({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    final isVerified = startup.status == VerificationStatus.verified;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Postings')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isVerified
            ? () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PostOpportunityScreen(startup: startup)),
                )
            : () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your startup must be verified before posting.'),
                    backgroundColor: AppColors.warning,
                  ),
                ),
        icon: const Icon(Icons.add),
        label: const Text('New Posting'),
        backgroundColor: isVerified ? AppColors.primary : AppColors.textSecondary,
      ),
      body: Column(
        children: [
          if (!isVerified) _VerificationBanner(status: startup.status),
          Expanded(
            child: BlocBuilder<OpportunityCubit, OpportunityState>(
              builder: (context, state) {
                if (state.myPostings.isEmpty) {
                  return const EmptyState(
                    icon: Icons.work_outline_rounded,
                    title: 'No postings yet',
                    subtitle: 'Create your first opportunity for ALU students to discover.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: state.myPostings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final o = state.myPostings[i];
                    return Card(
                      child: ListTile(
                        title: Text(o.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('${o.category} · ${o.applicantCount} applicants'),
                        trailing: Chip(
                          label: Text(o.status == OpportunityStatus.open ? 'Open' : 'Closed'),
                          backgroundColor: o.status == OpportunityStatus.open
                              ? const Color(0xFFE3F5EB)
                              : const Color(0xFFF1EFF7),
                          labelStyle: TextStyle(
                            color: o.status == OpportunityStatus.open
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                        ),
                        onTap: () => _showActions(context, o),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showActions(BuildContext context, Opportunity o) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (o.status == OpportunityStatus.open)
              ListTile(
                leading: const Icon(Icons.lock_outline_rounded),
                title: const Text('Close posting'),
                onTap: () {
                  context.read<OpportunityCubit>().closeOpportunity(o.id);
                  Navigator.of(sheetContext).pop();
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              title: const Text('Delete posting', style: TextStyle(color: AppColors.error)),
              onTap: () {
                context.read<OpportunityCubit>().deleteOpportunity(o.id);
                Navigator.of(sheetContext).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationBanner extends StatelessWidget {
  final VerificationStatus status;
  const _VerificationBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final pending = status == VerificationStatus.pending;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (pending ? AppColors.warning : AppColors.error).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(pending ? Icons.hourglass_top_rounded : Icons.error_outline_rounded,
              color: pending ? AppColors.warning : AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              pending
                  ? 'Your startup is pending ALU verification. You can\'t post publicly until approved.'
                  : 'Your startup verification was rejected. Contact ALU admin for details.',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
