import 'package:supabase_flutter/supabase_flutter.dart';

abstract class IAuthRepository {
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthResponse> signInWithGoogle();

  Future<void> signOut();

  Future<Map<String, dynamic>?> getSupplierData(String userId);

  User? get currentUser;
}
