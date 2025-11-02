import 'package:lavajato/services/auth_result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lavajato/models/client_model.dart';
import 'package:lavajato/services/firestore_service.dart';
import 'package:lavajato/services/notification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  // Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();

      if (googleUser == null) {
        // The user canceled the sign-in
        return AuthResult(errorMessage: 'Login com Google cancelado.');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential for Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: (googleAuth as dynamic).accessToken,
        idToken: (googleAuth as dynamic).idToken,
      );

      // Once signed in, return the UserCredential
      final userCredential = await _auth.signInWithCredential(credential);
      return AuthResult(userCredential: userCredential);
    } on FirebaseAuthException catch (e) {
      return AuthResult(errorMessage: e.message);
    } catch (e) {
      return AuthResult(errorMessage: 'Ocorreu um erro desconhecido.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
      await _auth.signOut();
    } catch (e) {
      // Handle errors appropriately
    }
  }

  // Sign up with email and password
  Future<AuthResult> signUpWithEmailPassword(
      String name, String email, String phone, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        await _firestoreService.addUser(
            userCredential.user!.uid, name, email, phone, rule: 'usuario');
        final client = Client(
          uid: userCredential.user!.uid,
          name: name,
          email: email,
          phone: phone,
        );
        await _notificationService.sendRegistrationConfirmation(client);
      }
      return AuthResult(userCredential: userCredential);
    } on FirebaseAuthException catch (e) {
      return AuthResult(errorMessage: e.message);
    } catch (e) {
      return AuthResult(errorMessage: 'Ocorreu um erro desconhecido.');
    }
  }



  // Sign in with email and password
  Future<AuthResult> signInWithEmailPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult(userCredential: userCredential);
    } on FirebaseAuthException catch (e) {
      return AuthResult(errorMessage: e.message);
    } catch (e) {
      return AuthResult(errorMessage: 'Ocorreu um erro desconhecido.');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      // Handle errors appropriately
    }
  }
}
