import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import '../authentication/login_screen.dart';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cineprime/constants/colors.dart';
import 'package:cineprime/constants/text.dart';
import 'package:cineprime/models/subscription_plan.dart';
import 'package:cineprime/presentation/components/subscription/plan_card.dart';
import 'package:cineprime/presentation/pages/payment/payment_failure_page.dart';
import 'package:cineprime/presentation/pages/payment/payment_success_page.dart';
import 'package:cineprime/providers/authentication_provider.dart';
import 'package:payu_checkoutpro_flutter/PayUConstantKeys.dart';
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../models/user/user.dart';
import '../../../network/api_paths.dart';
import '../../../services/guest_plans.dart';
import '../../../services/network_service.dart';
import '../../components/bottom_sheet/payment_bottomsheet.dart';
import 'plans_list_page_shimmer.dart';
import 'sabpaisa_checkout_page.dart';

class PlansListPage extends StatefulWidget {
  const PlansListPage({super.key});

  @override
  State<PlansListPage> createState() => _PlansListPageState();
}

class _PlansListPageState extends State<PlansListPage> implements PayUCheckoutProProtocol {
  final _razorpay = Razorpay();
  final _stripe = Stripe.instance;
  final _cashfree = CFPaymentGatewayService();
  String paymentId = '';
  String? referralCode;
  final _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  late Set<String> _ids = <String>{};
  late   List<SubscriptionPlan> _plans = [];
  List<SubscriptionPlan> _basePlans = [];
  late Set<String> _enabledMethods = <String>{};
  late BuildContext preContext;
  bool _pendingDialogVisible = false;
  SubscriptionPlan? selectedPlan;
  final TextEditingController _promoController = TextEditingController();
  String? _appliedCouponCode;
  String? _couponMessage;
  bool _couponLoading = false;
  bool _showPromoInput = false;
  bool _guestPlansRequested = false;
  bool _guestPlansFailed = false;
  String? _cashfreePlanId;
  String? _cashfreeReferralCode;
  String? _cashfreeCouponCode;
  bool _cashfreeHandled = false;

  // final sdk = JuspaySingleton().hyperSDK;

  late PayUCheckoutProFlutter _checkoutPro;

  @override
  void initState() {
    super.initState();
    _checkoutPro = PayUCheckoutProFlutter(this);
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorpayPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorpayPaymentError);

    _cashfree.setCallback(_onCashfreeVerify, _onCashfreeError);

