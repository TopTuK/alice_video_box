import 'package:alice_video_box/blocs/appstate_bloc.dart';
import 'package:alice_video_box/blocs/device_list_bloc.dart';
import 'package:alice_video_box/blocs/login_bloc.dart';
import 'package:alice_video_box/screens/device_list_screen.dart';
import 'package:alice_video_box/screens/landing_screen.dart';
import 'package:alice_video_box/screens/login_screen.dart';
import 'package:alice_video_box/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NavigationService {
  static const String LANDING = '/landing';
  static const String ONBOARDING = '/onboarding';
  static const String LOGIN = '/login';
  static const String HOME = '/home';

  static Map<String, WidgetBuilder> getRoutes() {
    return <String, WidgetBuilder>{
      NavigationService.LANDING: (ctx) => new LandingScreen(),
      NavigationService.ONBOARDING: (ctx) => new OnboardingScreen(),
      NavigationService.LOGIN: (ctx) => new ProxyProvider<AppStateBloc, LoginStateBloc>(
        update: (_, appStateBloc, __) => new LoginStateBloc(appStateBloc: appStateBloc),
        dispose: (_, loginStateBloc) => loginStateBloc.dispose(),
        child: new LoginScreen(),
      ),
      NavigationService.HOME: (ctx) => new ProxyProvider<AppStateBloc, DeviceListStateBloc>(
        update: (_, appStateBloc, __) => new DeviceListStateBloc(appStateBloc: appStateBloc),
        dispose: (_, deviceListStateBloc) => deviceListStateBloc.dispose(),
        child: new DeviceListScreen(),
      ),
    };
  }

  static void openLandingScreen(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(NavigationService.LANDING);
  }

  static void openOnboardingScreen(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(NavigationService.ONBOARDING);
  }

  static void openLoginScreen(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(NavigationService.LOGIN);
  }

  static void openDeviceListScreen(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(NavigationService.HOME);
  }
}
