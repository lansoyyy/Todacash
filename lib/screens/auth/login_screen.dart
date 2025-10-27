import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:phara/screens/auth/signup_screen.dart';
import 'package:phara/screens/splashtohome_screen.dart';
import 'package:phara/utils/colors.dart';
import 'package:phara/widgets/button_widget.dart';
import 'package:phara/widgets/text_widget.dart';
import 'package:phara/widgets/textfield_widget.dart';
import 'package:phara/widgets/toast_widget.dart';

class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey,
      body: Form(
        key: _formKey,
        child: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/back.png'),
                  fit: BoxFit.cover)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 50, 30, 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  TextBold(text: 'Todacash', fontSize: 58, color: Colors.white),
                  const SizedBox(
                    height: 75,
                  ),
                  TextRegular(text: 'Login', fontSize: 24, color: Colors.white),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFieldWidget(
                    textCapitalization: TextCapitalization.none,
                    hint: 'Email',
                    label: 'Email',
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email address';
                      }
                      final emailRegex =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      TextFieldWidget(
                        textCapitalization: TextCapitalization.none,
                        showEye: true,
                        isObscure: true,
                        hint: 'Password',
                        label: 'Password',
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters long';
                          }

                          return null;
                        },
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: ((context) {
                                final formKey = GlobalKey<FormState>();
                                final TextEditingController emailController =
                                    TextEditingController();

                                return AlertDialog(
                                  backgroundColor: Colors.grey[100],
                                  title: TextRegular(
                                    text: 'Forgot Password',
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  content: Form(
                                    key: formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextFieldWidget(
                                          hint: 'Email',
                                          textCapitalization:
                                              TextCapitalization.none,
                                          inputType: TextInputType.emailAddress,
                                          label: 'Email',
                                          controller: emailController,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter an email address';
                                            }
                                            final emailRegex = RegExp(
                                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                            if (!emailRegex.hasMatch(value)) {
                                              return 'Please enter a valid email address';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: (() {
                                        Navigator.pop(context);
                                      }),
                                      child: TextRegular(
                                        text: 'Cancel',
                                        fontSize: 12,
                                        color: grey,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: (() async {
                                        if (formKey.currentState!.validate()) {
                                          try {
                                            Navigator.pop(context);
                                            await FirebaseAuth.instance
                                                .sendPasswordResetEmail(
                                                    email:
                                                        emailController.text);
                                            showToast(
                                                'Password reset link sent to ${emailController.text}');
                                          } catch (e) {
                                            String errorMessage = '';

                                            if (e is FirebaseException) {
                                              switch (e.code) {
                                                case 'invalid-email':
                                                  errorMessage =
                                                      'The email address is invalid.';
                                                  break;
                                                case 'user-not-found':
                                                  errorMessage =
                                                      'The user associated with the email address is not found.';
                                                  break;
                                                default:
                                                  errorMessage =
                                                      'An error occurred while resetting the password.';
                                              }
                                            } else {
                                              errorMessage =
                                                  'An error occurred while resetting the password.';
                                            }

                                            showToast(errorMessage);
                                            Navigator.pop(context);
                                          }
                                        }
                                      }),
                                      child: TextBold(
                                        text: 'Continue',
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            );
                          },
                          child: TextRegular(
                              text: 'Forgot Password?',
                              fontSize: 12,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: ButtonWidget(
                      color: black,
                      label: 'Login',
                      onPressed: (() {
                        if (_formKey.currentState!.validate()) {
                          login(context);
                        }
                      }),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextRegular(
                          text: "New to Todacash?",
                          fontSize: 12,
                          color: Colors.white),
                      TextButton(
                        onPressed: (() {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const SignupScreen()));
                        }),
                        child: TextBold(
                            text: "Signup Now",
                            fontSize: 14,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  final box = GetStorage();

  login(context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

      // Check if email is verified
      if (!userCredential.user!.emailVerified) {
        // Show email verification dialog
        _showEmailVerificationDialog(context, userCredential.user!);
        return;
      }

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SplashToHomeScreen()));
      box.write('shown', false);
      box.write('shownDeliver', false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showToast("No user found with that email.");
      } else if (e.code == 'wrong-password') {
        showToast("Wrong password provided for that user.");
      } else if (e.code == 'invalid-email') {
        showToast("Invalid email provided.");
      } else if (e.code == 'user-disabled') {
        showToast("User account has been disabled.");
      } else {
        showToast("An error occurred: ${e.message}");
      }
    } on Exception catch (e) {
      showToast("An error occurred: $e");
    }
  }

  void _showEmailVerificationDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Icon(Icons.email_outlined, color: Colors.orange, size: 28),
                const SizedBox(width: 10),
                TextBold(
                    text: 'Email Verification Required',
                    fontSize: 18,
                    color: black),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextRegular(
                  text:
                      'Your email address needs to be verified before you can login.',
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(height: 5),
                TextBold(
                  text: user.email!,
                  fontSize: 16,
                  color: black,
                ),
                const SizedBox(height: 15),
                TextRegular(
                  text:
                      'Please check your inbox and click on the verification link we sent you.',
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
                const SizedBox(height: 15),
                TextRegular(
                  text: 'Didn\'t receive the email?',
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    await user.sendEmailVerification();
                    showToast('Verification email resent!');
                  } catch (e) {
                    showToast('Failed to resend email: $e');
                  }
                },
                child: TextBold(
                  text: 'Resend Email',
                  fontSize: 14,
                  color: Colors.blue,
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _checkEmailVerification(user, context);
                },
                child: TextBold(
                  text: 'I\'ve Verified',
                  fontSize: 14,
                  color: Colors.green,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  FirebaseAuth.instance.signOut();
                },
                child: TextBold(
                  text: 'Back to Login',
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _checkEmailVerification(User user, BuildContext context) async {
    try {
      // Reload user to get updated verification status
      await user.reload();
      User? refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser != null && refreshedUser.emailVerified) {
        showToast('Email verified successfully!');

        // Navigate to home screen
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const SplashToHomeScreen()));

        box.write('shown', false);
        box.write('shownDeliver', false);
      } else {
        showToast(
            'Email not verified yet. Please check your email and try again.');
        _showEmailVerificationDialog(context, refreshedUser!);
      }
    } catch (e) {
      showToast('Error checking verification status: $e');
    }
  }
}
