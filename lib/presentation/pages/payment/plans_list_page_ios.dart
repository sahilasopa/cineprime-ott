import 'dart:async';
import 'dart:ui';
import '../authentication/login_screen.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/models/subscription_plan.dart';
import 'package:cineprime/presentation/components/subscription/plan_card.dart';
import 'package:cineprime/presentation/pages/payment/payment_success_page.dart';
import 'package:cineprime/presentation/pages/payment/plans_list_page_shimmer.dart';
import 'package:cineprime/providers/authentication_provider.dart';
import 'package:cineprime/services/guest_plans.dart';
import 'package:provider/provider.dart';

class PlansListPage extends StatefulWidget {
  const PlansListPage({super.key});

  @override
  State<PlansListPage> createState() => _PlansListPageState();
}

class _PlansListPageState extends State<PlansListPage> {
  final _inAppPurchase = InAppPurchase.instance;

  /// Loaded once.
  late Future<Map<String, dynamic>> _plansFuture;

  /// Loaded once.
  List<SubscriptionPlan> _plans = [];
  List<ProductDetails> _products = [];

  SubscriptionPlan? selectedPlan;
  Set<String> _ids = {};

  bool _pendingDialogVisible = false;
  late final StreamSubscription<List<PurchaseDetails>> _purchaseSub;

  /// Track user-initiated purchase flow so we can ignore random restores/renewals.
  bool _purchaseInProgress = false;
  bool _guestPlansRequested = false;
  bool _guestPlansFailed = false;
  String? _activeProductId;

  @override
  void initState() {
    super.initState();

    final auth = Provider.of<AuthenticationProvider>(context, listen: false);
    _plansFuture = auth.getPlansListAndEnabledMethods();

    _purchaseSub = _inAppPurchase.purchaseStream.listen(
      _listenToPurchaseUpdates,
      onDone: () {
        debugPrint('Purchase stream done');
      },
      onError: (Object error) {
        debugPrint('Purchase stream error: $error');
      },
    );
  }

  @override
  void dispose() {
    _purchaseSub.cancel();
    super.dispose();
  }

  // ------------------------------------------------------------
  // PURCHASE LISTENER
  // ------------------------------------------------------------
  Future<void> _listenToPurchaseUpdates(List<PurchaseDetails> purchases) async {
    if (!mounted) return;

    for (final p in purchases) {
      debugPrint(
        'Purchase update -> '
            'product: ${p.productID}, '
            'status: ${p.status}, '
            'pendingComplete: ${p.pendingCompletePurchase}',
      );

      final bool isCurrentFlow =
          _purchaseInProgress && _activeProductId == p.productID;

      // ------------------------------------------------------------
      // 1) SPECIAL CASE: Subscription upgrade
      // Apple sends ONLY a "restored" event when user upgrades
      // We MUST treat restore as success if user initiated purchase,
      // even if the restored product is NOT the one just purchased.
      // ------------------------------------------------------------
      if (_purchaseInProgress &&
          p.status == PurchaseStatus.restored &&
          !isCurrentFlow) {
        debugPrint("✔ Apple accepted subscription upgrade via RESTORE.");

        final receipt = p.verificationData.serverVerificationData;
        final gateway = p.verificationData.source == 'google_play'
            ? 'google-in-app'
            : 'apple-in-app';

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentSuccessPage(
                paymentId: receipt,
                paymentGateway: gateway,
                productId: _activeProductId ?? p.productID,
                referralCode: null,
              ),
            ),
          );
        }

        if (p.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(p);
        }

