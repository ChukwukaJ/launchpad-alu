import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/bookmark/bookmark_cubit.dart';
import '../../cubits/opportunity/opportunity_cubit.dart';
import '../../cubits/search/search_cubit.dart';
import '../../data/models/opportunity_model.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/opportunity_card.dart';
import 'opportunity_detail_screen.dart';
import 'notifications_screen.dart';

class StudentExploreScreen extends StatelessWidget {
  const StudentExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentSkills = context.watch<AuthCubit>().state.user?.skills ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: (v) => context.read<SearchCubit>().setQuery(v),
              decoration: const InputDecoration(
                hintText: 'Search title, startup, or skill…',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          _FilterRow(),
          const SizedBox(height: 4),
          Expanded(
            child: BlocBuilder<OpportunityCubit, OpportunityState>(
              builder: (context, oppState) {
                return BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, searchState) {
                    var results = searchState.apply(oppState.discoveryFeed);
                    if (searchState.category != null) {
                      results = results.where((o) => o.category == searchState.category).toList();
                    }
                    if (searchState.workMode != null) {
                      results = results.where((o) => o.workMode == searchState.workMode).toList();
                    }
                    // Recommendation: surface best skill-matches first when no
                    // active text search, so the "for you" feel comes for free.
                    if (searchState.query.isEmpty) {
                      results.sort((a, b) =>
                          b.matchScore(studentSkills).compareTo(a.matchScore(studentSkills)));
                    }

                    if (results.isEmpty) {
                      return const EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No opportunities found',
                        subtitle: 'Try a different search term or clear your filters.',
                      );
                    }

                    return BlocBuilder<BookmarkCubit, BookmarkState>(
                      builder: (context, bookmarkState) {
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: results.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final opp = results[i];
                            return OpportunityCard(
                              opportunity: opp,
                              matchScore: opp.matchScore(studentSkills),
                              isBookmarked: bookmarkState.isBookmarked(opp.id),
                              onBookmarkTap: () =>
                                  context.read<BookmarkCubit>().toggle(opp.id),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => OpportunityDetailScreen(opportunity: opp),
                                ),
                              ),
                            );
                          },
                        );
                      },
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
}

class _FilterRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final search = context.watch<SearchCubit>().state;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ...AppConstants.opportunityCategories.map((cat) {
            final selected = search.category == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(cat),
                selected: selected,
                onSelected: (v) =>
                    context.read<SearchCubit>().setCategory(v ? cat : null),
              ),
            );
          }),
          const SizedBox(width: 4),
          ...WorkMode.values.map((mode) {
            final selected = search.workMode == mode;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(AppConstants.workModeLabel(mode)),
                selected: selected,
                selectedColor: AppColors.accent.withOpacity(0.25),
                onSelected: (v) =>
                    context.read<SearchCubit>().setWorkMode(v ? mode : null),
              ),
            );
          }),
        ],
      ),
    );
  }
}
