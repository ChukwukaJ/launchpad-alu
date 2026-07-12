part of 'opportunity_cubit.dart';

class OpportunityState extends Equatable {
  final List<Opportunity> discoveryFeed;
  final List<Opportunity> myPostings; // startup owner view
  final bool isLoading;
  final String? errorMessage;

  const OpportunityState({
    this.discoveryFeed = const [],
    this.myPostings = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  OpportunityState copyWith({
    List<Opportunity>? discoveryFeed,
    List<Opportunity>? myPostings,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OpportunityState(
      discoveryFeed: discoveryFeed ?? this.discoveryFeed,
      myPostings: myPostings ?? this.myPostings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [discoveryFeed, myPostings, isLoading, errorMessage];
}
