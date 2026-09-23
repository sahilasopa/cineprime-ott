# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn com.google.android.gms.auth.api.credentials.Credential
-dontwarn com.google.android.gms.auth.api.credentials.Credentials
-dontwarn com.google.android.gms.auth.api.credentials.CredentialsClient
-dontwarn com.google.android.gms.auth.api.credentials.CredentialsOptions$Builder
-dontwarn com.google.android.gms.auth.api.credentials.CredentialsOptions
-dontwarn com.google.android.gms.auth.api.credentials.HintRequest$Builder
-dontwarn com.google.android.gms.auth.api.credentials.HintRequest
-dontwarn com.payu.cardscanner.PayU
-dontwarn com.payu.cardscanner.callbacks.PayUCardListener
-dontwarn com.payu.olamoney.OlaMoney
-dontwarn com.payu.olamoney.callbacks.OlaMoneyCallback
-dontwarn com.payu.olamoney.utils.PayUOlaMoneyParams
-dontwarn com.payu.olamoney.utils.PayUOlaMoneyPaymentParams
-dontwarn com.payu.ppiscanner.PayUQRScanner
-dontwarn com.payu.ppiscanner.PayUScannerConfig
-dontwarn com.payu.ppiscanner.interfaces.PayUScannerListener
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider
-dontwarn org.conscrypt.Conscrypt
-dontwarn org.slf4j.impl.StaticLoggerBinder
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers

-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}
-optimizations !method/inlining/
-keepclasseswithmembers class * {
  public void onPayment*(...);
}

-keep class com.android.billingclient.** { *; }
-dontwarn com.android.billingclient.**

-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.**

-keep class com.android.billingclient.api.** { *; }

-dontwarn javax.xml.stream.XMLStreamException
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.PaymentsClient
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.Wallet
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.WalletUtils

-keepattributes *Annotation*
-optimizations !method/inlining/
-keep interface retrofit2.* { *; }
-keep class retrofit2.* { *; }
-keepclassmembers interface * {
    @retrofit2.http.* <methods>;
}
-keepattributes Signature
-keepattributes Exceptions

-keepattributes *Annotation*
-dontwarn com.SabPaisa.**
-keep class com.SabPaisa.** {*;}
-optimizations !method/inlining/
-keep class com.sabpaisa.sabpaisa_flutter.** { *; }

# Keep Retrofit interfaces
-keep interface retrofit2.* { *; }
-keep class retrofit2.* { *; }

# Keep methods annotated with Retrofit annotations
-keepclassmembers interface * {
    @retrofit2.http.* <methods>;
}
-keepattributes Signature
-keepattributes Exceptions