    final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
    purchaseUpdated.listen((event) {
      _listenToPurchaseUpdates(event);
    });
    // initiateHyperSDK();
  }

  void _handleRazorpayPaymentSuccess(PaymentSuccessResponse response) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessPage(
          paymentId: response.paymentId,
          paymentGateway: "razorpay",
          productId: selectedPlan?.id,
          referralCode: referralCode,
          couponCode: _appliedCouponCode,
        ),
      ),
    );
  }

  void _handleRazorpayPaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Payment Failed"),
      ),
    );
  }

  void _showPendingUI(BuildContext context) {
    if (!_pendingDialogVisible) {
      _pendingDialogVisible = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) {},
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: AppColors.colorSurface,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: AppColors.colorInputBorder),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.colorPrimary),
                        SizedBox(height: 20.0),
                        Text(
                          "Processing Your Payment",
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          "Please do not close or navigate away from this page.",
                          style: TextStyle(fontSize: 14.0, color: AppColors.colorTextSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ).then((value) => {_pendingDialogVisible = false});
    }
  }

  void _listenToPurchaseUpdates(List<PurchaseDetails> pdl) async {
    if (!mounted) return;

    for (var purchaseDetails in pdl) {
      print("=============================================");
      print(purchaseDetails.error);
      print(purchaseDetails.pendingCompletePurchase);
      print(purchaseDetails.productID);
      print(purchaseDetails.status);
      print(purchaseDetails.transactionDate);
      print(purchaseDetails.verificationData);
      print("=============================================");
      if (purchaseDetails.status == PurchaseStatus.pending) {
        if (!_pendingDialogVisible && context.mounted) {
          _showPendingUI(context);
          _pendingDialogVisible = true;
        }
        // don’t complete here; wait for a final status
        continue;
      }

      // any non-pending state: dismiss spinner if shown
      if (_pendingDialogVisible && context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _pendingDialogVisible = false;
      }

      // 1️⃣ Handle the status
      switch (purchaseDetails.status) {
        case PurchaseStatus.error:
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Payment Failed, Please Try Again")),
            );
          }
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final receiptData = purchaseDetails.verificationData.serverVerificationData;
          final gateway = purchaseDetails.verificationData.source == 'google_play' ? 'google-in-app' : 'apple-in-app';

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentSuccessPage(
                  paymentId: receiptData,
                  paymentGateway: gateway,
                  productId: selectedPlan?.id,
                  referralCode: referralCode,
                  couponCode: _appliedCouponCode,
                ),
              ),
            );
          }
          break;

        default:
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    }
  }

  @override
  void dispose() {
    _promoController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  void _onCashfreeVerify(String orderId) {
    if (_cashfreeHandled || !mounted) return;
    _cashfreeHandled = true;
    Navigator.pushReplacement(
      preContext,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessPage(
          paymentId: orderId,
          paymentGateway: 'cashfree',
          productId: _cashfreePlanId ?? selectedPlan?.id,
          referralCode: _cashfreeReferralCode ?? referralCode,
          couponCode: _cashfreeCouponCode ?? _appliedCouponCode,
        ),
      ),
    );
  }

  void _onCashfreeError(CFErrorResponse errorResponse, String orderId) {
    if (_cashfreeHandled || !mounted) return;
    _cashfreeHandled = true;
    Navigator.pushReplacement(
      preContext,
      MaterialPageRoute(
        builder: (context) => const PaymentFailurePage(),
      ),
    );
  }

  Future<void> _applyPromoCode() async {
    final code = _promoController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a promo code")),
      );
      return;
    }
    setState(() => _couponLoading = true);
    await NetworkService().post(
      APIPath.validateCoupon,
      {"code": code},
      (data) {
        if (!mounted) return;
        final body = data["body"];
        if (body["valid"] == true) {
          final plansList = body["plans"] as List<dynamic>?;
          final message = body["message"] as String? ?? "Coupon applied.";
          setState(() {
            _appliedCouponCode = code;
            _couponMessage = message;
            if (plansList != null && plansList.isNotEmpty) {
              _plans = plansList.map((p) => SubscriptionPlan.fromJson(Map<String, dynamic>.from(p as Map))).toList();
              selectedPlan = _plans.firstWhereOrNull((e) => e.isDefaultSelected);
              if (selectedPlan == null && _plans.length > 1) selectedPlan = _plans[1];
              if (selectedPlan == null && _plans.isNotEmpty) selectedPlan = _plans.first;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.green),
          );
        } else {
          setState(() {
            _appliedCouponCode = null;
            _couponMessage = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body["message"]?.toString() ?? "Invalid promo code")),
          );
        }
      },
      (error) {
        if (!mounted) return;
        final msg = error is Map && error["body"] != null
            ? (error["body"]["message"] ?? error["body"]["error"] ?? "Invalid promo code").toString()
            : "Invalid promo code";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      },
      () {},
    );
    if (mounted) setState(() => _couponLoading = false);
  }

  void _ensureGuestPlans(User? user) {
    if (user != null || _guestPlansRequested || _plans.isNotEmpty) return;
    _guestPlansRequested = true;
    GuestPlans.load().then((plans) {
      if (!mounted || _basePlans.isNotEmpty) return;
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

  void _clearPromoCode() {
    _promoController.clear();
    setState(() {
      _appliedCouponCode = null;
      _couponMessage = null;
      if (_basePlans.isNotEmpty) {
        _plans = List<SubscriptionPlan>.from(_basePlans);
        selectedPlan = _plans.firstWhereOrNull((e) => e.isDefaultSelected);
        if (selectedPlan == null && _plans.length > 1) selectedPlan = _plans[1];
        if (selectedPlan == null && _plans.isNotEmpty) selectedPlan = _plans.first;
      }
    });
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
                if (_basePlans.isEmpty || _plans.any((plan) => plan.id.startsWith('guest-'))) {
                  _basePlans = List<SubscriptionPlan>.from(allPlans);
                  _plans = List<SubscriptionPlan>.from(allPlans);
                }
              } else {
                _ensureGuestPlans(user);
              }
              if (selectedPlan == null || (_plans.isNotEmpty && !_plans.any((plan) => plan.id == selectedPlan?.id))) {
                selectedPlan = _plans.firstWhereOrNull(
                  (element) => element.isDefaultSelected,
                );
                if (selectedPlan == null && _plans.length > 1) {
                  selectedPlan = _plans[1];
                }
                if (selectedPlan == null && _plans.isNotEmpty) {
                  selectedPlan = _plans.first;
                }

                _ids = _plans.map((plan) => plan.iapId).where((id) => id.isNotEmpty).toSet();
                _ids.addAll(_plans.map((plan) => plan.id).where((id) => !id.startsWith('guest-')).toSet());
                _enabledMethods = Set<String>.from(snapshot.data?['enabled_methods'] ?? const <String>{});
                if (_ids.isNotEmpty && _products.isEmpty) {
                  InAppPurchase.instance.isAvailable().then((available) {
                    if (available) {
                      _inAppPurchase.queryProductDetails(_ids).then((response) {
                        if (mounted) {
                          setState(() {
                            _products = response.productDetails;
                          });
                        }
                      });
                    } else {
                      if (_ids.contains('gbs')) {
                        _ids.remove('gbs');
                      }
                    }
                  });
                }
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
                  if (plan == null) return;
                  setState(() => selectedPlan = plan);
                  _showPlanPopup(user, plan, null);
                },
                promo: PromoCodeBar(
                  expanded: _showPromoInput,
                  appliedCouponCode: _appliedCouponCode,
                  couponMessage: _couponMessage,
                  loading: _couponLoading,
                  controller: _promoController,
                  onExpand: () => setState(() => _showPromoInput = true),
                  onApply: _applyPromoCode,
                  onClear: _clearPromoCode,
                ),
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

  void _showPlanPopup(User? user, SubscriptionPlan plan, String? code) async {
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

    final activeMethods = _enabledMethods;
    print("============");
    print(_enabledMethods);
    print("============");
    if (activeMethods.length == 1) {
      final singleMethod = activeMethods.first;
      _handlePayment(singleMethod, user, plan, code);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => PaymentBottomSheetWidget(
        plan: plan,
        enabledMethods: _enabledMethods,
        onMethodSelection: (method) async {
          _handlePayment(method, user, plan, code);
        },
      ),
    );
  }

  Future<void> _handlePayment(String method, User user, SubscriptionPlan plan, String? code) async {
    if (method == "razorpay") {
      final body = <String, dynamic>{"object_id": plan.id, 'referral_code': code};
      if (_appliedCouponCode != null && _appliedCouponCode!.isNotEmpty) {
        body['coupon_code'] = _appliedCouponCode;
      }
      await NetworkService().post(
        APIPath.createRazorpayCharge,
        body,
        (data) {
          _razorpay.open(data['body']['options']);
        },
        (error) {},
        () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please wait while we process your order"),
            ),
          );
        },
      );
    } else if (method == 'sabpaisa') {
      await NetworkService().post(
        APIPath.createSabpaisaCharge,
        {"object_id": plan.id},
        (data) {
          paymentId = data['body']['data'];
          final options = data['body']['options'];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SabpaisaCheckoutPage(
                checkoutUrl: options['checkout_url'],
                returnUrl: options['return_url'] ?? '',
                onCompleted: _handleSabpaisaPaymentSuccess,
              ),
            ),
          );
        },
        (error) {},
        () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please wait while we process your order"),
            ),
          );
        },
      );
    } else if (method == "cashfree") {
      final body = <String, dynamic>{"object_id": plan.id, 'referral_code': code};
      if (_appliedCouponCode != null && _appliedCouponCode!.isNotEmpty) {
        body['coupon_code'] = _appliedCouponCode;
      }
      await NetworkService().post(
        APIPath.createCashfreeCharge,
        body,
        (data) {
          final response = data['body'] as Map<String, dynamic>;
          final orderId = (response['order_id'] ?? response['payment_id'] ?? '').toString();
          final paymentSessionId = (response['payment_session_id'] ?? '').toString();
          if (orderId.isEmpty || paymentSessionId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Unable to start Cashfree payment")),
            );
            return;
          }

          _cashfreeHandled = false;
          _cashfreePlanId = plan.id;
          _cashfreeReferralCode = referralCode;
          _cashfreeCouponCode = _appliedCouponCode;

          try {
            final session = CFSessionBuilder()
                .setEnvironment(CFEnvironment.PRODUCTION)
                .setOrderId(orderId)
                .setPaymentSessionId(paymentSessionId)
                .build();
            final checkout = CFWebCheckoutPaymentBuilder().setSession(session).build();
            _cashfree.doPayment(checkout);
          } on CFException {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Unable to start Cashfree payment")),
            );
          }
        },
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unable to start Cashfree payment")),
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
    } else if (method == "stripe") {
      await NetworkService().post(
        APIPath.createStripeCharge,
        {"object_id": plan.id, 'referral_code': code},
        (data) async {
          data = data['body'];
          final paymentId = data['payment_id'];
          Stripe.publishableKey = data["client_id"];
          await _stripe.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: data["client_secret"],
              style: ThemeMode.dark,
              merchantDisplayName: AppText.appName,
            ),
          );
          await _stripe.presentPaymentSheet();
          try {
            _stripe.confirmPaymentSheetPayment();
            if (!mounted) return;
            Navigator.pushReplacement(
              preContext,
              MaterialPageRoute(
                builder: (context) => PaymentSuccessPage(
                  paymentId: paymentId,
                  paymentGateway: 'stripe',
                  productId: selectedPlan?.id,
                  referralCode: referralCode,
                  couponCode: _appliedCouponCode,
                ),
              ),
            );
          } catch (error) {
            if (!mounted) return;
            Navigator.pushReplacement(
              preContext,
              MaterialPageRoute(
                builder: (context) => const PaymentFailurePage(),
              ),
            );
          }
        },
        (error) {},
        () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please wait while we process your order"),
            ),
          );
        },
      );
    } else if (method == "gpb") {
      final payload = '${user.id}-${plan.id}-$code';
      final PurchaseParam _param = PurchaseParam(
        productDetails: _products.firstWhere((element) => element.id == plan.iapId),
        applicationUserName: jsonEncode(payload),
      );
      if (plan.isIAPRecurring) {
        _inAppPurchase.buyNonConsumable(purchaseParam: _param);
      } else {
        _inAppPurchase.buyConsumable(purchaseParam: _param);
      }
    } else if (method == "payu") {
      NetworkService().post(
        APIPath.getPayuPaymentParam,
        {"plan_id": plan.id, 'referral_code': code},
        (data) {
          final param = data['body']['message'];
          final merchantName = data['body']['merchant_name'];
          _checkoutPro.openCheckoutScreen(
            payUPaymentParams: param,
            payUCheckoutProConfig: {
              PayUCheckoutProConfigKeys.merchantName: merchantName,
            },
          );
        },
        (error) {
          print("======");
          print(error);
          print("======");
        },
        () {},
      );
    } else if (method == "juspay") {
      return;
      // await NetworkService().post(
      //   APIPath.createJuspayCharge,
      //   {"object_id": plan.id, 'referral_code': code},
      //   (data) {
      //     final response = data['body']['sdk_data'];
      //     paymentId = data['body']['payment_id'];
      //     final sdkPayload = response['sdk_payload'];
      //     print("=================");
      //     print(sdkPayload);
      //     callProcess(sdkPayload);
      //     print("=================");
      //   },
      //   (error) {},
      //   () {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(
      //         content: Text("Please wait while we process your order"),
      //       ),
      //     );
      //   },
      // );
    }
  }

  @override
  generateHash(Map response) async {
    await NetworkService().post(APIPath.generatePayuHash, {"data": response}, (data) {
      _checkoutPro.hashGenerated(hash: data['body']);
    }, (error) {}, () {});
  }

  @override
  onError(Map? response) {}

  @override
  onPaymentCancel(Map? response) {}

  @override
  onPaymentFailure(response) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentFailurePage(),
      ),
    );
  }

  @override
  onPaymentSuccess(response) {
    final payuResponse = jsonDecode(response['payuResponse']);
    final txnId = payuResponse['txnid'];
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessPage(
          paymentId: txnId,
          paymentGateway: 'payu',
          productId: selectedPlan?.id,
          referralCode: referralCode,
          couponCode: _appliedCouponCode,
        ),
      ),
    );
  }

