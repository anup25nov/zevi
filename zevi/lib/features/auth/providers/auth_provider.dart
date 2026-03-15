import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';

class AuthState {
  final bool isLoading;
  final bool isSignedIn;
  final GoogleSignInAccount? user;
  final String? error;

  AuthState({
    required this.isLoading,
    required this.isSignedIn,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isSignedIn,
    GoogleSignInAccount? user,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) 
      : super(AuthState(isLoading: false, isSignedIn: false)) {
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    final signedIn = await _authService.isSignedIn();
    if (signedIn) {
      state = state.copyWith(isSignedIn: true);
    }
  }

  Future<void> signIn() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      // Simulating a minor network delay for UI testing purposes
      await Future.delayed(const Duration(milliseconds: 800));
      
      final account = await _authService.signIn();
      
      if (account != null) {
        state = state.copyWith(isLoading: false, isSignedIn: true, user: account);
      } else {
        state = state.copyWith(isLoading: false, error: 'Sign in aborted by user.');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = AuthState(isLoading: false, isSignedIn: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
