import 'dart:async';
import 'package:alice_video_box/models/alice_service.dart';
import 'package:alice_video_box/models/field_validation.dart';
import 'package:alice_video_box/models/service_locator.dart';
import 'package:meta/meta.dart';
import 'package:alice_video_box/blocs/appstate_bloc.dart';
import 'package:rxdart/rxdart.dart';

abstract class LoginState {
  LoginState();

  factory LoginState.init() => new LoginStateInit();
  factory LoginState.loading() => new LoginStateLoading();
  factory LoginState.success() => new LoginStateSuccess();
  factory LoginState.error() => new LoginStateError();
  factory LoginState.validationError(String errorText) => LoginStateFieldValidationError(errorText: errorText);
}

// Init
class LoginStateInit extends LoginState {}
// Loading
class LoginStateLoading extends LoginState {}
// Success
class LoginStateSuccess extends LoginState {}
// Error
class LoginStateError extends LoginState {}
// Field validation error
class LoginStateFieldValidationError extends LoginState {
  final String errorText;

  LoginStateFieldValidationError({this.errorText});
}

class LoginStateBloc with FieldValidationMixin {
  BehaviorSubject<LoginState> _loginState;

  AppStateBloc _appStateBloc;
  StreamSubscription<AppState> _appStateStreamHandle;

  ValueStream<LoginState> get loginStateStream => _loginState.stream;
  LoginState get currentLoginState => _loginState.value;

  LoginStateBloc({@required AppStateBloc appStateBloc}) {
    _loginState = BehaviorSubject.seeded(LoginState.init());

    _appStateBloc = appStateBloc;
    _appStateStreamHandle = appStateBloc.addAppStateListener(handleAppStateData);
  }

  void handleAppStateData(AppState appState) {
    switch(appState) {
      case AppState.INIT:
      case AppState.LOADING:
      case AppState.NOCONNECTION:
      case AppState.ONBOARDING:
      case AppState.UNATHORIZED:
        break;
      case AppState.READY:
        _loginState.add(LoginState.success());
        break;
      default:
        break;
    }
  }

  void dispose() {
    _appStateStreamHandle?.cancel();
  }

  String _validateFields(String login, String password) {
    String errorText;

    if(isFieldEmpty(login)) errorText = "emptyLoginText";
    else if(isFieldEmpty(password)) errorText = "emptyPasswordText";
    //else if(validateEmailField(login)) errorText = "invalidaLoginText";

    return errorText;
  }

  Future login({@required String login, @required String password}) async {
    _loginState.add(LoginState.loading());

    var errorText = _validateFields(login, password);
    if(errorText != null) {
      _loginState.add(LoginState.validationError(errorText));
      return;
    }

    var aliceService = gServiceLocator<AliceStationService>();
    var loginResult = await aliceService.login(
      login: login, 
      passwd: password,
    );

    switch(loginResult) {
      case AuthResult.SUCCESS:
        await aliceService.saveUserSession();
        await _appStateBloc.completeLogin();
        break;
      case AuthResult.NOREDIRECT:
      case AuthResult.NOSESSIONID:
      case AuthResult.NOCSRFTOKEN:
      case AuthResult.UNKNOWN:
      default:
        _loginState.add(LoginState.error());
        break;
    }
  }
}