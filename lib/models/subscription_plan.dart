class SubscriptionPlan {
  final String id;
  final String name;
  final double cost;
  final String currency;
  final double? originalCost;
  final String validity;
  final bool isRecurring;
  final bool isIAPRecurring;
  final String iapId;
  final bool isBestValue;
  final bool isMostPopular;
  final bool isDefaultSelected;
  final String buttonText;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.cost,
    this.originalCost,
    required this.isRecurring,
    required this.isIAPRecurring,
    required this.iapId,
    required this.validity,
    required this.isBestValue,
    required this.isMostPopular,
    required this.buttonText,
    required this.isDefaultSelected,
    required this.currency,
  });

  /// Formats cost for display: whole numbers show as "399", decimals as "399.49".
  static String formatCost(double value) {
    if (value == value.truncateToDouble()) return value.toInt().toString();
    final s = value.toStringAsFixed(2);
    return s.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    print('');
    print(json);
    print('');
    return SubscriptionPlan(
      id: json['id'].toString(),
      name: json['name'],
      cost: (json['cost'] as num).toDouble(),
      originalCost: json['original_cost'] != null ? (json['original_cost'] as num).toDouble() : null,
      validity: json['validity'],
      isRecurring: json['is_recurring'] ?? false,
      iapId: json['iap_id'] ?? json['id'],
      isBestValue: json['is_best_value'] ?? true,
      isMostPopular: json['is_most_popular'] ?? false,
      buttonText: () {
        final v = json['button_text']?.toString().trim();
        return (v == null || v.isEmpty) ? 'Subscribe Now' : v;
      }(),
      isDefaultSelected: json['is_default_selected'] ?? false,
      currency: json['currency'] ?? "₹",
      isIAPRecurring: json['is_iap_recurring'] ?? false
    );
  }
}
