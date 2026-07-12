import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/startup/startup_cubit.dart';
import '../../data/models/startup_model.dart';
import '../../data/models/user_model.dart';
import '../../widgets/common_widgets.dart';
import '../student/student_shell.dart';
import '../startup/startup_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // student fields
  final Set<String> _selectedSkills = {};
  final _bioController = TextEditingController();

  // startup fields
  final _startupName = TextEditingController();
  final _tagline = TextEditingController();
  final _description = TextEditingController();
  String _industry = AppConstants.industries.first;
  final _teamSize = TextEditingController(text: '1');

  static const _skillPool = [
    'Flutter', 'React', 'UI/UX Design', 'Copywriting', 'Video Editing',
    'Data Analysis', 'Social Media', 'Python', 'Node.js', 'Product Management',
    'Graphic Design', 'Sales', 'Market Research', 'Public Speaking',
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user!;
    final isStudent = user.role == UserRole.student;

    return Scaffold(
      appBar: AppBar(title: const Text('One last step')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: isStudent ? _studentOnboarding(context, user) : _startupOnboarding(context, user),
        ),
      ),
    );
  }

  Widget _studentOnboarding(BuildContext context, AppUser user) {
    return ListView(
      children: [
        Text('What are your skills?', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        const Text('Pick a few — this powers your match score on opportunities.',
            style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _skillPool.map((skill) {
            final selected = _selectedSkills.contains(skill);
            return FilterChip(
              label: Text(skill),
              selected: selected,
              onSelected: (v) => setState(
                  () => v ? _selectedSkills.add(skill) : _selectedSkills.remove(skill)),
              selectedColor: AppColors.primary.withOpacity(0.15),
              checkmarkColor: AppColors.primary,
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        AppTextField(label: 'Short bio (optional)', controller: _bioController, maxLines: 3),
        const SizedBox(height: 28),
        PrimaryButton(
          label: 'Get Started',
          onPressed: () async {
            await context.read<AuthCubit>().completeOnboarding(
                  skills: _selectedSkills.toList(),
                  bio: _bioController.text.trim(),
                );
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const StudentShell()),
                (_) => false,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _startupOnboarding(BuildContext context, AppUser user) {
    return ListView(
      children: [
        Text('Register your startup', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        const Text('An ALU admin reviews new startups before they can post publicly.',
            style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        AppTextField(label: 'Startup name', controller: _startupName),
        const SizedBox(height: 14),
        AppTextField(label: 'Tagline', controller: _tagline),
        const SizedBox(height: 14),
        AppTextField(label: 'Description', controller: _description, maxLines: 4),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          value: _industry,
          decoration: const InputDecoration(labelText: 'Industry'),
          items: AppConstants.industries
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: (v) => setState(() => _industry = v ?? _industry),
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: 'Team size',
          controller: _teamSize,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 28),
        BlocConsumer<StartupCubit, StartupState>(
          listener: (context, state) {},
          builder: (context, state) {
            return PrimaryButton(
              label: 'Submit for Verification',
              isLoading: state.isLoading,
              onPressed: () async {
                final startup = Startup(
                  id: '',
                  ownerUid: user.uid,
                  name: _startupName.text.trim(),
                  tagline: _tagline.text.trim(),
                  description: _description.text.trim(),
                  industry: _industry,
                  teamSize: int.tryParse(_teamSize.text.trim()) ?? 1,
                  status: VerificationStatus.pending,
                  createdAt: DateTime.now(),
                );
                await context.read<StartupCubit>().registerStartup(startup);
                await context.read<AuthCubit>().completeOnboarding();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const StartupShell()),
                    (_) => false,
                  );
                }
              },
            );
          },
        ),
      ],
    );
  }
}
