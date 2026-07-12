import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/bookmark/bookmark_cubit.dart';
import '../../cubits/opportunity/opportunity_cubit.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/opportunity_card.dart';
import 'opportunity_detail_screen.dart';

class StudentBookmarksScreen extends StatelessWidget {
  const StudentBookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentSkills = context.watch<AuthCubit>().state.user?.skills ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Opportunities')),
      body: BlocBuilder<BookmarkCubit, BookmarkState>(
        builder: (context, bookmarkState) {
          return BlocBuilder<OpportunityCubit, OpportunityState>(
            builder: (context, oppState) {
              final saved = oppState.discoveryFeed
                  .where((o) => bookmarkState.isBookmarked(o.id))
                  .toList();

              if (saved.isEmpty) {
                return const EmptyState(
                  icon: Icons.bookmark_border_rounded,
                  title: 'Nothing saved yet',
                  subtitle: 'Tap the bookmark icon on any opportunity to save it for later.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: saved.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final opp = saved[i];
                  return OpportunityCard(
                    opportunity: opp,
                    matchScore: opp.matchScore(studentSkills),
                    isBookmarked: true,
                    onBookmarkTap: () => context.read<BookmarkCubit>().toggle(opp.id),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => OpportunityDetailScreen(opportunity: opp)),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
