import 'dart:io';

import 'package:chat_app/consts.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/services/alert_service.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/media_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/services/storage_service.dart';
import 'package:chat_app/widgets/custom_button.dart';
import 'package:chat_app/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _registerFormKey = GlobalKey();

  File? selectedImage;
  String? name;
  String? email;
  String? password;
  bool isLoading = false;

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late MediaService _mediaService;
  late StorageService _storageService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width,
              ),
              const Text(
                "Let's get going!",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Register an account using the form below",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () async {
                    File? file = await _mediaService.getImageFromGallery();
                    if (file != null) {
                      setState(() {
                        selectedImage = file;
                      });
                    }
                  },
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.15,
                    backgroundImage: selectedImage != null
                        ? FileImage(selectedImage!)
                        : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
                  ),
                ),
              ),
              Container(
                // height: MediaQuery.sizeOf(context).height * 0.3,
                margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.sizeOf(context).height * 0.05,
                ),
                child: Form(
                  key: _registerFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomFormField(
                        onSaved: (value) {
                          setState(() {
                            name = value!;
                          });
                        },
                        obscureText: false,
                        validationRegExp: NAME_VALIDATION_REGEX,
                        height: MediaQuery.sizeOf(context).height * 0.11,
                        hint: "Name",
                      ),
                      const SizedBox(height: 15),
                      CustomFormField(
                        onSaved: (value) {
                          setState(() {
                            email = value!;
                          });
                        },
                        obscureText: false,
                        validationRegExp: EMAIL_VALIDATION_REGEX,
                        height: MediaQuery.sizeOf(context).height * 0.11,
                        hint: "Email",
                      ),
                      const SizedBox(height: 15),
                      CustomFormField(
                        onSaved: (value) {
                          setState(() {
                            password = value!;
                          });
                        },
                        obscureText: true,
                        validationRegExp: PASSWORD_VALIDATION_REGEX,
                        height: MediaQuery.sizeOf(context).height * 0.11,
                        hint: "Password",
                      ),
                      // const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.center,
                child: isLoading == true
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        fontSize: 20,
                        height: 70,
                        width: 400,
                        text: "Register",
                        onTap: () async {
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            if (_registerFormKey.currentState?.validate() ??
                                false) {
                              _registerFormKey.currentState?.save();
                              bool result =
                                  await _authService.signUp(email!, password!);
                              if (result) {
                                String? pfpURL =
                                    await _storageService.uploadUserPfp(
                                        file: selectedImage!,
                                        uid: _authService.user!.uid);
                                if (pfpURL != null) {
                                  await _databaseService.createUserProfile(
                                    userProfile: UserProfile(
                                      uid: _authService.user!.uid,
                                      name: name,
                                      pfpURL: pfpURL,
                                    ),
                                  );
                                } else {
                                  throw Exception(
                                      'Unable to upload user profile picture');
                                }
                                _navigationService.goBack();
                                _navigationService
                                    .pushReplacementNamed('/home');
                                _alertService.showToast(
                                  text: "Successfully registerd",
                                  icon: Icons.check,
                                );
                              } else {
                                throw Exception("Unable to register user");
                              }
                            }
                          } catch (e) {
                            _alertService.showToast(
                              text: "Failed to register. Please try again!",
                              icon: Icons.error,
                            );
                          }

                          setState(() {
                            isLoading = false;
                          });
                        }),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        _navigationService.goBack();
                      },
                      child: Ink(
                        child: const Text(
                          "Log in",
                          style: TextStyle(
                            fontSize: 20,
                            decoration: TextDecoration.underline,
                          ),
                        ),
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
