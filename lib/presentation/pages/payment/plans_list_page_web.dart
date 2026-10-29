import 'package:flutter/material.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/models/subscription_plan.dart';
import 'package:cineprime/presentation/components/subscription/plan_card.dart';
import 'package:cineprime/presentation/pages/payment/payment_success_page.dart';
import 'package:cineprime/presentation/pages/payment/plans_list_page_shimmer.dart';
import 'package:cineprime/providers/authentication_provider.dart';
import 'package:provider/provider.dart';

import '../../../models/user/user.dart';
import '../../../network/api_paths.dart';
import '../../../razorpay_js.dart';
import '../../../services/guest_plans.dart';
import '../../../services/network_service.dart';
import '../authentication/login_screen.dart';

class PlansListPage extends StatefulWidget {
  const PlansListPage({super.key});

  @override
  State<PlansListPage> createState() => _PlansListPageState();
}

class _PlansListPageState extends State<PlansListPage> {
  late List<SubscriptionPlan> _plans = [];
  late BuildContext preContext;
  SubscriptionPlan? selectedPlan;
  bool _guestPlansRequested = false;
  bool _guestPlansFailed = false;

  void _ensureGuestPlans(User? user) {
    if (user != null || _guestPlansRequested || _plans.isNotEmpty) return;
    _guestPlansRequested = true;
    GuestPlans.load().then((plans) {
      if (!mounted || _plans.isNotEmpty) return;
      if (plans.isEmpty) {
        setState(() => _guestPlansFailed = true);
        return;
      }
      setState(() {
        _plans = plans;
        selectedPlan = plans.length > 1 ? plans[1] : plans.first;
      });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authenticationProvider = Provider.of<AuthenticationProvider>(context);
    final user = authenticationProvider.getUser();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: MembershipPageFrame(
          child: FutureBuilder(
          future: authenticationProvider.getPlansListAndEnabledMethods(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final allPlans = List<SubscriptionPlan>.from(snapshot.data?['plans'] ?? const []);
              if (allPlans.isNotEmpty) {
                if (_plans.isEmpty || _plans.any((plan) => plan.id.startsWith('guest-'))) {
                  _plans = allPlans;
                }
              } else {
                _ensureGuestPlans(user);
              }
              if (selectedPlan == null && _plans.length > 1) {
                selectedPlan = _plans[1];
              } else if (selectedPlan == null && _plans.isNotEmpty) {
                selectedPlan = _plans.first;
              }
              if (_plans.isEmpty) {
                return Center(
                  child: _guestPlansFailed
                      ? const Text(
                          'Plans are unavailable right now.',
                          style: TextStyle(color: AppColors.colorTextSecondary),
                        )
                      : const CircularProgressIndicator(color: AppColors.colorPrimary),
                );
              }
              return MembershipBody(
                plans: _plans,
                selectedPlan: selectedPlan,
                onSelect: (plan) => setState(() => selectedPlan = plan),
                onContinue: () {
                  final plan = selectedPlan;
                  if (plan == null) return;
                  _showPlanPopup(user, plan);
                },
              );
            } else {
              return const PlansListPageShimmer();
            }
          },
          ),
        ),
      ),
    );
  }

  void _showPlanPopup(User? user, SubscriptionPlan plan) async {
    if (user == null) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LoginPage(next: const PlansListPage()),
        ),
      );
      return;
    }

    preContext = context;
    await NetworkService().post(
      APIPath.createRazorpayCharge,
      {"object_id": plan.id},
      (data) {
        // Instead of using the mobile-only _razorpay instance, use our web integration.
        openRazorpay(data['body']['options'], (response) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessPage(
                paymentId: response['razorpay_payment_id'],
                paymentGateway: 'razorpay',
                productId: plan.id,
                referralCode: null,
              ),
            ),
          );
        });
      },
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment Failed"),
          ),
        );
      },
      () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please wait while we process your order"),
          ),
        );
      },
    );
  }
}
