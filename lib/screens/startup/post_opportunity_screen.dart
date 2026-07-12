import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants.dart';
import '../../cubits/opportunity/opportunity_cubit.dart';
import '../../data/models/opportunity_model.dart';
import '../../data/models/startup_model.dart';
import '../../widgets/common_widgets.dart';

class PostOpportunityScreen extends StatefulWidget {
  final Startup startup;
  const PostOpportunityScreen({super.key, required this.startup});

  @override
  State<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends State<PostOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _duration = TextEditingController(text: '3 months');
  final _skillsController = TextEditingController();
  String _category = AppConstants.opportunityCategories.first;
  WorkMode _workMode = WorkMode.remote;
  bool _isPaid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Opportunity')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                AppTextField(
                  label: 'Title',
                  controller: _title,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: AppConstants.opportunityCategories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Description',
                  controller: _description,
                  maxLines: 5,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Required skills (comma separated)',
                  controller: _skillsController,
                ),
                const SizedBox(height: 14),
                AppTextField(label: 'Duration (e.g. "3 months")', controller: _duration),
                const SizedBox(height: 14),
                DropdownButtonFormField<WorkMode>(
                  value: _workMode,
                  decoration: const InputDecoration(labelText: 'Work mode'),
                  items: WorkMode.values
                      .map((m) => DropdownMenuItem(
                          value: m, child: Text(AppConstants.workModeLabel(m))))
                      .toList(),
                  onChanged: (v) => setState(() => _workMode = v ?? _workMode),
                ),
                const SizedBox(height: 6),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('This is a paid opportunity'),
                  value: _isPaid,
                  onChanged: (v) => setState(() => _isPaid = v),
                ),
                const SizedBox(height: 20),
                BlocConsumer<OpportunityCubit, OpportunityState>(
                  listenWhen: (p, c) => p.isLoading && !c.isLoading && c.errorMessage == null,
                  listener: (context, state) => Navigator.of(context).pop(),
                  builder: (context, state) {
                    return PrimaryButton(
                      label: 'Publish Opportunity',
                      isLoading: state.isLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final opportunity = Opportunity(
                            id: '',
                            startupId: widget.startup.id,
                            startupName: widget.startup.name,
                            startupLogoUrl: widget.startup.logoUrl,
                            title: _title.text.trim(),
                            category: _category,
                            description: _description.text.trim(),
                            requiredSkills: _skillsController.text
                                .split(',')
                                .map((s) => s.trim())
                                .where((s) => s.isNotEmpty)
                                .toList(),
                            workMode: _workMode,
                            duration: _duration.text.trim(),
                            isPaid: _isPaid,
                            postedAt: DateTime.now(),
                          );
                          context.read<OpportunityCubit>().postOpportunity(opportunity);
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
