import 'package:flutter/services.dart';
import 'package:eventify/eventify.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform;
import 'dart:convert';


class SabPaisa {
  // Response codes from platform
  static const _CODE_PAYMENT_SUCCESS = 0;
  static const _CODE_PAYMENT_ERROR = 1;

  // Event names
  static const EVENT_PAYMENT_SUCCESS = 'payment.success';
  static const EVENT_PAYMENT_ERROR = 'payment.error';

  // Payment error codes
  static const NETWORK_ERROR = 0;
  static const INVALID_OPTIONS = 1;
  static const PAYMENT_CANCELLED = 2;
  static const TLS_ERROR = 3;
  static const INCOMPATIBLE_PLUGIN = 4;
  static const UNKNOWN_ERROR = 100;

  static const MethodChannel _channel = const MethodChannel('sabpaisa_flutter');

  // EventEmitter instance used for communication
  late EventEmitter _eventEmitter;

  SabPaisa(String key) {
    _eventEmitter = new EventEmitter();
    // _setKeyID(key);
  }




  ///Set KeyId function
  void _setKeyID(String keyID) async {
    await _channel.invokeMethod('setKeyID', keyID);
  }

  /// Opens SabPaisa checkout
  void open(Map<String, dynamic> options) async {
  
    if (Platform.isAndroid) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      // _channel.invokeMethod('setPackageName', packageInfo.packageName);
    }

    var response = await _channel.invokeMethod('open', options);
    _handleResult(response);
  }

  /// Handles checkout response from platform
  void _handleResult(Map<dynamic, dynamic> response) {
    String eventName;

    Map<String, dynamic> jsonMap = jsonDecode(response["data"]);

    dynamic payload;

    switch (response['type']) {
      case _CODE_PAYMENT_SUCCESS:
        eventName = EVENT_PAYMENT_SUCCESS;
        payload = TransactionResponsesModel.fromMap(jsonMap);
        break;

      case _CODE_PAYMENT_ERROR:
        eventName = EVENT_PAYMENT_ERROR;
        payload = TransactionResponsesModel.fromMap(jsonMap);
        break;

      default:
        eventName = 'error';
        payload = TransactionResponsesModel();
    }

    _eventEmitter.emit(eventName, null, payload);
  }

  /// Registers event listeners for payment events
  void on(String event, Function handler) {
    EventCallback cb = (event, cont) {
      handler(event.eventData);
    };
    _eventEmitter.on(event, null, cb);
    // _resync();
  }

  /// Clears all event listeners
  void clear() {
    _eventEmitter.clear();
  }

  /// Retrieves lost responses from platform
  void _resync() async {
    var response = await _channel.invokeMethod('resync');
    if (response != null) {
      _handleResult(response);
    }
  }
}

class TransactionResponsesModel {
  String? payerName;
  String? payerEmail;
  String? payerMobile;
  String? clientTxnId;
  String? payerAddress;
  String? amount;
  String? clientCode;
  String? paidAmount;
  String? paymentMode;
  String? bankName;
  String? amountType;
  String? status;
  String? statusCode;
  String? challanNumber;
  String? sabpaisaTxnId;
  String? sabpaisaMessage;
  String? bankMessage;
  String? bankErrorCode;
  String? sabpaisaErrorCode;
  String? bankTxnId;
  String? transDate;
  String? udf1;
  String? udf2;
  String? udf3;
  String? udf4;
  String? udf5;
  String? udf6;
  String? udf7;
  String? udf8;
  String? udf9;
  String? udf10;
  String? udf11;
  String? udf12;
  String? udf13;
  String? udf14;
  String? udf15;
  String? udf16;
  String? udf17;
  String? udf18;
  String? udf19;
  String? udf20;

