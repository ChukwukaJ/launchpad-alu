import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/opportunity_model.dart';
import '../../data/repositories/opportunity_repository.dart';

part 'opportunity_state.dart';

class OpportunityCubit extends Cubit<OpportunityState> {
  final OpportunityRepository _repository;
  StreamSubscription<List<Opportunity>>? _feedSub;
  StreamSubscription<List<Opportunity>>? _myPostingsSub;

  OpportunityCubit({OpportunityRepository? repository})
      : _repository = repository ?? OpportunityRepository(),
        super(const OpportunityState());

  /// This is the primary stream to demonstrate real-time updates: post a
  /// new opportunity from a startup account and this feed updates on the
  /// student's screen with no manual refresh, because both sides are bound
  /// to the same Firestore snapshot stream.
  void watchDiscoveryFeed({String? category, WorkMode? workMode}) {
    _feedSub?.cancel();
    _feedSub = _repository
        .watchOpenOpportunities(category: category, workMode: workMode)
        .listen((list) => emit(state.copyWith(discoveryFeed: list)));
  }

  void watchMyPostings(String startupId) {
    _myPostingsSub?.cancel();
    _myPostingsSub = _repository
        .watchOpportunitiesByStartup(startupId)
        .listen((list) => emit(state.copyWith(myPostings: list)));
  }

  Future<void> postOpportunity(Opportunity opportunity) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.postOpportunity(opportunity);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> closeOpportunity(String id) => _repository.closeOpportunity(id);
  Future<void> deleteOpportunity(String id) => _repository.deleteOpportunity(id);

  @override
  Future<void> close() {
    _feedSub?.cancel();
    _myPostingsSub?.cancel();
    return super.close();
  }
}
