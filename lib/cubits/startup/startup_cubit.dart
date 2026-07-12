import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/startup_model.dart';
import '../../data/repositories/startup_repository.dart';

part 'startup_state.dart';

class StartupCubit extends Cubit<StartupState> {
  final StartupRepository _repository;
  StreamSubscription<Startup?>? _myStartupSub;
  StreamSubscription<List<Startup>>? _verifiedSub;
  StreamSubscription<List<Startup>>? _pendingSub;

  StartupCubit({StartupRepository? repository})
      : _repository = repository ?? StartupRepository(),
        super(const StartupState());

  void watchMyStartup(String ownerUid) {
    _myStartupSub?.cancel();
    _myStartupSub = _repository.watchStartupByOwner(ownerUid).listen((startup) {
      emit(state.copyWith(myStartup: startup));
    });
  }

  void watchDiscoveryFeed() {
    _verifiedSub?.cancel();
    _verifiedSub = _repository.watchVerifiedStartups().listen((list) {
      emit(state.copyWith(verifiedStartups: list));
    });
  }

  /// Admin-only stream of startups awaiting verification.
  void watchAdminQueue() {
    _pendingSub?.cancel();
    _pendingSub = _repository.watchPendingStartups().listen((list) {
      emit(state.copyWith(pendingStartups: list));
    });
  }

  Future<void> registerStartup(Startup startup) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.createStartup(startup);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> updateStartup(Startup startup) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.updateStartup(startup);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> approve(String startupId) =>
      _repository.setVerificationStatus(startupId, VerificationStatus.verified);

  Future<void> reject(String startupId) =>
      _repository.setVerificationStatus(startupId, VerificationStatus.rejected);

  @override
  Future<void> close() {
    _myStartupSub?.cancel();
    _verifiedSub?.cancel();
    _pendingSub?.cancel();
    return super.close();
  }
}
