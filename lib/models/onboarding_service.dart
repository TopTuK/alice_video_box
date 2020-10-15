import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _PREF_ONBOARDING = 'show_onboarding';

  OnboardingService();

  Future<bool> isShowOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return (prefs.getBool(_PREF_ONBOARDING) ?? true);
  }

  Future<bool> saveShowOnboarding({bool showOnboarding = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return await prefs.setBool(_PREF_ONBOARDING, showOnboarding);
  }
}