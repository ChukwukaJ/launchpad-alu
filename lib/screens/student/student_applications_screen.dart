import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/theme.dart';
import '../../cubits/application/application_cubit.dart';
import '../../data/models/application_model.dart';
import '../../widgets/common_widgets.dart';

enum _Tab { applied, interview, accepted, all }

class StudentApplicationsScreen extends StatefulWidget {
  const StudentApplicationsScreen({super.key});

  @override
  State<StudentApplicationsScreen> createState() => _StudentApplicationsScreenState();
}

class _StudentApplicationsScreenState extends State<StudentApplicationsScreen> {
  _Tab _selected = _Tab.applied;

  // "Applied" groups submitted + underReview — both mean "the ball is in
  // the startup's court" from the student's point of view, mirroring how
  // most job-tracker apps collapse early-stage statuses into one tab.
  bool _matches(ApplicationStatus status, _Tab tab) {
    switch (tab) {
      case _Tab.applied:
        return status == ApplicationStatus.submitted || status == ApplicationStatus.underReview;
      case _Tab.interview:
        return status == ApplicationStatus.interview;
      case _Tab.accepted:
        return status == ApplicationStatus.accepted;
      case _Tab.all:
        return true;
    }
  }

  String _tabLabel(_Tab tab) {
    switch (tab) {
      case _Tab.applied:
        return 'Applied';
      case _Tab.interview:
        return 'Interview';
      case _Tab.accepted:
        return 'Accepted';
      case _Tab.all:
        return 'All';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Applications')),
      body: BlocBuilder<ApplicationCubit, ApplicationState>(
        builder: (context, state) {
          final filtered =
              state.myApplications.where((a) => _matches(a.status, _selected)).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _Tab.values.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final tab = _Tab.values[i];
                      final selected = tab == _selected;
                      return ChoiceChip(
                        label: Text(_tabLabel(tab)),
                        selected: selected,
                        onSelected: (_) => setState(() => _selected = tab),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: const Color(0xFFEFEBFA),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const EmptyState(
                        icon: Icons.assignment_outlined,
                        title: 'Nothing here yet',
                        subtitle: 'Applications in this status will show up here with live updates.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final app = filtered[i];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(app.opportunityTitle,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700, fontSize: 15.5)),
                                      ),
                                      StatusPill(status: app.status),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(app.startupName,
                                      style: const TextStyle(color: AppColors.textSecondary)),
                                  const SizedBox(height: 8),
                                  Text('Applied ${timeago.format(app.submittedAt)}',
                                      style: const TextStyle(
                                          fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
