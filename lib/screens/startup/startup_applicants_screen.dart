import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme.dart';
import '../../cubits/application/application_cubit.dart';
import '../../data/models/application_model.dart';
import '../../data/models/startup_model.dart';
import '../../widgets/common_widgets.dart';

class StartupApplicantsScreen extends StatelessWidget {
  final Startup startup;
  const StartupApplicantsScreen({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Applicants')),
      body: BlocBuilder<ApplicationCubit, ApplicationState>(
        builder: (context, state) {
          if (state.receivedApplications.isEmpty) {
            return const EmptyState(
              icon: Icons.people_outline_rounded,
              title: 'No applicants yet',
              subtitle: 'Once students apply to your postings, they\'ll show up here in real time.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.receivedApplications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final app = state.receivedApplications[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              app.studentName.isNotEmpty ? app.studentName[0].toUpperCase() : '?',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(app.studentName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text('Applied for ${app.opportunityTitle}',
                                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          StatusPill(status: app.status),
                        ],
                      ),
                      if (app.coverNote.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(app.coverNote, style: const TextStyle(height: 1.4)),
                      ],
                      const SizedBox(height: 8),
                      Text('Submitted ${timeago.format(app.submittedAt)}',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                      const SizedBox(height: 10),
                      _StatusDropdown(application: app),
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

class _StatusDropdown extends StatelessWidget {
  final Application application;
  const _StatusDropdown({required this.application});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DropdownButtonFormField<ApplicationStatus>(
        value: application.status,
        decoration: const InputDecoration(
          labelText: 'Update status',
          isDense: true,
        ),
        items: ApplicationStatus.values
            .map((s) => DropdownMenuItem(value: s, child: Text(_label(s))))
            .toList(),
        onChanged: (newStatus) {
          if (newStatus != null && newStatus != application.status) {
            context.read<ApplicationCubit>().updateStatus(application, newStatus);
          }
        },
      ),
    );
  }

  String _label(ApplicationStatus s) {
    switch (s) {
      case ApplicationStatus.submitted:
        return 'Submitted';
      case ApplicationStatus.underReview:
        return 'Under Review';
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }
}
