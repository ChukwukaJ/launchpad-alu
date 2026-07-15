import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme.dart';
import '../../cubits/application/application_cubit.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/bookmark/bookmark_cubit.dart';
import '../../cubits/opportunity/opportunity_cubit.dart';
import '../../cubits/search/search_cubit.dart';
import '../../data/models/opportunity_model.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/featured_opportunity_card.dart';
import '../../widgets/opportunity_card.dart';
import 'opportunity_detail_screen.dart';
import 'notifications_screen.dart';

class StudentHomeScreen extends StatelessWidget {
  final void Function(String category) onBrowseCategory;
  const StudentHomeScreen({super.key, required this.onBrowseCategory});

  static const _browseCategories = [
    (label: 'Design', icon: Icons.palette_outlined, category: 'Design'),
    (label: 'Engineering', icon: Icons.code_rounded, category: 'Software Development'),
    (label: 'Marketing', icon: Icons.campaign_outlined, category: 'Marketing'),
    (label: 'Data', icon: Icons.bar_chart_rounded, category: 'Research'),
    (label: 'Other', icon: Icons.apps_rounded, category: ''),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    final studentSkills = user?.skills ?? [];
    final firstName = (user?.fullName ?? '').split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<OpportunityCubit, OpportunityState>(
          builder: (context, oppState) {
            final feed = List<Opportunity>.from(oppState.discoveryFeed)
              ..sort((a, b) => b.matchScore(studentSkills).compareTo(a.matchScore(studentSkills)));
            final recommended = feed.where((o) => o.matchScore(studentSkills) > 0).take(6).toList();
            final recommendedList = recommended.isNotEmpty ? recommended : feed.take(6).toList();
            final recent = feed.take(5).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello, ${firstName.isEmpty ? 'there' : firstName} 👋',
                              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          const Text('Find meaningful ways to contribute.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      ),
                    ),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SearchBarStub(onTap: () => onBrowseCategory('')),
                const SizedBox(height: 22),

                if (recommendedList.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recommended', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      TextButton(onPressed: () => onBrowseCategory(''), child: const Text('See all')),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 210,
                    child: BlocBuilder<BookmarkCubit, BookmarkState>(
                      builder: (context, bookmarkState) {
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: recommendedList.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, i) {
                            final opp = recommendedList[i];
                            return FeaturedOpportunityCard(
                              opportunity: opp,
                              isBookmarked: bookmarkState.isBookmarked(opp.id),
                              onBookmarkTap: () => context.read<BookmarkCubit>().toggle(opp.id),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (routeContext) => BlocProvider.value(
                                    value: context.read<ApplicationCubit>(),
                                    child: OpportunityDetailScreen(opportunity: opp),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 26),
                ],

                const Text('Browse by category', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _browseCategories.map((c) {
                    return _CategoryIcon(
                      label: c.label,
                      icon: c.icon,
                      onTap: () => onBrowseCategory(c.category),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 26),

                const Text('Recent opportunities', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 10),
                if (recent.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: EmptyState(
                      icon: Icons.explore_outlined,
                      title: 'No opportunities yet',
                      subtitle: 'Check back soon — new postings show up here in real time.',
                    ),
                  )
                else
                  BlocBuilder<BookmarkCubit, BookmarkState>(
                    builder: (context, bookmarkState) {
                      return Column(
                        children: recent.map((opp) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: OpportunityCard(
                              opportunity: opp,
                              matchScore: opp.matchScore(studentSkills),
                              isBookmarked: bookmarkState.isBookmarked(opp.id),
                              onBookmarkTap: () => context.read<BookmarkCubit>().toggle(opp.id),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (routeContext) => BlocProvider.value(
                                    value: context.read<ApplicationCubit>(),
                                    child: OpportunityDetailScreen(opportunity: opp),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SearchBarStub extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchBarStub({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE3E0F0)),
        ),
        child: Row(
          children: const [
            Icon(Icons.search, color: AppColors.textSecondary, size: 20),
            SizedBox(width: 10),
            Text('Search opportunities…', style: TextStyle(color: AppColors.textSecondary)),
            Spacer(),
            Icon(Icons.tune_rounded, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _CategoryIcon({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.08),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}