import 'package:flutter/material.dart';
import 'package:flutter_at_akira_menai/navigation_page.dart';
import 'package:flutter_at_akira_menai/login_page.dart';
import 'package:flutter_at_akira_menai/widgets/google_auth.dart';
import 'package:flutter_at_akira_menai/widgets/switch_mode.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordValidationResult {
  final bool isValid;
  final String? errorMessage;

  const PasswordValidationResult({required this.isValid, this.errorMessage});
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isSubmitting = false;
  bool passwordHidden = true;
  String _email = '';
  String _currentPassword = '';
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  void togglePasswordVisibility() {
    setState(() {
      passwordHidden = !passwordHidden;
    });
  }

  PasswordValidationResult _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return const PasswordValidationResult(
        isValid: false,
        errorMessage: 'Please enter your password',
      );
    }

    if (value.length < 8) {
      return const PasswordValidationResult(
        isValid: false,
        errorMessage: 'Password must be at least 8 characters long',
      );
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return const PasswordValidationResult(
        isValid: false,
        errorMessage: 'Password must contain at least one uppercase letter',
      );
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return const PasswordValidationResult(
        isValid: false,
        errorMessage: 'Password must contain at least one lowercase letter',
      );
    }

    return const PasswordValidationResult(isValid: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SwitchMode(
                
              ),
              const SizedBox(height: 50),
              Form(
                key: _formKey,
                child: Column(
                  spacing: 30,
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        // Email validation regex pattern
                        final emailRegExp = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegExp.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _email = value;
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        labelText: 'Enter your email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    TextFormField(
                      obscureText: passwordHidden,
                      validator: (value) {
                        final validationResult = _validatePassword(value);
                        if (!validationResult.isValid) {
                          return validationResult.errorMessage;
                        }
                        _currentPassword = value!;
                        return null;
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.password),
                        labelText: 'Enter your password',
                        border: const OutlineInputBorder(),
                        helperText:
                            'Minimum 8 characters, 1 uppercase, 1 lowercase',
                        suffixIcon: IconButton(
                          icon: Icon(
                            passwordHidden
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: togglePasswordVisibility,
                        ),
                      ),
                    ),
                    TextFormField(
                      obscureText: passwordHidden,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _currentPassword) {
                          return 'Passwords do not match';
                        }

                        return null;
                      },
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline),
                        labelText: 'Confirm your password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    _isSubmitting
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: () async {
                            if (_isSubmitting) {
                              return; // Prevent multiple presses
                            }
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isSubmitting = true);

                              try {
                                final credential = await auth
                                    .createUserWithEmailAndPassword(
                                      email: _email,
                                      password: _currentPassword,
                                    );
                                if (context.mounted &&
                                    credential.user != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Account created successfully!',
                                      ),
                                    ),
                                  );
                                  // Navigate to the home page after successful sign-up
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const NavigationPage(),
                                    ),
                                  );
                                }
                              } on FirebaseAuthException catch (e) {
                                if (context.mounted &&
                                    e.code == 'weak-password') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'The password provided is too weak.',
                                      ),
                                    ),
                                  );
                                } else if (context.mounted &&
                                    e.code == 'email-already-in-use') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'The account already exists for that email.',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('An error occurred: $e'),
                                    ),
                                  );
                                }
                              } finally {
                                setState(() => _isSubmitting = false);
                              }
                            }
                          },
                          child: const Text('Sign Up'),
                        ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?'),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => LoginPage(
                                      
                                    ),
                              ),
                            );
                          },
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        signInWithGoogle().then((value) {
                          if (value != null) {
                            if (!context.mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const NavigationPage(),
                              ),
                            );
                          } else {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to sign in with Google'),
                              ),
                            );
                          }
                        });
                      },
                      icon: Image.asset(
                        'assets/images/Google-Symbol.png',
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
