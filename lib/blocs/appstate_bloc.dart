import 'dart:async';

import 'package:alice_video_box/models/alice_service.dart';
import 'package:alice_video_box/models/onboarding_service.dart';
import 'package:alice_video_box/models/service_locator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

enum AppState { INIT, LOADING, NOCONNECTION, ONBOARDING, UNATHORIZED, READY }

class AppStateBloc {
  BehaviorSubject<AppState> _appState;

  ValueStream<AppState> get appStateStream => _appState.stream;
  AppState get currentState => _appState.value;

  AppStateBloc() {
    _appState = BehaviorSubject<AppState>.seeded(AppState.INIT);
  }

  void dispose() {
    _appState.close();
  }

  StreamSubscription<AppState> addAppStateListener(Function(AppState appState) onAppStateChanged) {
    return _appState.listen(onAppStateChanged);
  }

  Future _internalCheckLoginStatus() async {
    var aliceService = gServiceLocator<AliceStationService>();
    var authResult = await aliceService.getUserSession();

    if (authResult == AuthResult.SUCCESS) {
      _appState.add(AppState.READY);
    }
    else {
      _appState.add(AppState.UNATHORIZED); 
    }
  }

  Future initialize() async {
    _appState.add(AppState.LOADING);

    var onboardingService = gServiceLocator<OnboardingService>();
    var showOnboarding = await onboardingService.isShowOnboarding();
    if (showOnboarding) {
      _appState.add(AppState.ONBOARDING);
    }
    else {
      await _internalCheckLoginStatus();
    }
  }

  Future completeOnboarding() async {
    _appState.add(AppState.LOADING);

    var onboardingService = gServiceLocator<OnboardingService>();
    await onboardingService.saveShowOnboarding(showOnboarding: false);

    await _internalCheckLoginStatus();
  }

  Future completeLogin() async {
    _appState.add(AppState.READY);
  }

  Future signOut() async {
    var aliceService = gServiceLocator<AliceStationService>();
    aliceService.clearUserSession();
    
    _appState.add(AppState.UNATHORIZED);
  }
}
