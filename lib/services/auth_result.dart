import 'package:firebase_auth/firebase_auth.dart';

class AuthResult {
  final UserCredential? userCredential;
  final String? errorMessage;

  AuthResult({this.userCredential, this.errorMessage});
}
