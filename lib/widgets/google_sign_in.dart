import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<UserCredential?> signInWithGoogle() async {
  // Create a new GoogleSignIn object
  final googleSignIn = GoogleSignIn();

  // Attempt to sign in
  final googleUser = await googleSignIn.signIn();

  if (googleUser != null) {
    // Obtain the auth details from the Google user
    final googleAuth = await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
  return null;
}

void signOutGoogle() async {
  await GoogleSignIn().signOut();
  await FirebaseAuth.instance.signOut();
}
