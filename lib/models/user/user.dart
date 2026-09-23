import 'package:cineprime/models/user/user_subscription.dart';

class User {
  String id;
  String? username;
  String? email;
  String? contactNumber;
  bool canDownload;
  bool canUpgradePlan;
  String? dob;
  String? fcmToken;
  String referralCode;
  double referralBalance;
  double totalPointsEarned;
  bool emailVerified;
  UserSubscription? userSubscription;

  User({
    required this.id,
    required this.username,
    required this.canDownload,
    required this.canUpgradePlan,
    required this.emailVerified,
    required this.referralBalance,
    required this.totalPointsEarned,
    required this.referralCode,
    this.dob,
    this.email,
    this.contactNumber,
    this.userSubscription,
    this.fcmToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['name'],
      canDownload: json['can_download'],
      canUpgradePlan: json['can_upgrade_plan'],
      email: json['email'],
      dob: json['date_of_birth'],
      contactNumber: json['contact_number'],
      emailVerified: json['email_verified'],
      fcmToken: json['fcm_token'],
      referralBalance: json['referral_balance'] ?? 0,
      totalPointsEarned: json['referral_total'] ?? 0,
      referralCode: json['referral_id'] ?? "NA",
      userSubscription: json["subscription_plan"] != null ? UserSubscription.fromJson(json["subscription_plan"]) : null,
    );
  }

  String getUniqueCredential() {
    if (email != null) {
      if (email!.isNotEmpty) {
        return email!;
      }
    }
    if (contactNumber != null) {
      if (contactNumber!.isNotEmpty) {
        return contactNumber!;
      }
    }
    return "";
  }

  bool compareTo(User other) {
    return id == other.id && username == other.username && email == other.email && fcmToken == other.fcmToken && userSubscription == other.userSubscription;
  }
}