// void initiateHyperSDK() async {
//   var initiatePayload = {
//     "requestId": const Uuid().v4(),
//     "service": "in.juspay.hyperpay",
//     "payload": {"action": "initiate", "merchantId": "", "clientId": "", "environment": "sandbox"}
//   };
//   if (!await sdk.isInitialised()) {
//     await sdk.initiate(initiatePayload, initiateCallbackHandler);
//   }
// }

// void initiateCallbackHandler(MethodCall methodCall) {
//   print("=======================");
//   print(methodCall.method);
//   print("=======================");
//   if (methodCall.method == "initiate_result") {
//     // check initiate result
//   }
// }

// void callProcess(dynamic sdkBody) async {
//   await sdk.process(sdkBody, hyperSDKCallbackHandler);
// }

  void _handleSabpaisaPaymentSuccess() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessPage(
          paymentId: paymentId,
          paymentGateway: 'sabpaisa',
          productId: selectedPlan?.id,
          referralCode: referralCode,
          couponCode: _appliedCouponCode,
        ),
      ),
    );
  }

// void hyperSDKCallbackHandler(MethodCall methodCall) {
//   switch (methodCall.method) {
//     case "hide_loader":
//       break;
//     case "process_result":
//       var args = {};
//
//       try {
//         args = json.decode(methodCall.arguments);
//       } catch (e) {
//         print("==================================++");
//         print(e);
//         print("==================================++");
//       }
//
//       var error = args["error"] ?? false;
//       var innerPayload = args["payload"] ?? {};
//
//       var status = innerPayload["status"] ?? " ";
//       var pi = innerPayload["paymentInstrument"] ?? " ";
//       var pig = innerPayload["paymentInstrumentGroup"] ?? " ";
//       // error -> bool
//       // status -> charged
//       // innerPayload -> payment method details
//       // pi -> payment instrument
//       // pig -> payment method
//       print("==================================--");
//       print(error);
//       print(status);
//       print(innerPayload);
//       print(pi);
//       print(pig);
//       print("==================================--");
//
//       if (!error) {
//         switch (status) {
//           case "charged":
//             {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => PaymentSuccessPage(
//                     paymentId: paymentId,
//                     paymentGateway: 'juspay',
//                     productId: selectedPlan?.id,
//                     referralCode: referralCode,
//                   ),
//                 ),
//               );
//             }
//             break;
//           case "cod_initiated":
//             {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => PaymentSuccessPage(
//                     paymentId: "paymentId",
//                     paymentGateway: 'juspay',
//                     productId: selectedPlan?.id,
//                     referralCode: referralCode,
//                   ),
//                 ),
//               );
//             }
//             break;
//         }
//       } else {
//         var errorCode = args["errorCode"] ?? " ";
//         var errorMessage = args["errorMessage"] ?? " ";
//
//         // WidgetsBinding.instance.addPostFrameCallback((_) {
//         //   Navigator.pushReplacement(context,
//         //       MaterialPageRoute(builder: (context) => const PaymentSuccessPage(paymentId: "paymentId")));
//         // });
//         switch (status) {
//           case "backpressed":
//             // user back-pressed from PP without initiating any txn
//             break;
//           case "user_aborted":
//             {
//               // user initiated a txn and pressed back
//               // check order status via S2S API
//             }
//             break;
//           case "pending_vbv":
//             {}
//             break;
//           case "authorizing":
//             {
//               // txn in pending state
//               // check order status via S2S API
//             }
//             break;
//           case "authorization_failed":
//             {}
//             break;
//           case "authentication_failed":
//             {}
//             break;
//           case "api_failure":
//             {
//               // txn failed
//               // check order status via S2S API
//             }
//             break;
//           case "new":
//             {
//               // order created but txn failed
//               // check order status via S2S API
//             }
//             break;
//           default:
//             {}
//         }
//       }
//   }
// }
}
