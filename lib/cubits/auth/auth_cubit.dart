import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_state.dart';

/// This is the Cubit the demo should lean on to show real-time state
/// propagation: it subscribes to `FirebaseAuth.authStateChanges()`, so
/// signing in/out in the Firebase Console (or another device) updates the
/// UI here automatically, without any manual refresh call.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<fb.User?>? _authSub;

  AuthCubit({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(const AuthState()) {
    _authSub = _authRepository.authStateChanges.listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(fb.User? firebaseUser) async {
    if (firebaseUser == null) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
      return;
    }
    try {
      final profile = await _authRepository.fetchUserProfile(firebaseUser.uid);
      emit(state.copyWith(status: AuthStatus.authenticated, user: profile));
    } catch (_) {
      // Profile doc not written yet (e.g. mid-signup race) — treat as signed out.
      emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final user = await _authRepository.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      emit(state.copyWith(
        isLoading: false,
        status: AuthStatus.authenticated,
        user: user,
      ));
    } on fb.FirebaseAuthException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: _mapError(e)));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final user = await _authRepository.signIn(email: email, password: password);
      emit(state.copyWith(
        isLoading: false,
        status: AuthStatus.authenticated,
        user: user,
      ));
    } on fb.FirebaseAuthException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: _mapError(e)));
    }
  }

  Future<void> signOut() => _authRepository.signOut();

  Future<void> completeOnboarding({List<String>? skills, String? bio}) async {
    final current = state.user;
    if (current == null) return;
    final updated = current.copyWith(
      skills: skills,
      bio: bio,
      onboardingComplete: true,
    );
    await _authRepository.updateProfile(updated);
    emit(state.copyWith(user: updated));
  }

  String _mapError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'That email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}
