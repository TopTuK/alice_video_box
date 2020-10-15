import 'package:alice_video_box/blocs/appstate_bloc.dart';
import 'package:alice_video_box/models/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  @override
  State<LandingScreen> createState() {
    return new _LandingScreen();
  }
}

class _LandingScreen extends State<LandingScreen> {
  Widget _buildLoadingPage() {
    return new Center(
      child: new CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildNoConnectionPage(AppStateBloc appStateBloc) {
    return new Container(
      alignment: Alignment.center,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(
            'No Internet connection',
            style: null
          ),
          new RaisedButton(
            onPressed: () => print('Check connection'),
            child: new Text(
              'Check connection',
              style: null
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appStateBloc = Provider.of<AppStateBloc>(context);

    return new Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.1, 0.4, 0.7, 0.9],
          colors: <Color>[
            Color(0xFF73AEF5),
            Color(0xFF61A4F1),
            Color(0xFF478DE0),
            Color(0xFF398AE5),
          ]
        ),
      ),
      child: new StreamBuilder<AppState>(
        stream: appStateBloc.appStateStream,
        initialData: appStateBloc.currentState,
        builder: (BuildContext ctx, AsyncSnapshot<AppState> snapshot) {
          if(!snapshot.hasData || snapshot.data == null) return Container();

          var appState = snapshot.data;
          switch(appState) {
            case AppState.INIT:
              appStateBloc.initialize();
              return _buildLoadingPage();
            case AppState.LOADING:
              return _buildLoadingPage();
            case AppState.NOCONNECTION:
              return _buildNoConnectionPage(appStateBloc);
            case AppState.ONBOARDING:
              SchedulerBinding.instance.addPostFrameCallback((_) {
                NavigationService.openOnboardingScreen(ctx);
              });
              break;
            case AppState.UNATHORIZED:
              SchedulerBinding.instance.addPostFrameCallback((_) {
                NavigationService.openLoginScreen(ctx);
              });
              break;
            case AppState.READY:
              SchedulerBinding.instance.addPostFrameCallback((_) {
                NavigationService.openDeviceListScreen(ctx);
              });
              break;
          }

          return Container();
        }
      ),
    );
  }
}
