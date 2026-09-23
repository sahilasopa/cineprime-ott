import 'package:flutter/material.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/presentation/components/ui/app_widgets.dart';
import '../../pages/authentication/login_screen.dart';

class NotLoggedInSubscribe extends StatelessWidget {
  const NotLoggedInSubscribe({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Plans'),
      ),
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const EmptyState(
                icon: Icons.lock_outline_rounded,
                title: "You're not signed in",
                subtitle: 'Sign in to subscribe and keep watching.',
              ),
              const SizedBox(height: 28),
              GradientButton(
                label: 'Sign In',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
