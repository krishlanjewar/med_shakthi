import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final SupabaseClient _supabase;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl(this._supabase)
      : _googleSignIn = GoogleSignIn(
          serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
        );

  @override
  User? get currentUser => _supabase.auth.currentUser;

  @override
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthResponse> signInWithGoogle() async {
    // Explicitly sign out from the plugin to force the account picker
    await _googleSignIn.signOut();
    
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw const AuthException('Google Sign-In was cancelled');
    }

    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw const AuthException('No ID Token found.');
    }

    return await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _supabase.auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<Map<String, dynamic>?> getSupplierData(String userId) async {
    return await _supabase
        .from('suppliers')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
  }
}
