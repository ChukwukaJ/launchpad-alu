import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/theme.dart';
import '../data/models/opportunity_model.dart';

class OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  final double? matchScore; // 0.0–1.0, null hides the badge
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    this.matchScore,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: opportunity.startupLogoUrl != null
                        ? NetworkImage(opportunity.startupLogoUrl!)
                        : null,
                    child: opportunity.startupLogoUrl == null
                        ? Text(
                            opportunity.startupName.isNotEmpty
                                ? opportunity.startupName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                color: AppColors.primary, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opportunity.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700)),
                        Text(opportunity.startupName,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onBookmarkTap,
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? AppColors.accent : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(opportunity.category)),
                  Chip(label: Text(AppConstants.workModeLabel(opportunity.workMode))),
                  Chip(label: Text(opportunity.duration)),
                  if (opportunity.isPaid)
                    const Chip(
                      label: Text('Paid'),
                      backgroundColor: Color(0xFFE3F5EB),
                      labelStyle: TextStyle(color: AppColors.success),
                    ),
                  if (matchScore != null && matchScore! > 0)
                    Chip(
                      label: Text('${(matchScore! * 100).round()}% match'),
                      backgroundColor: const Color(0xFFFFF1DC),
                      labelStyle: const TextStyle(color: Color(0xFFB6790C)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.people_alt_outlined, size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('${opportunity.applicantCount} applicants',
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
