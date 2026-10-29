import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/network/api_paths.dart';
import 'package:cineprime/platform_utils.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';
import 'package:cineprime/presentation/pages/authentication/otp_verifiction_page.dart';
import 'package:cineprime/presentation/pages/home_page.dart';
import 'package:cineprime/presentation/pages/payment/plans_list_page.dart';
import 'package:cineprime/providers/authentication_provider.dart';
import 'package:cineprime/providers/content_provider.dart';
import 'package:cineprime/services/logging_service.dart';
import 'package:cineprime/services/network_service.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../drawer_pages/legal/legal_list.dart';

class LoginPage extends StatefulWidget {
  final Widget? next;

  const LoginPage({super.key, this.next});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

bool validateEmail(String email) {
  String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  RegExp regex = RegExp(pattern);
  return regex.hasMatch(email);
}

class _LoginPageState extends State<LoginPage> {
  bool _isButtonDisabled = false;
  late AuthenticationProvider authenticationProvider;
  late ContentProvider contentProvider;
  final PlatformUtils platformUtils = PlatformUtils();

  late GoogleSignIn _googleSignIn;
  String? phoneError;
  String phoneNumber = "";
  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    LoggingService().logScreenView("login_screen");
    LoggingService().setCrashlyticsScreen("login_screen");
    if (PlatformUtils.isWeb) {
      _googleSignIn = GoogleSignIn(
        clientId:
            '227381852653-jskdv59enm926fpi7kv8934tshgjg5lc.apps.googleusercontent.com',
        scopes: [
          'email',
          'profile',
        ],
      );
    } else {
      _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
      );
    }

