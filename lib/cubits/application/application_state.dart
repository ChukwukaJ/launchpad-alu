part of 'application_cubit.dart';

class ApplicationState extends Equatable {
  final List<Application> myApplications; // student view
  final List<Application> receivedApplications; // startup view
  final bool isSubmitting;
  final String? errorMessage;

  const ApplicationState({
    this.myApplications = const [],
    this.receivedApplications = const [],
    this.isSubmitting = false,
    this.errorMessage,
  });

  ApplicationState copyWith({
    List<Application>? myApplications,
    List<Application>? receivedApplications,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return ApplicationState(
      myApplications: myApplications ?? this.myApplications,
      receivedApplications: receivedApplications ?? this.receivedApplications,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [myApplications, receivedApplications, isSubmitting, errorMessage];
}
