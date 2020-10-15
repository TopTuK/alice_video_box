import 'package:alice_video_box/models/alice_service.dart';
import 'package:alice_video_box/models/connection_service.dart';
import 'package:alice_video_box/models/http_service.dart';
import 'package:alice_video_box/models/onboarding_service.dart';
import 'package:get_it/get_it.dart';

GetIt gServiceLocator = GetIt.instance;

void registeServices() {
  gServiceLocator
    ..registerLazySingleton<OnboardingService>(() => new OnboardingService())
    ..registerLazySingleton<ConnectionService>(() => new ConnectionService())
    ..registerLazySingleton<AliceStationService>(() => new AliceStationService())
    ..registerLazySingleton<HttpService>(() => new HttpService());
}
