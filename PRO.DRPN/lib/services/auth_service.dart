import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shiksha_darpan/models/user_model.dart';
import 'package:shiksha_darpan/services/database_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Custom exception types so the login screen can show precise error messages.
// ─────────────────────────────────────────────────────────────────────────────
class AccountNotRegisteredException implements Exception {
  final String message;
  const AccountNotRegisteredException(this.message);
  @override
  String toString() => message;
}

class AccessDeniedException implements Exception {
  final String message;
  const AccessDeniedException(this.message);
  @override
  String toString() => message;
}

// ─────────────────────────────────────────────────────────────────────────────
// AuthService
// ─────────────────────────────────────────────────────────────────────────────
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _db = DatabaseService();

  // ---------------------------------------------------------------------------
  // Reactive auth state stream (used by wrappers / route guards).
  // ---------------------------------------------------------------------------
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentFirebaseUser => _auth.currentUser;

  // ---------------------------------------------------------------------------
  // CORE: Google Sign-In with category-level enforcement.
  //
  // Flow:
  //  1. Trigger Google OAuth.
  //  2. Look up user by UID (returning user).
  //  3. If not found by UID → look up by email (first-time Google login for a
  //     pre-registered stub account), then migrate the stub to a UID doc.
  //  4. If still not found → throw AccountNotRegisteredException.
  //  5. Compare the user's Firestore `level` with the `selectedLevel` the user
  //     chose on the login screen.  Mismatch → throw AccessDeniedException.
  //  6. Return the verified UserModel.
  //
  // NOTE: Firebase handles its own ID-token refresh cycle automatically, so we
  // do not need to manage JWT storage manually in a Flutter + Firestore app.
  // ---------------------------------------------------------------------------
  Future<UserModel?> signInWithGoogleForCategory(
    AdministrativeLevel selectedLevel,
  ) async {
    UserCredential? credential;

    try {
      // ── Step 1: Google OAuth ──────────────────────────────────────────────
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        credential = await _auth.signInWithPopup(provider);
      } else {
        final googleSignIn = GoogleSignIn();
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) return null; // user cancelled

        final googleAuth = await googleUser.authentication;
        final oauthCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        credential = await _auth.signInWithCredential(oauthCredential);
      }

      if (credential.user == null) return null;
      final firebaseUser = credential.user!;
      final email = (firebaseUser.email ?? '').toLowerCase().trim();

      // ── Step 2: Lookup by UID ─────────────────────────────────────────────
      UserModel? profile = await _db.getUserProfile(firebaseUser.uid);

      // ── Step 3: First-time Google login for a pre-registered user ─────────
      if (profile == null && email.isNotEmpty) {
        final stubProfile = await _db.getUserProfileByEmail(email);

        if (stubProfile != null) {
          // Migrate the pre-registered stub to a full UID-keyed Firestore doc.
          await _db.linkGoogleAccount(
            email: email,
            newUid: firebaseUser.uid,
            photoUrl: firebaseUser.photoURL,
            displayName: firebaseUser.displayName,
          );
          // Re-fetch the now-migrated profile by UID.
          profile = await _db.getUserProfile(firebaseUser.uid);
        }
      }

      // ── Step 4: Account not in the system at all ──────────────────────────
      if (profile == null) {
        // Sign out so the Firebase session is not left open.
        await _signOutQuietly();
        throw AccountNotRegisteredException(
          'Your Google account ($email) is not registered in ShikshaDarpan.\n'
          'Please contact your administrator to get access.',
        );
      }

      // ── Step 5: Role-level enforcement ────────────────────────────────────
      if (profile.level != selectedLevel) {
        await _signOutQuietly();
        throw AccessDeniedException(
          'Your account is registered under the '
          '${_levelDisplayName(profile.level)} portal.\n'
          'You cannot access the ${_levelDisplayName(selectedLevel)} portal.\n\n'
          'Please select the correct category and try again.',
        );
      }

      // ── Step 6: All checks passed ─────────────────────────────────────────
      return profile;
    } on AccountNotRegisteredException {
      rethrow;
    } on AccessDeniedException {
      rethrow;
    } catch (e) {
      await _signOutQuietly();
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Sign out from both Firebase and Google.
  // ---------------------------------------------------------------------------
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await GoogleSignIn().signOut();
      }
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign-out failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Internal: silent sign-out used after access is denied.
  // ---------------------------------------------------------------------------
  Future<void> _signOutQuietly() async {
    try {
      if (!kIsWeb) await GoogleSignIn().signOut();
      await _auth.signOut();
    } catch (_) {
      // Swallow errors — this is a best-effort cleanup.
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  String _levelDisplayName(AdministrativeLevel level) {
    switch (level) {
      case AdministrativeLevel.ground:
        return 'Ground Level (School & Community)';
      case AdministrativeLevel.intermediate:
        return 'Block / District Level';
      case AdministrativeLevel.state:
        return 'State Level';
      case AdministrativeLevel.national:
        return 'National Level';
    }
  }
}
