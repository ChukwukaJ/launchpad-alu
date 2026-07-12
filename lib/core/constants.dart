import '../data/models/opportunity_model.dart';

class AppConstants {
  static const List<String> opportunityCategories = [
    'Software Development',
    'Design',
    'Marketing',
    'Operations',
    'Research',
    'Business Analysis',
    'Content Creation',
    'Community Management',
  ];

  static const List<String> industries = [
    'Fintech',
    'EdTech',
    'HealthTech',
    'AgriTech',
    'E-commerce',
    'Media & Creative',
    'Logistics',
    'Social Impact',
    'Other',
  ];

  static String workModeLabel(WorkMode mode) {
    switch (mode) {
      case WorkMode.remote:
        return 'Remote';
      case WorkMode.onsite:
        return 'On-site';
      case WorkMode.hybrid:
        return 'Hybrid';
    }
  }
}
