import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme.dart';
import '../../cubits/application/application_cubit.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/bookmark/bookmark_cubit.dart';
import '../../cubits/opportunity/opportunity_cubit.dart';
import '../../cubits/search/search_cubit.dart';
import 'student_home_screen.dart';
import 'student_explore_screen.dart';
import 'student_applications_screen.dart';
import 'student_profile_screen.dart';

/// Nav structure mirrors the assignment's sample UI: Home (curated) / Explore
/// (search+filter) / Applications (status tabs) / Profile (stats + menu).
/// Saved Opportunities and Notifications move from top-level tabs into the
/// Profile menu, matching the sample exactly.
class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;

  void _goToExplore(String category) {
    setState(() => _index = 1);
    // Deferred so SearchCubit exists in the tree by the time this runs.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SearchCubit>().setCategory(category.isEmpty ? null : category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthCubit>().state.user!.uid;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => OpportunityCubit()..watchDiscoveryFeed()),
        BlocProvider(create: (_) => SearchCubit()),
        BlocProvider(create: (_) => BookmarkCubit(uid: uid)),
        BlocProvider(create: (_) => ApplicationCubit()..watchMyApplications(uid)),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            StudentHomeScreen(onBrowseCategory: _goToExplore),
            const StudentExploreScreen(),
            const StudentApplicationsScreen(),
            const StudentProfileScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primary.withOpacity(0.12),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
            NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: 'Applications'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
