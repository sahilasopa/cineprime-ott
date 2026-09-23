import 'package:intl/intl.dart';

class UserSubscription {
  late String planName;
  late int planValue;
  late String status;
  late String orderId;
  late DateTime startTime;
  late DateTime endTime;
  late String validity;

  UserSubscription(
      this.planName,
      this.status,
      this.startTime,
      this.endTime,
      );

  UserSubscription.fromJson(Map<String, dynamic> json) {
    planName = json['plan_name'];
    status = json['status'];
    startTime = DateTime.parse(json['start_date']);
    endTime = DateTime.parse(json['end_date']);
    planValue = json['plan_value'];
    orderId = json['order_id'];
    validity = json['plan_validity'];
  }

  String getDisplayEndTime() {
    return formatDateYY(endTime);
  }

  String getDisplayStartTime() {
    return formatDateYY(startTime);
  }

  String formatDate(DateTime dateTime) {
    return DateFormat('dd MMMM').format(dateTime.toLocal());
  }

  String formatDateYY(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime.toLocal());
  }
}