        _purchaseInProgress = false;
        _activeProductId = null;
        continue;
      }

      // ------------------------------------------------------------
      // 2) Ignore unrelated old restores (normal behavior)
      // ------------------------------------------------------------
      if (!isCurrentFlow && p.status == PurchaseStatus.restored) {
        debugPrint("Ignoring unrelated restore for ${p.productID}");
        if (p.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(p);
        }
        continue;
      }

      // ------------------------------------------------------------
      // 3) Pending state → show loader
      // ------------------------------------------------------------
      if (p.status == PurchaseStatus.pending) {
        _showPendingUI();
        continue;
      }

      // Close pending loader for any non-pending state
      if (_pendingDialogVisible && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _pendingDialogVisible = false;
      }

      // ------------------------------------------------------------
      // 4) Handle all purchase outcomes
      // ------------------------------------------------------------
      switch (p.status) {
        case PurchaseStatus.error:
          debugPrint("Purchase error: ${p.error}");
          _purchaseInProgress = false;
          _activeProductId = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Payment failed. Try again.")),
          );
          break;

        case PurchaseStatus.canceled:
          debugPrint("Purchase canceled by user.");
          _purchaseInProgress = false;
          _activeProductId = null;
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
        // Normal success case for the SAME product
          final receipt = p.verificationData.serverVerificationData;
          final gateway = p.verificationData.source == 'google_play'
              ? 'google-in-app'
              : 'apple-in-app';

          debugPrint("✔️ Purchase SUCCESS for ${p.productID}");

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentSuccessPage(
                  paymentId: receipt,
                  paymentGateway: gateway,
                  productId: p.productID,
                  referralCode: null,
                ),
              ),
            );
          }
          break;

        default:
          break;
      }

      // ------------------------------------------------------------
      // 5) Always complete the transaction
      // ------------------------------------------------------------
      if (p.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(p);
      }

      // Reset
      _purchaseInProgress = false;
      _activeProductId = null;
    }
  }

  // ------------------------------------------------------------
  // UI HELPERS
  // ------------------------------------------------------------
  void _showPendingUI() {
    if (_pendingDialogVisible) return;
    _pendingDialogVisible = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              BackdropFilter(filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5)),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.colorPrimary,),
                    SizedBox(height: 20),
                    Text(
                      "Processing Your Payment",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Please do not close this screen.",
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    ).then((_) => _pendingDialogVisible = false);
  }

  // ------------------------------------------------------------
  // LOAD IAP PRODUCTS — One Time
  // ------------------------------------------------------------
  Future<void> _loadProductsOnce() async {
    if (_ids.isEmpty || _products.isNotEmpty) return;

    final available = await _inAppPurchase.isAvailable();
    if (!available) {
      debugPrint('In-app purchases not available on this device/store.');
      return;
    }
    print(_ids);
    final response = await _inAppPurchase.queryProductDetails(_ids);
    print(response.error);
    print(response.notFoundIDs);
    print(response.productDetails);
    if (!mounted) return;

    if (response.error != null) {
      debugPrint('ProductDetails error: ${response.error}');
    }

    setState(() {
      _products = response.productDetails;
    });

    debugPrint(
        'Loaded products: ${_products.map((p) => '${p.id} (${p.price})').join(', ')}');
  }

  ProductDetails? _getProductForPlan(SubscriptionPlan plan) {
    try {
      print(plan.iapId);
      return _products.firstWhere((p) => p.id == plan.iapId);
    } catch (_) {
      debugPrint('No ProductDetails found for plan ${plan.id} (${plan.iapId})');
      return null;
    }
  }

  Future<void> _startPurchase(SubscriptionPlan plan) async {
    final auth = Provider.of<AuthenticationProvider>(context, listen: false);
    final user = auth.getUser();
    if (user == null) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LoginPage(next: const PlansListPage()),
        ),
      );
      return;
    }


    final product = _getProductForPlan(plan);
    if (product == null) {
      debugPrint('❌ Cannot start purchase — product is null.');
      return;
    }

    // Mark this purchase as user-initiated
    _purchaseInProgress = true;
    _activeProductId = product.id;

    final payload = '${user.id}-${plan.id}';

    final param = PurchaseParam(
      productDetails: product,
      applicationUserName: payload,
    );

    debugPrint("▶️ Starting purchase for ${product.id}");

    try {
      await _inAppPurchase.buyNonConsumable(purchaseParam: param);
    } catch (e) {
      debugPrint("buyNonConsumable ERROR: $e");
      _purchaseInProgress = false;
      _activeProductId = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to start payment.")),
      );
    }
  }

  void _ensureGuestPlans(bool signedIn) {
    if (signedIn || _guestPlansRequested || _plans.isNotEmpty) return;
    _guestPlansRequested = true;
    GuestPlans.load().then((plans) {
      if (!mounted || _plans.isNotEmpty) return;
      if (plans.isEmpty) {
        setState(() => _guestPlansFailed = true);
        return;
      }
      setState(() {
        _plans = plans;
        selectedPlan = plans.firstWhereOrNull((plan) => plan.isDefaultSelected) ?? plans.first;
      });
    });
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final signedIn = Provider.of<AuthenticationProvider>(context, listen: false).getUser() != null;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: MembershipPageFrame(
          child: FutureBuilder(
          future: _plansFuture,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const PlansListPageShimmer();
            }

            final result = snap.data as Map<String, dynamic>;
            final allPlans = List<SubscriptionPlan>.from(result['plans'] ?? const []);

            if (allPlans.isNotEmpty && (_plans.isEmpty || _plans.any((plan) => plan.id.startsWith('guest-')))) {
              _plans = allPlans;
              selectedPlan = _plans.firstWhereOrNull((e) => e.isDefaultSelected);
              if (selectedPlan == null && _plans.length > 1) selectedPlan = _plans[1];
              if (selectedPlan == null && _plans.isNotEmpty) selectedPlan = _plans.first;
              _ids = _plans.map((p) => p.iapId).where((id) => id.isNotEmpty).toSet();
              _loadProductsOnce();
            } else if (_plans.isEmpty) {
              _ensureGuestPlans(signedIn);
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
              onSelect: (plan) {
                if (!context.mounted) return;
                setState(() => selectedPlan = plan);
              },
              onContinue: () {
                final plan = selectedPlan;
                if (plan == null || !context.mounted) return;
                _onPlanPressed(plan);
              },
            );
          },
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ON PLAN PRESSED
  // ------------------------------------------------------------
  void _onPlanPressed(SubscriptionPlan plan) {
    setState(() => selectedPlan = plan);
    _startPurchase(plan);
  }
}
