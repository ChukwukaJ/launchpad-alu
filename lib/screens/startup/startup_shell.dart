import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme.dart';
import '../../cubits/application/application_cubit.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/opportunity/opportunity_cubit.dart';
import '../../cubits/startup/startup_cubit.dart';
import 'startup_postings_screen.dart';
import 'startup_applicants_screen.dart';
import 'startup_analytics_screen.dart';
import 'startup_profile_screen.dart';

class StartupShell extends StatefulWidget {
  const StartupShell({super.key});

  @override
  State<StartupShell> createState() => _StartupShellState();
}

class _StartupShellState extends State<StartupShell> {
  int _index = 0;
  String? _subscribedStartupId;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthCubit>().state.user!.uid;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => StartupCubit()..watchMyStartup(uid)),
        BlocProvider(create: (_) => OpportunityCubit()),
        BlocProvider(create: (_) => ApplicationCubit()),
      ],
      child: BlocBuilder<StartupCubit, StartupState>(
        builder: (context, startupState) {
          final startup = startupState.myStartup;
          // First frame(s) before the stream resolves — keep it snappy.
          if (startup == null) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          // Kick off dependent streams exactly once per resolved startup id
          // (not on every rebuild) — deferred a frame so it runs outside build.
          if (_subscribedStartupId != startup.id) {
            _subscribedStartupId = startup.id;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              context.read<OpportunityCubit>().watchMyPostings(startup.id);
              context.read<ApplicationCubit>().watchReceivedApplications(startup.id);
            });
          }

          return Scaffold(
            body: IndexedStack(
              index: _index,
              children: [
                StartupPostingsScreen(startup: startup),
                StartupApplicantsScreen(startup: startup),
                StartupAnalyticsScreen(startup: startup),
                const StartupProfileScreen(),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              backgroundColor: Colors.white,
              indicatorColor: AppColors.primary.withOpacity(0.12),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work), label: 'Postings'),
                NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Applicants'),
                NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Insights'),
                NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Startup'),
              ],
            ),
          );
        },
      ),
    );
  }
}