    phoneController.addListener(_phoneChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authenticationProvider =
          Provider.of<AuthenticationProvider>(context, listen: false);
      attemptSilentSignIn();
    });
  }

  void attemptSilentSignIn() async {
    if (!PlatformUtils.isWeb) return;
    final account = await _googleSignIn.signInSilently();
    if (account == null) return;
    final authentication = await account.authentication;
    final idToken = authentication.idToken;
    if (idToken != null) {
      await NetworkService().post(
        APIPath.googleSignIn,
        {'id_token': idToken},
        (data) {
          final sessionId = data['body']['session_id'];
          authenticationProvider.saveUserToken(sessionId);
        },
        (error) {
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error['body']['message']),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: keyboardHeight),
            ),
          );
        },
        () {},
      );
      setState(() {
        _isButtonDisabled = false;
      });
    }
  }

  @override
  void dispose() {
    phoneController.removeListener(_phoneChanged);
    phoneController.dispose();
    super.dispose();
  }

  void _phoneChanged() {
    if (phoneNumber != phoneController.text) {
      setState(() {
        _isButtonDisabled = false;
        phoneError = null; // Clear error when user starts typing
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    authenticationProvider = Provider.of<AuthenticationProvider>(context);
    contentProvider = Provider.of<ContentProvider>(context, listen: false);
    final loginMethod = contentProvider.getLoginConfigConfirm();

    if (authenticationProvider.getUser() != null && mounted) {
      LoggingService().logEvent('signup');
      contentProvider.init();
      if (loginMethod == 'B' || loginMethod == 'C') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (authenticationProvider.getUser()!.userSubscription == null) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => PlansListPage(),
              ),
              (_) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => HomePage(),
              ),
              (_) => false,
            );
            // Modal will be shown from HomePage's initState
          }
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ModalRoute.of(context)?.isCurrent == true) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => widget.next ?? HomePage(),
              ),
              (_) => false,
            );
            // Modal will be shown from HomePage's initState
          }
        });
      }
    }
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
                children: [
                  if (Navigator.of(context).canPop())
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Material(
                          color: AppColors.colorSurface.withValues(alpha: 0.72),
                          shape: const CircleBorder(),
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, inner) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: inner.maxHeight - 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                      Image.asset('assets/images/cineprime-logo.png', height: 108),
                      const SizedBox(height: 28),
                      const Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to continue your entertainment journey',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.colorTextSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),
                      DarkField(
                        controller: phoneController,
                        hintText: 'Phone Number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        errorText: phoneError,
                        onEditingComplete: () => FocusScope.of(context).unfocus(),
                      ),
                      const SizedBox(height: 20),
                      GradientButton(
                        label: 'Sign In',
                        isLoading: _isButtonDisabled,
                        onPressed: _isButtonDisabled
                            ? null
                            : () async {
                                phoneNumber = phoneController.text;
                                if (phoneNumber.isNotEmpty) {
                                  setState(() {
                                    _isButtonDisabled = true;
                                  });
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  await NetworkService().post(
                                    APIPath.sendOTP,
                                    {"phone_number": phoneNumber},
                                    (data) async {
                                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                                        builder: (context) => OtpVerificationPage(
                                          phoneNumber: phoneNumber,
                                          next: widget.next,
                                        ),
                                      ));
                                    },
                                    (error) {
                                      String? errorMessage;
                                      if (error.toString().contains('body')) {
                                        errorMessage = error['body']["message"];
                                      } else {
                                        errorMessage = error;
                                      }
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(errorMessage ?? "Something Went Wrong"),
                                        ),
                                      );
                                      setState(() {
                                        _isButtonDisabled = false;
                                      });
                                    },
                                    () {},
                                  );
                                } else {
                                  setState(() {
                                    phoneError = "Please Enter A Phone Number";
                                  });
                                }
                              },
                      ),
                      const SizedBox(height: 12),
                      SocialCircleButton(
                        label: 'Continue with Google',
                        fill: Colors.white,
                        foreground: AppColors.colorOnGold,
                        border: AppColors.colorPrimary,
                        icon: Image.asset('assets/images/google.png', width: 22, height: 22),
                        onPressed: _isButtonDisabled
                                ? () {}
                                : () async {
                                    try {
                                      final account = await _googleSignIn.signIn();
                                      if (account == null) return;
                                      final googleAuth = await account.authentication;
                                      final idToken = googleAuth.idToken;
                                      if (idToken != null) {
                                        await NetworkService().post(
                                          APIPath.googleSignIn,
                                          {'id_token': idToken},
                                          (data) async {
                                            final sessionId = data['body']['session_id'];
                                            final userJson = data['body']['user'];
                                            await authenticationProvider.saveUserToken(
                                              sessionId,
                                              userJson: userJson,
                                            );
                                          },
                                          (error) {
                                            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(error['body']['message']),
                                                behavior: SnackBarBehavior.floating,
                                                margin: EdgeInsets.only(bottom: keyboardHeight),
                                              ),
                                            );
                                          },
                                          () {},
                                        );
                                        setState(() {
                                          _isButtonDisabled = false;
                                        });
                                      }
                                    } catch (error) {
                                      if (mounted) {
                                        setState(() {
                                          _isButtonDisabled = false;
                                        });
                                      }
                                    }
                                  },
                      ),
                      const SizedBox(height: 12),
                      SocialCircleButton(
                        label: 'Continue with Apple',
                        fill: const Color(0xFF111318),
                        foreground: Colors.white,
                        border: AppColors.colorPrimaryLight,
                        icon: const FaIcon(FontAwesomeIcons.apple, color: Colors.white, size: 22),
                        onPressed: _isButtonDisabled
                                ? () {}
                                : () async {
                                    try {
                                      final appleCredential = await SignInWithApple.getAppleIDCredential(
                                        scopes: [
                                          AppleIDAuthorizationScopes.email,
                                          AppleIDAuthorizationScopes.fullName,
                                        ],
                                        webAuthenticationOptions: WebAuthenticationOptions(
                                          clientId: "app.butterflyott.app.signin",
                                          redirectUri: Uri.parse(
                                            "https://butterflyott.com/api/v1/auth/callback/apple-sign-in",
                                          ),
                                        ),
                                      );
                                      final token = appleCredential.identityToken;
                                      NetworkService().post(
                                        APIPath.appleSignIn,
                                        {
                                          "token": token,
                                          "first_name": appleCredential.givenName,
                                          "last_name": appleCredential.familyName
                                        },
                                        (data) {
                                          final sessionId = data['body']['session_id'];
                                          final userJson = data['body']['user'];
                                          authenticationProvider.saveUserToken(
                                            sessionId,
                                            userJson: userJson,
                                          );
                                        },
                                        (error) {
                                          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(error['body']['message']),
                                              behavior: SnackBarBehavior.floating,
                                              margin: EdgeInsets.only(bottom: keyboardHeight),
                                            ),
                                          );
                                        },
                                        () {},
                                      );
                                    } catch (error) {
                                      print(error);
                                    }
                                  },
                      ),
                      const SizedBox(height: 28),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            color: AppColors.colorTextSecondary,
                            fontSize: 14,
                            fontFamily: 'Mulish',
                          ),
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: 'Sign Up',
                              style: const TextStyle(
                                color: AppColors.colorPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  FocusScope.of(context).unfocus();
                                },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            height: 1.4,
                            color: AppColors.colorTextMuted,
                            fontSize: 12,
                            fontFamily: 'Mulish',
                          ),
                          children: <TextSpan>[
                            const TextSpan(text: "By using this app you confirm that you agree to our "),
                            TextSpan(
                              text: 'Policies',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.colorAccent,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const LegalListPage(),
                                  ));
                                },
                            ),
                          ],
                        ),
                      ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
