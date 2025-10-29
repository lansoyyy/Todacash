import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phara/screens/auth/login_screen.dart';
import 'package:phara/screens/splashtohome_screen.dart';
import 'package:phara/services/signup.dart';
import 'package:phara/utils/colors.dart';
import 'package:phara/utils/keys.dart';
import 'package:phara/widgets/button_widget.dart';
import 'package:phara/widgets/text_widget.dart';
import 'package:phara/widgets/textfield_widget.dart';
import 'package:phara/widgets/toast_widget.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_webservice/places.dart' as location;
import 'package:google_api_headers/google_api_headers.dart';
import 'dart:io';
import '../terms_conditions_page.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final nameController = TextEditingController();

  final numberController = TextEditingController();

  final addressController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Image picker variables
  File? _validIDImage;
  bool _isUploading = false;
  String? _validIDUrl;

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
                    height: 20,
                  ),
                  TextBold(text: 'Todacash', fontSize: 58, color: Colors.white),
                  const SizedBox(
                    height: 25,
                  ),
                  TextRegular(
                      text: 'Signup', fontSize: 24, color: Colors.white),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFieldWidget(
                    label: 'Name',
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFieldWidget(
                    hint: '09XXXXXXXXX',
                    inputType: TextInputType.number,
                    label: 'Mobile Number',
                    controller: numberController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a mobile number';
                      } else if (value.length != 11 ||
                          !value.startsWith('09')) {
                        return 'Please enter a valid mobile number';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextRegular(
                      text: 'Address', fontSize: 12, color: Colors.white),
                  const SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(width: 1, color: grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(width: 1, color: grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(width: 1, color: Colors.black),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      label: TextRegular(
                          text: addressController.text,
                          fontSize: 14,
                          color: Colors.black),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFieldWidget(
                    textCapitalization: TextCapitalization.none,
                    inputType: TextInputType.streetAddress,
                    label: 'Email',
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email address';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFieldWidget(
                    textCapitalization: TextCapitalization.none,
                    showEye: true,
                    isObscure: true,
                    inputType: TextInputType.streetAddress,
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
                  const SizedBox(
                    height: 10,
                  ),
                  TextFieldWidget(
                    textCapitalization: TextCapitalization.none,
                    showEye: true,
                    isObscure: true,
                    inputType: TextInputType.streetAddress,
                    label: 'Confirm Password',
                    controller: confirmPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value != passwordController.text) {
                        return 'Password do not match';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  // Valid ID Upload Section
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextBold(
                          text: 'Valid ID Verification',
                          fontSize: 16,
                          color: black,
                        ),
                        const SizedBox(height: 10),
                        TextRegular(
                          text: 'Please upload a valid ID for verification',
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(height: 10),
                        if (_validIDImage != null)
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.file(
                                    _validIDImage!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _validIDImage = null;
                                        _validIDUrl = null;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.shade300,
                                  style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 40,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(height: 10),
                                TextRegular(
                                  text: 'No image selected',
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ButtonWidget(
                                color: Colors.blue,
                                label: _validIDImage != null
                                    ? 'Change ID'
                                    : 'Select ID',
                                onPressed: () {
                                  _pickImage();
                                },
                              ),
                            ),
                            if (_validIDImage != null) ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: _isUploading
                                    ? ButtonWidget(
                                        color: Colors.grey,
                                        label: 'Uploading...',
                                        onPressed: () {},
                                      )
                                    : ButtonWidget(
                                        color: Colors.green,
                                        label: 'Upload ID',
                                        onPressed: () {
                                          print(
                                              'DEBUG: Upload ID button pressed');
                                          _uploadValidID();
                                        },
                                      ),
                              ),
                            ],
                          ],
                        ),
                        if (_validIDUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: TextRegular(
                                    text: 'ID uploaded successfully',
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Center(
                    child: ButtonWidget(
                      color: black,
                      label: 'Signup',
                      onPressed: (() {
                        if (_formKey.currentState!.validate()) {
                          print('DEBUG: _validIDUrl value: $_validIDUrl');
                          if (_validIDUrl == null || _validIDUrl!.isEmpty) {
                            showToast(
                                'Please upload your valid ID to complete registration');
                          } else {
                            register(context);
                          }
                        }
                      }),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: TextRegular(
                        text: 'Signing up means you agree to our',
                        fontSize: 12,
                        color: Colors.white),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                const TermsAndConditionsPage()));
                      },
                      child: TextBold(
                          text: 'Terms and Conditions',
                          fontSize: 14,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextRegular(
                          text: "Already have an Account?",
                          fontSize: 12,
                          color: Colors.white),
                      TextButton(
                        onPressed: (() {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        }),
                        child: TextBold(
                            text: "Login Now",
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

  register(context) async {
    try {
      // Create user account
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Store user data in Firestore
      signup(nameController.text, numberController.text, addressController.text,
          emailController.text, _validIDUrl);

      showToast(
          "Registered Successfully! Please check your email for verification.");

      // Show email verification dialog
      _showEmailVerificationDialog(context, userCredential.user!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showToast('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showToast('The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        showToast('The email address is not valid.');
      } else {
        showToast(e.toString());
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
                Icon(Icons.email_outlined, color: Colors.blue, size: 28),
                const SizedBox(width: 10),
                TextBold(
                    text: 'Email Verification', fontSize: 18, color: black),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextRegular(
                  text: 'We have sent a verification email to:',
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
                      'Please check your inbox and click on the verification link to complete your registration.',
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
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                child: TextBold(
                  text: 'Login',
                  fontSize: 14,
                  color: Colors.green,
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

        // Sign in the user and navigate to home
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);

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

  // Image picker function
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    // Show dialog to choose between camera and gallery
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              TextBold(text: 'Select Image Source', fontSize: 18, color: black),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: TextRegular(text: 'Camera', fontSize: 16, color: black),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      _validIDImage = File(image.path);
                      _validIDUrl =
                          null; // Reset URL when new image is selected
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: TextRegular(text: 'Gallery', fontSize: 16, color: black),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _validIDImage = File(image.path);
                      _validIDUrl =
                          null; // Reset URL when new image is selected
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Upload image to Firebase Storage
  Future<void> _uploadValidID() async {
    print('DEBUG: _uploadValidID called');
    if (_validIDImage == null) {
      print('DEBUG: No image selected');
      showToast('Please select an image first');
      return;
    }

    print('DEBUG: Image selected, starting upload');
    setState(() {
      _isUploading = true;
    });

    try {
      // Create a unique filename using timestamp and random number
      final String fileName =
          'valid_id_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}.jpg';
      print('DEBUG: Generated filename: $fileName');

      // Create a reference to the Firebase Storage
      final ref =
          FirebaseStorage.instance.ref().child('valid_ids').child(fileName);
      print('DEBUG: Storage reference created: ${ref.fullPath}');

      // Upload the file
      print('DEBUG: Starting file upload...');
      final uploadTask = await ref.putFile(_validIDImage!);
      print('DEBUG: File upload completed. Task state: ${uploadTask.state}');

      // Get the download URL
      print('DEBUG: Getting download URL...');
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print('DEBUG: Download URL obtained: $downloadUrl');

      setState(() {
        _validIDUrl = downloadUrl;
        _isUploading = false;
      });

      print('DEBUG: State updated. _validIDUrl is now: $_validIDUrl');
      showToast('Valid ID uploaded successfully');
    } catch (e) {
      print('DEBUG: Upload failed with error: $e');
      setState(() {
        _isUploading = false;
      });
      showToast('Failed to upload ID: $e');
    }
  }

  searchAddress() async {
    location.Prediction? p = await PlacesAutocomplete.show(
        mode: Mode.overlay,
        context: context,
        apiKey: kGoogleApiKey,
        language: 'en',
        strictbounds: false,
        types: [""],
        decoration: InputDecoration(
            hintText: 'Search Pick-up Location',
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.white))),
        components: [location.Component(location.Component.country, "ph")]);

    location.GoogleMapsPlaces places = location.GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders());

    location.PlacesDetailsResponse detail =
        await places.getDetailsByPlaceId(p!.placeId!);

    setState(() {
      addressController.text = detail.result.name;
    });
  }
}
