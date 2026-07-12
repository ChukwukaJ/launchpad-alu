import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:launchpad_alu/cubits/opportunity/opportunity_cubit.dart';
import 'package:launchpad_alu/data/models/opportunity_model.dart';
import 'package:launchpad_alu/data/repositories/opportunity_repository.dart';

class MockOpportunityRepository extends Mock implements OpportunityRepository {}

void main() {
  late MockOpportunityRepository repository;

  final sample = Opportunity(
    id: '1',
    startupId: 's1',
    startupName: 'Test Startup',
    title: 'Frontend Intern',
    category: 'Software Development',
    description: 'Build UI',
    requiredSkills: const ['Flutter', 'UI/UX Design'],
    workMode: WorkMode.remote,
    duration: '3 months',
    postedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    repository = MockOpportunityRepository();
  });

  group('OpportunityCubit', () {
    blocTest<OpportunityCubit, OpportunityState>(
      'emits discoveryFeed when watchDiscoveryFeed receives data',
      setUp: () {
        when(() => repository.watchOpenOpportunities())
            .thenAnswer((_) => Stream.value([sample]));
      },
      build: () => OpportunityCubit(repository: repository),
      act: (cubit) => cubit.watchDiscoveryFeed(),
      expect: () => [
        isA<OpportunityState>().having(
          (s) => s.discoveryFeed.length,
          'discoveryFeed length',
          1,
        ),
      ],
    );

    blocTest<OpportunityCubit, OpportunityState>(
      'sets errorMessage when postOpportunity throws',
      setUp: () {
        when(() => repository.postOpportunity(any()))
            .thenThrow(Exception('network error'));
      },
      build: () => OpportunityCubit(repository: repository),
      act: (cubit) => cubit.postOpportunity(sample),
      expect: () => [
        isA<OpportunityState>().having((s) => s.isLoading, 'isLoading', true),
        isA<OpportunityState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );
  });

  group('Opportunity.matchScore', () {
    test('returns 1.0 when all required skills match', () {
      expect(sample.matchScore(['Flutter', 'UI/UX Design', 'Python']), 1.0);
    });

    test('returns 0.5 when half the required skills match', () {
      expect(sample.matchScore(['Flutter']), 0.5);
    });

    test('returns 0 when no required skills are set', () {
      final noSkills = Opportunity(
        id: '2',
        startupId: 's1',
        startupName: 'Test Startup',
        title: 'Generic role',
        category: 'Operations',
        description: '...',
        workMode: WorkMode.onsite,
        duration: '1 month',
        postedAt: DateTime(2026, 1, 1),
      );
      expect(noSkills.matchScore(['Flutter']), 0);
    });
  });
}