  TransactionResponsesModel({
    this.payerName,
    this.payerEmail,
    this.payerMobile,
    this.clientTxnId,
    this.payerAddress,
    this.amount,
    this.clientCode,
    this.paidAmount,
    this.paymentMode,
    this.bankName,
    this.amountType,
    this.status,
    this.statusCode,
    this.challanNumber,
    this.sabpaisaTxnId,
    this.sabpaisaMessage,
    this.bankMessage,
    this.bankErrorCode,
    this.sabpaisaErrorCode,
    this.bankTxnId,
    this.transDate,
    this.udf1,
    this.udf2,
    this.udf3,
    this.udf4,
    this.udf5,
    this.udf6,
    this.udf7,
    this.udf8,
    this.udf9,
    this.udf10,
    this.udf11,
    this.udf12,
    this.udf13,
    this.udf14,
    this.udf15,
    this.udf16,
    this.udf17,
    this.udf18,
    this.udf19,
    this.udf20,
  });

  factory TransactionResponsesModel.fromMap(Map<dynamic, dynamic> map) {
    return TransactionResponsesModel(
      payerName: map['payerName'],
      payerEmail: map['payerEmail'],
      payerMobile: map['payerMobile'],
      clientTxnId: map['clientTxnId'],
      payerAddress: map['payerAddress'],
      amount: map['amount'],
      clientCode: map['clientCode'],
      paidAmount: map['paidAmount'],
      paymentMode: map['paymentMode'],
      bankName: map['bankName'],
      amountType: map['amountType'],
      status: map['status'],
      statusCode: map['statusCode'],
      challanNumber: map['challanNumber'],
      sabpaisaTxnId: map['sabpaisaTxnId'],
      sabpaisaMessage: map['sabpaisaMessage'],
      bankMessage: map['bankMessage'],
      bankErrorCode: map['bankErrorCode'],
      sabpaisaErrorCode: map['sabpaisaErrorCode'],
      bankTxnId: map['bankTxnId'],
      transDate: map['transDate'],
      udf1: map['udf1'],
      udf2: map['udf2'],
      udf3: map['udf3'],
      udf4: map['udf4'],
      udf5: map['udf5'],
      udf6: map['udf6'],
      udf7: map['udf7'],
      udf8: map['udf8'],
      udf9: map['udf9'],
      udf10: map['udf10'],
      udf11: map['udf11'],
      udf12: map['udf12'],
      udf13: map['udf13'],
      udf14: map['udf14'],
      udf15: map['udf15'],
      udf16: map['udf16'],
      udf17: map['udf17'],
      udf18: map['udf18'],
      udf19: map['udf19'],
      udf20: map['udf20'],
    );
  }

  Map<String, dynamic> toMap() {
  return {
    'payerName': payerName,
    'payerEmail': payerEmail,
    'payerMobile': payerMobile,
    'clientTxnId': clientTxnId,
    'payerAddress': payerAddress,
    'amount': amount,
    'clientCode': clientCode,
    'paidAmount': paidAmount,
    'paymentMode': paymentMode,
    'bankName': bankName,
    'amountType': amountType,
    'status': status,
    'statusCode': statusCode,
    'challanNumber': challanNumber,
    'sabpaisaTxnId': sabpaisaTxnId,
    'sabpaisaMessage': sabpaisaMessage,
    'bankMessage': bankMessage,
    'bankErrorCode': bankErrorCode,
    'sabpaisaErrorCode': sabpaisaErrorCode,
    'bankTxnId': bankTxnId,
    'transDate': transDate,
    'udf1': udf1,
    'udf2': udf2,
    'udf3': udf3,
    'udf4': udf4,
    'udf5': udf5,
    'udf6': udf6,
    'udf7': udf7,
    'udf8': udf8,
    'udf9': udf9,
    'udf10': udf10,
    'udf11': udf11,
    'udf12': udf12,
    'udf13': udf13,
    'udf14': udf14,
    'udf15': udf15,
    'udf16': udf16,
    'udf17': udf17,
    'udf18': udf18,
    'udf19': udf19,
    'udf20': udf20,
  };
  }
}

class ExternalWalletResponse {
  String? walletName;

  ExternalWalletResponse(this.walletName);

  static ExternalWalletResponse fromMap(Map<dynamic, dynamic> map) {
    var walletName = map["external_wallet"] as String?;
    return new ExternalWalletResponse(walletName);
  }
}
