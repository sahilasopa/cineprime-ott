import 'package:flutter/material.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';

class ContactUsSuccessPage extends StatefulWidget {
  const ContactUsSuccessPage({super.key});

  @override
  State<ContactUsSuccessPage> createState() => _ContactUsSuccessPageState();
}

class _ContactUsSuccessPageState extends State<ContactUsSuccessPage> {
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
                  'Thank you for contacting us',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'We will get back to you soon.',
                  style: TextStyle(
                    color: AppColors.colorTextSecondary,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Back to home',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
