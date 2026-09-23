import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cineprime/models/subscription_plan.dart';
import 'package:cineprime/models/user/user.dart';
import 'package:cineprime/models/user/user_subscription.dart';
import 'package:cineprime/network/api_paths.dart';
import 'package:cineprime/services/authentication_service.dart';
import 'package:cineprime/services/network_service.dart';

typedef OnSuccessCallback = void Function(User user);
typedef OnFailureCallback = void Function(dynamic error);

class AuthenticationProvider extends ChangeNotifier {
  AuthenticationService authenticationService = AuthenticationService();
  User? _user;
  List<SubscriptionPlan> _plans = [];
  List<UserSubscription> _allPlans = [];
  Set<String> _enabledPaymentMethods = {};

  Future<void> init(OnSuccessCallback onSuccess, OnFailureCallback onFailure, {bool sync = false}) async {
    await authenticationService.getCountry();
    final sessionId = await authenticationService.getSessionId();
    if (sessionId == null || sessionId == "null" || sessionId == "anonymous_user") {
      onFailure({});
      return;
    }
    await NetworkService().get(APIPath.getUserDetails, headers: {"sync": sync ? "yes" : "no"}, (data) async {
      _user = User.fromJson(data['body']);
      if (_user!.userSubscription == null) {
        getPlansListAndEnabledMethods();
      }
      authenticationService.setUser(_user!);
      onSuccess(_user!);
      notifyListeners();
    }, (error) {
      authenticationService.saveSessionId(null);
      onFailure(
        {},
      );
    }, () {}, maxRetries: 100);
  }

  Future<Map<String, dynamic>> getPlansListAndEnabledMethods() async {
    if (_plans.isEmpty) {
      await NetworkService().get(
        APIPath.getPlansList,
        (data) {
          // Show all plans regardless of subscription state
          _plans = (data["body"]["message"] as List).map((data) => SubscriptionPlan.fromJson(data)).toList();
          _enabledPaymentMethods = Set<String>.from(data["body"]["enabled_methods"]);
        },
        (error) {},
        () {},
      );
      return {"plans": _plans, "enabled_methods": _enabledPaymentMethods};
    }
    // Return cached plans without filtering
    return {"plans": _plans, "enabled_methods": _enabledPaymentMethods};
  }

  Future<List<UserSubscription>> getPurchaseHistory() async {
    if (_allPlans.isEmpty) {
      await NetworkService().get(
        APIPath.getPurchaseHistory,
        (data) {
          _allPlans = (data["body"]['message'] as List).map((data) => UserSubscription.fromJson(data)).toList();
        },
        (error) {},
        () {},
      );
      return _allPlans;
    }
    return _allPlans;
  }

  Future<void> saveUserToken(String token, {bool notify = true, dynamic userJson}) async {
    await authenticationService.saveSessionId(token);
    if (userJson != null) {
      _user = User.fromJson(userJson);
      getPlansListAndEnabledMethods();
      notifyListeners();
    } else {
      await init(
        (user) {
          if (notify) {
            notifyListeners();
          }
        },
        (error) {},
      );
    }
  }

  void updateUsername(String username) {
    if (_user != null) {
      _user!.username = username;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await authenticationService.logout();
    GoogleSignIn().signOut();
    _user = null;
    notifyListeners();
  }

  Future<String?> getUid() async {
    return await authenticationService.getSessionId();
  }

  User? getUser() {
    return _user;
  }

  void pollPaymentStatus(String? paymentId, String paymentGateway, String? referralCode, String? couponCode, String productId, OnSuccessCallback onSuccess, OnFailureCallback onFailureCallback) async {
    bool success = false;
    if (paymentId == null) {
      return;
    }
    for (int i = 0; i < 30; i++) {
      final body = <String, String>{
        "Payment-Id": paymentId,
        'Payment-Gateway': paymentGateway,
        'Referral-Code': referralCode ?? '',
        'Product-Id': productId,
      };
      if (couponCode != null && couponCode.isNotEmpty) {
        body['Coupon-Code'] = couponCode;
      }
      await NetworkService().post(
        APIPath.pollPaymentStatus,
        body,
        (data) {
          success = true;
          _user = User.fromJson(data['body']);
          authenticationService.setUser(_user!);
          onSuccess(_user!);
          notifyListeners();
        },
        (error) async {},
        () {},
      );
      if (success) {
        return;
      } else {
        await Future.delayed(const Duration(seconds: 3));
      }
    }
    onFailureCallback({});
  }
}
