import 'package:flutter/material.dart';
import 'package:cineprime/constants/app_theme.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/network/api_paths.dart';
import 'package:cineprime/presentation/pages/authentication/login_screen.dart';
import 'package:cineprime/presentation/pages/home_page.dart';
import 'package:cineprime/services/logging_service.dart';
import 'package:cineprime/services/network_service.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';
import 'package:cineprime/presentation/components/controls/timer_widget.dart';
import 'package:cineprime/providers/authentication_provider.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:smart_auth/smart_auth.dart';

import '../../../providers/content_provider.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final Widget? next;

  const OtpVerificationPage({super.key, required this.phoneNumber, this.next});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  bool? isValidOtp;
  bool isClickable = true;
  String otp = "";
  String errorMessage = "Invalid OTP";
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    LoggingService().logScreenView("otp_verification_page");
    LoggingService().setCrashlyticsScreen("otp_verification_page");
    getSmsWithRetrieverApi();
  }

  @override
  Widget build(BuildContext context) {
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);
    const pinText = TextStyle(
      fontSize: 24,
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontFamily: AppTheme.fontFamily,
    );

    PinTheme pinTheme({required Color border, Color? fill, double width = 1.5}) {
      return PinTheme(
        width: 58,
        height: 64,
        textStyle: pinText,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: width),
          color: fill ?? AppColors.colorInputFill,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: AppBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Material(
                          color: AppColors.colorSurface.withValues(alpha: 0.72),
                          shape: const CircleBorder(),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage(next: widget.next)),
                              );
                            },
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Image.asset('assets/images/cineprime-logo.png', height: 78),
                      const SizedBox(height: 22),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(1.4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.colorPrimary, AppColors.colorPrimaryLight],
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 26, 20, 18),
                          decoration: BoxDecoration(
                            color: AppColors.colorSurface.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(26.5),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.primaryGradient,
                                ),
                                child: const Icon(Icons.sms_rounded, color: AppColors.colorOnGold, size: 30),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Verify your number',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  fontFamily: AppTheme.fontFamily,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Enter the 4-digit code sent to',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.colorTextSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppTheme.fontFamily,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.phoneNumber,
                                  style: const TextStyle(
                                    color: AppColors.colorOnGold,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    fontFamily: AppTheme.fontFamily,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 26),
                              Form(
                                key: formKey,
                                child: Pinput(
                                  length: 4,
                                  controller: pinController,
                                  focusNode: focusNode,
                                  defaultPinTheme: pinTheme(border: AppColors.colorInputBorder),
                                  separatorBuilder: (index) => const SizedBox(width: 12),
                                  validator: _validateOtp,
                                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                                  onCompleted: (pin) => otp = pin,
                                  onChanged: (value) {
                                    otp = value;
                                    isValidOtp = null;
                                  },
                                  cursor: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        width: 22,
                                        height: 2,
                                        color: AppColors.colorPrimary,
                                      ),
                                    ],
                                  ),
                                  focusedPinTheme: pinTheme(
                                    border: AppColors.colorPrimary,
                                    fill: AppColors.colorPrimary.withValues(alpha: 0.14),
                                    width: 2,
                                  ),
                                  submittedPinTheme: pinTheme(
                                    border: AppColors.colorPrimaryLight,
                                    fill: AppColors.colorAccent.withValues(alpha: 0.16),
                                  ),
                                  errorPinTheme: pinTheme(
                                    border: Colors.redAccent,
                                    fill: Colors.redAccent.withValues(alpha: 0.12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 26),
                              GradientButton(
                onPressed: () async {
                  if (!isClickable) return;
                  setState(() {
                    isClickable = false;
                  });
                  focusNode.unfocus();
                  if (otp.length != 4) {
                    setState(() {
                      isClickable = true;
                    });
                    isValidOtp = false;
                    errorMessage = "Please enter an OTP";
                    formKey.currentState!.validate();
                  } else {
                    await NetworkService().post(
                      APIPath.verifyOTP,
                      {
                        "otp": otp,
                        "phoneNumber": widget.phoneNumber,
                      },
                      (data) async {
                        isValidOtp = true;
                        LoggingService().logEvent('signup');
                        final sessionId = data['body']['session_id'];
                        final userJson = data['body']['user'];
                        await authenticationProvider.saveUserToken(sessionId, userJson: userJson);
                        Provider.of<ContentProvider>(context, listen: false).init();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => widget.next ?? HomePage(),
                            ),
                            (route) => false,
                          );
                          // Modal will be shown from HomePage's initState
                        });
                      },
                      (error) {
                        setState(() {
                          isClickable = true;
                        });
                        isValidOtp = false;
                        errorMessage = error['body']['message'];
                        formKey.currentState!.validate();
                      },
                      () {},
                    );
                  }
                },
                                label: 'Verify',
                                isLoading: !isClickable,
                              ),
                              const SizedBox(height: 18),
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    "Didn't receive the code? ",
                                    style: TextStyle(
                                      color: AppColors.colorTextMuted,
                                      fontSize: 14,
                                      fontFamily: AppTheme.fontFamily,
                                    ),
                                  ),
                                  TimerWidget(
                                    initialSeconds: 60,
                                    onPressed: () async {
                                      await NetworkService().post(
                                        APIPath.sendOTP,
                                        {"phone_number": widget.phoneNumber},
                                        (data) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP resent successfully")));
                                        },
                                        (error) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error['body']['message'])));
                                          isValidOtp = false;
                                          errorMessage = error['body']['message'];
                                          formKey.currentState!.validate();
                                        },
                                        () {},
                                      );
                                    },
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginPage(next: widget.next),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Change phone number',
                                  style: TextStyle(
                                    color: AppColors.colorPrimaryLight,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: AppTheme.fontFamily,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String? _validateOtp(String? otp) {
    if (otp == null || otp.length != 4) return errorMessage;
    if (isValidOtp != null) {
      if (!isValidOtp!) return errorMessage;
    }
    return null;
  }

  void getSmsWithRetrieverApi() async {
    final smartAuth = SmartAuth.instance;
    final res = await smartAuth.getSmsWithRetrieverApi();
    if (res.hasData) {
      final code = res.requireData.code;

      /// The code can be null if the SMS was received but the code was not extracted from it
      if (code == null) return;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          pinController.text = code;
        });
      },);
      //  Use the code
    } else {
      // handle the error
    }
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
