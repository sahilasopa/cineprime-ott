import 'package:flutter/material.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/presentation/age_popup.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';
import 'package:cineprime/presentation/pages/home_page.dart';
import 'package:cineprime/presentation/pages/payment/payment_failure_page.dart';
import 'package:cineprime/services/logging_service.dart';
import 'package:provider/provider.dart';

import '../../../providers/authentication_provider.dart';

class PaymentSuccessPage extends StatefulWidget {
  final String? paymentId;
  final String? productId;
  final String? referralCode;
  final String? couponCode;
  final String paymentGateway;

  const PaymentSuccessPage({
    super.key,
    required this.paymentId,
    required this.paymentGateway,
    required this.productId,
    required this.referralCode,
    this.couponCode,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  @override
  Widget build(BuildContext context) {
    final AuthenticationProvider authenticationProvider = Provider.of<AuthenticationProvider>(
      context,
      listen: false,
    );
    authenticationProvider.pollPaymentStatus(
      widget.paymentId,
      widget.paymentGateway,
      widget.referralCode,
      widget.couponCode,
      widget.productId ?? "NA",
      (user) {
        if (user.userSubscription == null) {
          showLinkedAccountDialog(context, onGotIt: () {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          });
          return;
        }

        LoggingService().logPurchase(
          user.userSubscription!.planValue.toDouble(),
          currency: 'INR',
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      },
      (error) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PaymentFailurePage(),
          ),
        );
      },
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/cineprime-logo.png', height: 72),
                  const SizedBox(height: 28),
                  const CircularProgressIndicator(color: AppColors.colorPrimary),
                  const SizedBox(height: 28),
                  const Text(
                    'Confirming Your Payment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please do not press the back button. We will redirect you shortly.',
                    style: TextStyle(
                      color: AppColors.colorTextSecondary,
                      fontSize: 15,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
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
