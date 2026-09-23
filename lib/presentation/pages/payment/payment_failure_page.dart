import 'package:flutter/material.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';
import 'package:cineprime/presentation/pages/drawer_pages/contact_us_page.dart';
import 'package:cineprime/services/logging_service.dart';

import '../home_page.dart';

class PaymentFailurePage extends StatefulWidget {
  const PaymentFailurePage({super.key});

  @override
  State<PaymentFailurePage> createState() => _PaymentFailurePageState();
}

class _PaymentFailurePageState extends State<PaymentFailurePage> {
  @override
  void initState() {
    LoggingService().logEvent('checkout_failure');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/cineprime-logo.png', height: 72),
                const SizedBox(height: 28),
                const Text(
                  'Payment failed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'If any money was deducted from your account it will be refunded. Please contact support if you need help.',
                  style: TextStyle(
                    color: AppColors.colorTextSecondary,
                    fontSize: 15,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Contact Support',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactUsPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Back to home',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
