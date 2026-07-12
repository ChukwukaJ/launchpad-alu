part of 'startup_cubit.dart';

class StartupState extends Equatable {
  final Startup? myStartup;
  final List<Startup> verifiedStartups;
  final List<Startup> pendingStartups; // admin view
  final bool isLoading;
  final String? errorMessage;

  const StartupState({
    this.myStartup,
    this.verifiedStartups = const [],
    this.pendingStartups = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  StartupState copyWith({
    Startup? myStartup,
    List<Startup>? verifiedStartups,
    List<Startup>? pendingStartups,
    bool? isLoading,
    String? errorMessage,
  }) {
    return StartupState(
      myStartup: myStartup ?? this.myStartup,
      verifiedStartups: verifiedStartups ?? this.verifiedStartups,
      pendingStartups: pendingStartups ?? this.pendingStartups,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [myStartup, verifiedStartups, pendingStartups, isLoading, errorMessage];
}
