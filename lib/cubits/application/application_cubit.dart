import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/application_model.dart';
import '../../data/repositories/application_repository.dart';

part 'application_state.dart';

class ApplicationCubit extends Cubit<ApplicationState> {
  final ApplicationRepository _repository;
  StreamSubscription<List<Application>>? _mySub;
  StreamSubscription<List<Application>>? _receivedSub;

  ApplicationCubit({ApplicationRepository? repository})
      : _repository = repository ?? ApplicationRepository(),
        super(const ApplicationState());

  void watchMyApplications(String studentUid) {
    _mySub?.cancel();
    _mySub = _repository
        .watchApplicationsByStudent(studentUid)
        .listen((list) => emit(state.copyWith(myApplications: list)));
  }

  void watchReceivedApplications(String startupId) {
    _receivedSub?.cancel();
    _receivedSub = _repository
        .watchApplicationsForStartup(startupId)
        .listen((list) => emit(state.copyWith(receivedApplications: list)));
  }

  Future<bool> submitApplication(Application application) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await _repository.submitApplication(application);
      emit(state.copyWith(isSubmitting: false));
      return true;
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
      return false;
    }
  }

  Future<void> updateStatus(Application application, ApplicationStatus newStatus) {
    return _repository.updateStatus(application, newStatus);
  }

  @override
  Future<void> close() {
    _mySub?.cancel();
    _receivedSub?.cancel();
    return super.close();
  }
}
