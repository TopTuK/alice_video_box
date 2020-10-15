import 'package:alice_video_box/blocs/appstate_bloc.dart';
import 'package:alice_video_box/models/navigation_service.dart';
import 'package:alice_video_box/screens/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() {
    return new _OnboardingScreen();
  }
}

class _OnboardingScreen extends State<OnboardingScreen> {
  final int _numPages = 3;
  final PageController _pageController = new PageController(initialPage: 0);
  int _currentPageIndex = 0;

  void _onSkipPressed(AppStateBloc appStateBloc) {
    appStateBloc.completeOnboarding();
  }

  Widget _buildBottomSheet(AppStateBloc appStateBloc) {
    if (_currentPageIndex == (_numPages - 1)) {
      return new Container(
        height: 100.0,
        width: double.infinity,
        color: Colors.white,
        child: new GestureDetector(
          onTap: () {
            appStateBloc.completeOnboarding();
          },
          child: new Center(
            child: new Padding(
              padding: EdgeInsets.only(bottom: 30.0),
              child: new Text(
                'onboarding_start',
                style: new TextStyle(
                  color: Color(0xFF5B16D0),
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                )
              ).tr(),
            ),
          ),
        ),
      );
    }

    return null;
  }

  Widget _buildIndicator(bool isActive) {
    return new AnimatedContainer(
      duration: new Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 10.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Color(0xFF7B51D3),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    return List<Widget>.generate(
      _numPages, 
      (index) => (index == _currentPageIndex) ? _buildIndicator(true) : _buildIndicator(false)
    );
  }

  Widget _buildFirstPage() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Center(
          child: new Image.asset('assets/graphics/watch_video_1.jpg')
        ),
        const SizedBox(height: 5.0,),
        new Text(
          'onboardingTitle1',
          style: cTitleStyle
        ).tr(),
        const SizedBox(height: 20.0,),
        new Text(
          'onboardingText1',
          style: cSubtitleStyle
        ).tr()
      ],
    );
  }

  Widget _buildSecondPage() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Center(
          child: new Image.asset('assets/graphics/watch_video_2.jpg')
        ),
        const SizedBox(height: 5.0,),
        new Text(
          'onboardingTitle2',
          style: cTitleStyle
        ).tr(),
        const SizedBox(height: 20.0,),
        new Text(
          'onboardingText2',
          style: cSubtitleStyle
        ).tr()
      ],
    );
  }

  Widget _buildThirdPage() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Center(
          child: new Image.asset('assets/graphics/onboarding_2.jpg')
        ),
        const SizedBox(height: 5.0,),
        new Text(
          'onboardingTitle3',
          style: cTitleStyle
        ).tr(),
        const SizedBox(height: 20.0,),
        new Text(
          'onboardingText3',
          style: cSubtitleStyle
        ).tr()
      ],
    );
  }

  Widget _buildNextButton() {
    Widget nextButtonWidget;

    if(_currentPageIndex != _numPages - 1) {
      nextButtonWidget = new FlatButton(
        onPressed: () => _pageController.nextPage(
          duration: new Duration(milliseconds: 500), 
          curve: Curves.ease,
        ),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Text(
              'onboarding_next',
              style: new TextStyle(
                color: Colors.white,
                fontSize: 22.0,
              )
            ).tr(),
            new SizedBox(width: 10.0,),
            new Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 30.0,
            ),
          ],
        ),
      );
    }

    return nextButtonWidget;
  }

  Widget _buildOnboardingBody(AppStateBloc appStateBloc) {
    return new Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.1, 0.4, 0.7, 0.9],
          colors: [
            Color(0xFF3594DD),
            Color(0xFF4563DB),
            Color(0xFF5036D5),
            Color(0xFF5B16D0),
          ]
        ),
      ),
      child: new Padding( 
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Skip button
            new Container(
              alignment: Alignment.centerRight,
              child: new FlatButton(
                onPressed: () => _onSkipPressed(appStateBloc), 
                child: new Text(
                  'onboarding_skip',
                  style: new TextStyle(
                    color: Colors.white,
                    fontSize: 20.0
                  ),
                ).tr(),
              ),
            ),
            // PageView (Container)
            new Expanded(
              child: new Padding(
                padding: EdgeInsets.all(10.0),
                child: new Container( 
                  alignment: Alignment.center,
                  child: new PageView(
                    physics: new ClampingScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (int pageIndex) {
                      setState(() {
                        _currentPageIndex = pageIndex;
                      });
                    },
                    children: <Widget>[ // Pages
                      _buildFirstPage(),
                      _buildSecondPage(),
                      _buildThirdPage(),
                    ],
                  ),
                ),
              ),
            ),
            // Page indicator
            new Container(
              alignment: Alignment.center,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildPageIndicator(),
              ),
            ),
            // Next button
            new Container(
              alignment: Alignment.bottomCenter,
              child: _buildNextButton(),
            ),
          ],
        )
      )
    );
  }

  Widget _buildLoadingPage() {
    return new Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.1, 0.4, 0.7, 0.9],
          colors: [
            Color(0xFF3594DD),
            Color(0xFF4563DB),
            Color(0xFF5036D5),
            Color(0xFF5B16D0),
          ]
        ),
      ),
      child: new Center(
        child: new CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appStateBloc = Provider.of<AppStateBloc>(context);

    return new StreamBuilder<AppState>(
      stream: appStateBloc.appStateStream,
      initialData: appStateBloc.currentState,
      builder: (BuildContext ctx, AsyncSnapshot<AppState> snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return new Container();
        }

        Widget pageWidget;
        switch(snapshot.data) {
          case AppState.LOADING:
            pageWidget = _buildLoadingPage();
            break;
          case AppState.ONBOARDING:
            pageWidget = new Scaffold(
              body: _buildOnboardingBody(appStateBloc),
              bottomSheet: _buildBottomSheet(appStateBloc),
            );
            break;
          case AppState.UNATHORIZED:
            SchedulerBinding.instance.addPostFrameCallback((_) {
              NavigationService.openLoginScreen(ctx);
            });
            pageWidget = new Container();
            break;
          case AppState.READY:
            SchedulerBinding.instance.addPostFrameCallback((_) {
              NavigationService.openDeviceListScreen(ctx);
            });
            pageWidget = new Container();
            break;
          default:
            pageWidget = _buildLoadingPage();
            break;
        }

        return pageWidget;
      }
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
