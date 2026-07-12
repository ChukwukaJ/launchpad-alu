import 'package:flutter/material.dart';
import '../data/models/opportunity_model.dart';

/// Bigger, gradient-backed card used only in the Home screen's "Recommended"
/// carousel — visually distinct from the plain white OpportunityCard used
/// everywhere else, so the single best match actually stands out.
class FeaturedOpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;

  const FeaturedOpportunityCard({
    super.key,
    required this.opportunity,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5B45C7), Color(0xFFB07AE0), Color(0xFFF4A93A)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                InkWell(
                  onTap: onBookmarkTap,
                  child: Icon(
                    isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              opportunity.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17),
            ),
            const SizedBox(height: 4),
            Text(opportunity.startupName,
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: opportunity.requiredSkills.take(3).map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 11.5)),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.schedule_rounded, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(opportunity.duration, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const Spacer(),
                Text('Posted recently', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
