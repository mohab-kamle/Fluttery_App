import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_at_akira_menai/widgets/google_auth.dart';

Future<void> signOutUser() async {
  final user = FirebaseAuth.instance.currentUser;
  int test = 0;

  if (user != null) {
    for (final provider in user.providerData) {
      if (provider.providerId == 'google.com') {
        signOutGoogle();
        test++;
        break;
      }
    }
  }
  if (test == 0) {
    await FirebaseAuth.instance.signOut();
  }
}
