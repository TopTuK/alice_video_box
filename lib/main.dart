import 'package:alice_video_box/blocs/appstate_bloc.dart';
import 'package:alice_video_box/models/navigation_service.dart';
import 'package:alice_video_box/screens/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'models/service_locator.dart';

void main() {
  registeServices();
  runApp(new EasyLocalization(
    supportedLocales: [Locale('en', 'US'), Locale('ru', 'RU')],
    path: 'assets/translations',
    fallbackLocale: Locale('en', 'US'),
    child: new AliceBoxApp(), 
  ));
}

class AliceBoxApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Provider<AppStateBloc>(
      create: (_) => new AppStateBloc(),
      dispose: (ctx, appState) => appState.dispose(),
      child: new MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: 'Alice video box',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: new LandingScreen(),
        routes: NavigationService.getRoutes(),
      ),
    );
  }
}
