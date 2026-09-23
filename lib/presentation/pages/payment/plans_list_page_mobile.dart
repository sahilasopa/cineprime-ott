import 'package:flutter/widgets.dart';
import '../../../platform_utils.dart';
import 'plans_list_page_android.dart' as android;
import 'plans_list_page_ios.dart' as ios;

class PlansListPage extends StatelessWidget {
  const PlansListPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return const ios.PlansListPage();
    }
    return const android.PlansListPage();
  }
}
