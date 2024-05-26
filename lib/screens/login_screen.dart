import 'package:chat_app/consts.dart';
import 'package:chat_app/services/alert_service.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:chat_app/widgets/custom_button.dart';
import 'package:chat_app/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _loginFormKey = GlobalKey();

  String? email;
  String? password;

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width,
              ),
              const Text(
                "Hi, Wellcome Back!",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Hello again, You've been missed",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                ),
              ),
              Container(
                height: MediaQuery.sizeOf(context).height * 0.4,
                margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.sizeOf(context).height * 0.05,
                ),
                child: Form(
                  key: _loginFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
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
                      const SizedBox(height: 30),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.center,
                child: CustomButton(
                  fontSize: 50,
                  height: 100,
                  width: 400,
                  text: "Sign In",
                  onTap: () async {
                    if (_loginFormKey.currentState?.validate() ?? false) {
                      _loginFormKey.currentState?.save();
                      bool result = await _authService.login(email!, password!);
                      if (result) {
                        _navigationService.pushReplacementNamed('/home');
                        _alertService.showToast(
                          text: "Successfully loged in",
                          icon: Icons.check,
                        );
                      } else {
                        _alertService.showToast(
                          text: "Failed to login. Please try again!",
                          icon: Icons.error,
                        );
                      }
                    }
                  },
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        _navigationService.pushNamed('/register');
                      },
                      child: Ink(
                        child: const Text(
                          "Register",
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
