import 'package:http/http.dart' as http;
import 'package:cineprime/models/subscription_plan.dart';
import 'package:cineprime/network/api_paths.dart';

/// The plans API requires a signed-in session. The public plans page does not,
/// so guests can still see the current catalogue before they pay.
class GuestPlans {
  static final RegExp _card = RegExp(
    r'<h4 class="plan-name">([^<]+)</h4>[\s\S]*?<span class="amount">([^<]+)</span>\s*<span class="period">/\s*([^<]+)</span>',
  );

  static Future<List<SubscriptionPlan>> load() async {
    try {
      final response = await http.get(Uri.parse(APIPathHelper.plansPageUrl));
      if (response.statusCode != 200) return const [];
      return _parse(response.body);
    } catch (_) {
      return const [];
    }
  }

  static List<SubscriptionPlan> _parse(String html) {
    final plans = <SubscriptionPlan>[];
    for (final match in _card.allMatches(html)) {
      final name = match.group(1)!.trim();
      final cost = double.tryParse(match.group(2)!.trim());
      if (name.isEmpty || cost == null) continue;
      final days = match.group(3)!.trim();
      plans.add(
        SubscriptionPlan(
          id: 'guest-${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}',
          name: name,
          cost: cost,
          currency: '₹',
          validity: _validity(name, days),
          isRecurring: false,
          isIAPRecurring: false,
          iapId: '',
          isBestValue: false,
          isMostPopular: false,
          isDefaultSelected: name.toLowerCase() == 'monthly',
          buttonText: 'Subscribe Now',
        ),
      );
    }
    if (plans.isNotEmpty && plans.every((plan) => !plan.isDefaultSelected)) {
      final first = plans[0];
      plans[0] = SubscriptionPlan(
        id: first.id,
        name: first.name,
        cost: first.cost,
        currency: first.currency,
        validity: first.validity,
        isRecurring: first.isRecurring,
        isIAPRecurring: first.isIAPRecurring,
        iapId: first.iapId,
        isBestValue: first.isBestValue,
        isMostPopular: first.isMostPopular,
        isDefaultSelected: true,
        buttonText: first.buttonText,
      );
    }
    return plans;
  }

  static String _validity(String name, String days) {
    switch (days) {
      case '7':
        return '1 Week';
      case '30':
        return '1 Month';
      case '180':
        return '6 Months';
      case '360':
      case '365':
        return '1 Year';
      default:
        return name;
    }
  }
}
