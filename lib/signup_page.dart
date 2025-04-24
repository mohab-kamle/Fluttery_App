import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_at_akira_menai/navigation_page.dart';
import 'package:flutter_at_akira_menai/login_page.dart';
import 'package:flutter_at_akira_menai/providers/theme_provider.dart';
import 'package:flutter_at_akira_menai/widgets/awsome_material_banner.dart';
import 'package:flutter_at_akira_menai/widgets/google_auth.dart';
import 'package:flutter_at_akira_menai/widgets/switch_mode.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: RefreshIndicator(
            onRefresh: () { 
              return Future.delayed(const Duration(seconds: 1), () {
                setState(() {});
              });
            },
            child: SizedBox(
              width: 300,
              child: Column(
                spacing: 20,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                    color: isDarkMode == true
                        ? Colors.white
                        : Colors.black,
                    'assets/images/templyLogoTransparentBg (Medium).png',
                    height: 50,
                    width: 50,
                  ),
                      const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Create an account to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SwitchMode(
                    
                  ),
                  const SizedBox(height: 20),
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
                            helperStyle: const TextStyle(
                              fontSize: 8,
                            ),
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
                                      awesomeMaterialBanner(context: context, title: 'Great !', message: 'account created succesfully', contentType: ContentType.success);
                                      // Navigate to the home page after successful sign-up
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => const NavigationPage(),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  } on FirebaseAuthException catch (e) {
                                    if (context.mounted &&
                                        e.code == 'weak-password') {
                                          awesomeMaterialBanner(context: context, title: 'Sorry', message: 'The password provided is too weak.', contentType: ContentType.warning);
                                    } else if (context.mounted &&
                                        e.code == 'email-already-in-use') {
                                      awesomeMaterialBanner(context: context, title: 'Sorry', message: 'The account already exists for that email.', contentType: ContentType.warning);
                                    }
                                    else{
                                      if(context.mounted){
                                        awesomeMaterialBanner(context: context, title: 'Sorry', message: 'An error occurred: $e', contentType: ContentType.failure);
                                      }
                                      
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      awesomeMaterialBanner(context: context, title: 'Sorry', message: 'An error occurred: $e', contentType: ContentType.failure);
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
                            const Text('Already have an account?',
                            style: TextStyle(
                              fontSize: 12,
                            )),
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
                              child: const Text('Login',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
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
                                awesomeMaterialBanner(context: context, title: 'please try again', message: 'Failed to sign in with google', contentType: ContentType.failure);
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
        ),
      ),
    );
  }
}
