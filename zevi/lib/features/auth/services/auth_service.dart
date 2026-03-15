import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/gmail.modify',
      'https://www.googleapis.com/auth/contacts.readonly',
      'https://www.googleapis.com/auth/drive.file',
    ],
  );
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> isSignedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }

  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        // Fetch auth details if needed
        // final auth = await account.authentication;
        // final idToken = auth.idToken;
        
        // Mocking the backend call to our API for JWT since we don't have it yet
        final mockJwt = 'mock_jwt_token_for_${account.email}';
        await _storage.write(key: 'auth_token', value: mockJwt);
      }
      return account;
    } catch (error) {
      throw Exception('Google Sign-In failed: $error');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _storage.delete(key: 'auth_token');
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
