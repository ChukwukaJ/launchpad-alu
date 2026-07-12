import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme.dart';
import '../../cubits/application/application_cubit.dart';
import '../../cubits/opportunity/opportunity_cubit.dart';
import '../../data/models/application_model.dart';
import '../../data/models/opportunity_model.dart';
import '../../data/models/startup_model.dart';

class StartupAnalyticsScreen extends StatelessWidget {
  final Startup startup;
  const StartupAnalyticsScreen({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: BlocBuilder<OpportunityCubit, OpportunityState>(
        builder: (context, oppState) {
          return BlocBuilder<ApplicationCubit, ApplicationState>(
            builder: (context, appState) {
              final postings = oppState.myPostings;
              final applications = appState.receivedApplications;
              final openCount = postings.where((o) => o.status == OpportunityStatus.open).length;
              final totalApplicants = postings.fold<int>(0, (sum, o) => sum + o.applicantCount);
              final accepted =
                  applications.where((a) => a.status == ApplicationStatus.accepted).length;

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: 'Open Postings', value: '$openCount')),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(label: 'Total Applicants', value: '$totalApplicants')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: 'Accepted', value: '$accepted')),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Avg. Applicants / Posting',
                          value: postings.isEmpty
                              ? '0'
                              : (totalApplicants / postings.length).toStringAsFixed(1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Applications by status', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ...ApplicationStatus.values.map((status) {
                    final count = applications.where((a) => a.status == status).length;
                    final total = applications.isEmpty ? 1 : applications.length;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${_label(status)} ($count)', style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: count / total,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFEDEAF7),
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          );
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
