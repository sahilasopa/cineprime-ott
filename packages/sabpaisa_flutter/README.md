# SabPaisa Flutter

Flutter plugin for SabPaisa SDK.

[![pub package](https://img.shields.io/pub/v/sabpaisa_flutter.svg)](https://pub.dartlang.org/packages/sabpaisa_flutter)

- [Getting Started](#getting-started)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)
- [API](#api)
- [Example App](https://gitlab.com/eywa-public/sabpaisaplugins2025examples/flutter-example)

## Getting Started

This flutter plugin is a wrapper around our Android and iOS SDKs.


## Installation

This plugin is available on Pub: [https://pub.dev/packages/sabpaisa_flutter](https://pub.dev/packages/sabpaisa_flutter)

Add this to `dependencies` in your app's `pubspec.yaml`

```yaml
sabpaisa_flutter: ^<take_latest_version>
```


**Note for Android**: Make sure that the minimum API level for your app is 19 or higher.

### Proguard rules

If you are using proguard for your builds, you need to add following lines to proguard files

```
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
```


**Note for iOS**: Make sure that the minimum deployment target for your app is iOS 10.0 or higher. Also, don't forget to enable bitcode for your project.

Run `flutter packages get` in the root directory of your app.

## Usage

Sample code to integrate can be found in [https://gitlab.com/eywa-public/sabpaisaplugins2025examples/flutter-example](here).

#### Import package

```dart
import 'package:sabpaisa_flutter/sabpaisa_flutter.dart';
```

#### Create SabPaisa instance

```dart
sabpaisa = SabPaisa("sabpaisa_test_BBktfVGtrhWaQ");
```

#### Attach event listeners

The plugin uses event-based communication, and emits events when payment fails or succeeds.

The event names are exposed via the constants `EVENT_PAYMENT_SUCCESS` and `EVENT_PAYMENT_ERROR` from the `SabPaisa` class.

Use the `on(String event, Function handler)` method on the `SabPaisa` instance to attach event listeners.

```dart

sabpaisa.on(SabPaisa.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
sabpaisa.on(SabPaisa.EVENT_PAYMENT_ERROR, _handlePaymentError);
```

The handlers would be defined somewhere as

```dart

void _handlePaymentSuccess(TransactionResponsesModel response) {
  // Do something when payment succeeds
  sabPaisa = SabPaisa("sabpaisa_test_BBktfVGtrhWaQ");
}

void _handlePaymentError(TransactionResponsesModel response) {
  // Do something when payment fails
  sabPaisa = SabPaisa("sabpaisa_test_BBktfVGtrhWaQ");
}

```


#### Setup options

```dart
Map<String, Object> getPaymentOptions() {
    return {
    'first_name': 'firstnameflutter',
            'last_name': 'lastnameflutter',
            'currency': 'INR',
            'mobile_number': '9999999999',
            'email_id': 'lokesh.d@eywa.com',
            'client_code': 'DJ020',
            'aes_iv': 'M+aUFgRMPq7ci+Cmoytp3KJ2GPBOwO72Z2Cjbr55zY7++pT9mLES2M5cIblnBtaX',
            'aes_key': 'ISTrmmDC2bTvkxzlDRrVguVwetGS8xC/UFPsp6w+Itg=',
            'user_name': 'DJL754@sp',
            'password': '4q3qhgmJNM4m',
            'env': 'staging', // staging/prod
            'txn_id': '<Unique Transaction Id>',
            'amount': '1',
            'callback_url': 'http://localhost:8082',
            'udf1': '1',
            'udf2': '2',
            'udf3': '3',
            'udf4': '4',
            'udf5': '5',
            'udf6': '6',
            'udf7': '7',
            'udf8': '8',
            'udf9': '9',
            'udf10': '10',
            'udf11': '11',
            'udf12': '12',
            'udf13': '13',
            'udf14': '14',
            'udf15': '15',
            'udf16': '16',
            'udf17': '17',
            'udf18': '18',
            'udf19': '19',
            'udf20': '20'


    };
  }
```


#### Open Checkout

```dart
late SabPaisa sabPaisa ;

 sabPaisa.on(SabPaisa.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
 sabPaisa.on(SabPaisa.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
 sabPaisa.open(getPaymentOptions());

```

⚙️ Setup (IOS)
Pod Configuration:
Add this line at top of your pod file in "ios/Podfile"

require_relative './.symlinks/plugins/sabpaisa_flutter/lib/scripts/patch_podfile.rb'


And in flutter post install script add below line in "ios/Podfile"

```
SabPaisaPatch.run(installer)
```
Example:

```
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
  SabPaisaPatch.run(installer) #<------only this line you need to add
end
  ```


## Troubleshooting


### Enabling Bitcode

Open `ios/Podfile` and find this section:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
```

Set `config.build_settings['ENABLE_BITCODE'] = 'YES'`.

### Setting Swift version

Add the following line below `config.build_settings['ENABLE_BITCODE'] = 'YES'`:

`config.build_settings['SWIFT_VERSION'] = '5.0'`

### `CocoaPods could not find compatible versions for pod "sabpaisa_flutter"` when running `pod install`

```
Specs satisfying the `sabpaisa_flutter (from
    `.symlinks/plugins/sabpaisa_flutter/ios`)` dependency were found, but they
    required a higher minimum deployment target.
```

This is due to your minimum deployment target being less than iOS 10.0. To change this, open `ios/Podfile` in your project and add/uncomment this line at the top:

```ruby
# platform :ios, '9.0'
```

and change it to

```ruby
platform :ios, '10.0'
```

and run `pod install` again in the `ios` directory.

### iOS build fails with `'sabpaisa_flutter/sabpaisa_flutter-Swift.h' file not found`

Add use_frameworks! in `ios/Podfile` and run `pod install` again in the `ios` directory.

### Gradle build fails with `Error: uses-sdk:minSdkVersion 16 cannot be smaller than version 19 declared in library [:sabpaisa_flutter]`

This is due to your Android minimum SDK version being less than 19. To change this, open `android/app/build.gradle`, find `minSdkVersion` in `defaultConfig` and set it to at least `19`.

### A lot of errors saying `xxxx is not defined for the class 'SabPaisa'`

We export a class `SabPaisa` from `package:sabpaisa_flutter/sabpaisa_flutter.dart`. Check if your code is redeclaring the `SabPaisa` class.


## API

### SabPaisa

#### open(map<String, dynamic> options)

Open SabPaisa Checkout.

The `options` map has `key` as a required property. All other properties are optional.

#### on(String eventName, Function listener)

Register event listeners for payment events.

- `eventName`: The name of the event.
- `listener`: The function to be called. The listener should accept a single argument of the following type:
  - [`PaymentSuccessResponse`](#paymentsuccessresponse) for `EVENT_PAYMENT_SUCCESS`
  - [`PaymentFailureResponse`](#paymentfailureresponse) for `EVENT_PAYMENT_FAILURE`


### PaymentSuccessResponse

| Field Name | Type   | Description                                                                                  |
| ---------- | ------ | -------------------------------------------------------------------------------------------- |
| data       | String | Full payment details object                                                                  |

### PaymentFailureResponse

| Field Name | Type   | Description        |
| ---------- | ------ | ------------------ |
| data       | String | Full payment details object                                                                  |

