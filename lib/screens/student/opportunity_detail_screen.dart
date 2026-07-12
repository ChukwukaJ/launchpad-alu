import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../cubits/application/application_cubit.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../data/models/application_model.dart';
import '../../data/models/opportunity_model.dart';
import '../../widgets/common_widgets.dart';

class OpportunityDetailScreen extends StatelessWidget {
  final Opportunity opportunity;
  const OpportunityDetailScreen({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(opportunity.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      opportunity.startupName.isNotEmpty
                          ? opportunity.startupName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opportunity.startupName,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        Text('${opportunity.category} · ${AppConstants.workModeLabel(opportunity.workMode)}',
                            style: const TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(opportunity.duration)),
                  if (opportunity.isPaid)
                    const Chip(label: Text('Paid'), backgroundColor: Color(0xFFE3F5EB)),
                  Chip(label: Text('${opportunity.applicantCount} applicants')),
                ],
              ),
              const SizedBox(height: 20),
              Text('About this role', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(opportunity.description, style: const TextStyle(height: 1.5)),
              const SizedBox(height: 20),
              Text('Skills needed', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: opportunity.requiredSkills.map((s) => Chip(label: Text(s))).toList(),
              ),
              const SizedBox(height: 32),
              _ApplyButton(opportunity: opportunity),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplyButton extends StatefulWidget {
  final Opportunity opportunity;
  const _ApplyButton({required this.opportunity});

  @override
  State<_ApplyButton> createState() => _ApplyButtonState();
}

class _ApplyButtonState extends State<_ApplyButton> {
  bool _applied = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ApplicationCubit, ApplicationState>(
      listenWhen: (p, c) => p.isSubmitting && !c.isSubmitting,
      listener: (context, state) {
        if (state.errorMessage == null) {
          setState(() => _applied = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Application submitted!'), backgroundColor: AppColors.success),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        final alreadyApplied = _applied ||
            state.myApplications.any((a) => a.opportunityId == widget.opportunity.id);
        return PrimaryButton(
          label: alreadyApplied ? 'Applied ✓' : 'Apply Now',
          isLoading: state.isSubmitting,
          onPressed: alreadyApplied ? null : () => _showApplySheet(context),
        );
      },
    );
  }

  void _showApplySheet(BuildContext context) {
    final coverNoteController = TextEditingController();
    final user = context.read<AuthCubit>().state.user!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Apply to ${widget.opportunity.title}',
                style: Theme.of(sheetContext).textTheme.titleMedium),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Why are you a good fit? (short note)',
              controller: coverNoteController,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Submit Application',
              onPressed: () {
                final now = DateTime.now();
                final application = Application(
                  id: '',
                  opportunityId: widget.opportunity.id,
                  opportunityTitle: widget.opportunity.title,
                  startupId: widget.opportunity.startupId,
                  startupName: widget.opportunity.startupName,
                  studentUid: user.uid,
                  studentName: user.fullName,
                  studentPhotoUrl: user.photoUrl,
                  coverNote: coverNoteController.text.trim(),
                  submittedAt: now,
                  updatedAt: now,
                );
                context.read<ApplicationCubit>().submitApplication(application);
                Navigator.of(sheetContext).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
