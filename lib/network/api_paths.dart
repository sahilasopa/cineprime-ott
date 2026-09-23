enum APIPath {
  getUserDetails,
  getConfig,
  getAllShelves,
  getSectionHomepage,
  completeLogin,
  getVideoUrl,
  updateProfile,
  getPlansList,
  getPurchaseHistory,
  contactUs,
  updateFCMToken,
  createRazorpayCharge,
  createSabpaisaCharge,
  createCashfreeCharge,
  createJuspayCharge,
  createStripeCharge,
  pollPaymentStatus,
  pollEmailVerificationStatus,
  googleSignIn,
  facebookSignIn,
  appleSignIn,
  emailExistence,
  sendOTP,
  verifyOTP,
  emailLogin,
  emailRegistration,
  logout,
  resendConfirmationEmail,
  forgotPassword,
  deleteAccount,
  reels,
  generatePayuHash,
  getPayuPaymentParam,
  getReels,
  continueWatching,
  removeContinueWatching,
  validateApplePayment,
  validateReferralCode,
  validateCoupon,
  inAppNotifications,
  getCountry,
  notificationCampaignEvent,
  externalItemClick,
}

class APIPathHelper {
  // static const String _domain = "https://sahilasopa.pagekite.me";
  // static const String _domain = "https://warm-leopard-uniquely.ngrok-free.app";

  static const String _domain = "https://butterflyott.com";
  static const String plansPageUrl = "$_domain/plans";
  static const String _authBasePath = "$_domain/api/v1/auth";
  static const String _paymentsBasePath = "$_domain/api/v1/payments";
  static const String _mediaBasePath = "$_domain/api/v1/media";

  static String getValue(APIPath path) {
    switch (path) {
      case APIPath.getUserDetails:
        return "$_authBasePath/get/user";
      case APIPath.updateProfile:
        return "$_authBasePath/post/update/profile";
      case APIPath.getPlansList:
        return "$_authBasePath/get/plans/v2";
      case APIPath.contactUs:
        return "$_authBasePath/post/contact-us";
      case APIPath.updateFCMToken:
        return "$_authBasePath/post/update/fcm-token";
      case APIPath.googleSignIn:
        return "$_authBasePath/post/google-sign-in";
      case APIPath.facebookSignIn:
        return "$_authBasePath/post/facebook-sign-in";
      case APIPath.appleSignIn:
        return "$_authBasePath/post/apple-sign-in";
      case APIPath.emailRegistration:
        return "$_authBasePath/post/email/register";
      case APIPath.pollEmailVerificationStatus:
        return "$_authBasePath/get/email-verification-status";
      case APIPath.resendConfirmationEmail:
        return "$_authBasePath/get/resend-confirmation-email";
      case APIPath.forgotPassword:
        return "$_authBasePath/post/forgot-password";
      case APIPath.sendOTP:
        return "$_authBasePath/post/otp/send";
      case APIPath.verifyOTP:
        return "$_authBasePath/post/otp/verify";
      case APIPath.deleteAccount:
        return "$_authBasePath/post/delete/account";
      case APIPath.completeLogin:
        return "$_authBasePath/post/complete/login";
      case APIPath.logout:
        return "$_authBasePath/post/logout";
      case APIPath.getPurchaseHistory:
        return "$_authBasePath/get/user/plans";
      case APIPath.inAppNotifications:
        return "$_authBasePath/get/notifications";
      case APIPath.notificationCampaignEvent:
        return "$_authBasePath/post/notification-campaign-event/";
      case APIPath.validateReferralCode:
        return "$_authBasePath/post/validate/referral-code";
      case APIPath.validateCoupon:
        return "$_authBasePath/post/validate/coupon";
      case APIPath.getConfig:
        return "$_authBasePath/get/config";

      // Media-related endpoints
      case APIPath.getAllShelves:
        return "$_mediaBasePath/get/all/shelves";
      case APIPath.getSectionHomepage:
        return "$_mediaBasePath/get/section-homepage-mobile";
      case APIPath.getVideoUrl:
        return "$_mediaBasePath/get/video/url";
      case APIPath.getReels:
        return "$_mediaBasePath/get/reels";
      case APIPath.continueWatching:
        return "$_mediaBasePath/post/continue-watching";
      case APIPath.removeContinueWatching:
        return "$_mediaBasePath/remove/continue-watching";

      // Payments-related endpoints
      case APIPath.createSabpaisaCharge:
        return "$_paymentsBasePath/get/sabpaisa/charge";
      case APIPath.createRazorpayCharge:
        return "$_paymentsBasePath/get/razorpay/charge";
      case APIPath.createCashfreeCharge:
        return "$_paymentsBasePath/get/cashfree/charge";
      case APIPath.pollPaymentStatus:
        return "$_paymentsBasePath/get/payment/status";
      case APIPath.generatePayuHash:
        return "$_paymentsBasePath/get/payu/hash";
      case APIPath.getPayuPaymentParam:
        return "$_paymentsBasePath/get/payu/param";
      case APIPath.createJuspayCharge:
        return "$_paymentsBasePath/post/juspay/session";
      case APIPath.createStripeCharge:
        return "$_paymentsBasePath/get/stripe/charge";
      case APIPath.getCountry:
        return "https://api.country.is";
      default:
        return _mediaBasePath;
    }
  }

  static String getExternalItemClickUrl(String externalItemId) {
    return "$_mediaBasePath/external-item/$externalItemId/click/";
  }
}
