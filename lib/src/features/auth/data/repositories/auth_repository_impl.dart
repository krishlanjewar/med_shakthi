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
    await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      queryParams: {'prompt': 'select_account'},
    );
    return AuthResponse();
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
