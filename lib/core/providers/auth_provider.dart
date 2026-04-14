import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planzy/core/services/firebase_auth_service.dart';

/// Provider for FirebaseAuth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Provider for FirebaseAuthService
final authServiceProvider = Provider<FirebaseAuthService>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthService(auth);
});

/// Stream provider for auth state changes
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

/// Notifier provider for current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateChangesProvider).when(
        data: (user) => user,
        loading: () => null,
        error: (_, _) => null,
      );
});

/// State notifier for authentication operations
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final FirebaseAuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((user) {
      state = AsyncValue.data(user);
    });
  }

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    final result = await _authService.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );

    if (result.success) {
      state = AsyncValue.data(result.user);
    } else {
      state = AsyncValue.error(result.errorMessage ?? 'Sign up failed', StackTrace.current);
    }

    return result;
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (result.success) {
      state = AsyncValue.data(result.user);
    } else {
      state = AsyncValue.error(result.errorMessage ?? 'Sign in failed', StackTrace.current);
    }

    return result;
  }

  Future<AuthResult> signOut() async {
    final result = await _authService.signOut();
    if (result.success) {
      state = const AsyncValue.data(null);
    }
    return result;
  }

  Future<AuthResult> sendPasswordReset(String email) async {
    return _authService.sendPasswordResetEmail(email);
  }

  Future<AuthResult> deleteAccount() async {
    final result = await _authService.deleteAccount();
    if (result.success) {
      state = const AsyncValue.data(null);
    }
    return result;
  }
}

/// Provider for AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

/// Provider to check if initial auth check is complete
final authCheckCompleteProvider = Provider<bool>((ref) {
  return ref.watch(authStateChangesProvider).when(
        data: (_) => true,
        loading: () => false,
        error: (error, stack) => true,
      );
});