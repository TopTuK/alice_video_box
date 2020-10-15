import 'package:alice_video_box/blocs/login_bloc.dart';
import 'package:alice_video_box/models/navigation_service.dart';
import 'package:alice_video_box/screens/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() {
    return new _LoginScreen();
  }
}

class _LoginScreen extends State<LoginScreen> {
  final TextEditingController _loginController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();

  Widget _buildTitleText() {
    return new Text(
      'login_title',
      style: new TextStyle(
        color: Colors.white,
        fontFamily: 'OpenSans',
        fontSize: 30.0,
        fontWeight: FontWeight.bold,
      ),
    ).tr();
  }

  Widget _buildLoginTextField() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Text(
          'login_email',
          style: cLabelStyle,
        ).tr(),
        const SizedBox(height: 10.0),
        new Container(
          alignment: Alignment.centerLeft,
          decoration: cBoxDecorationStyle,
          height: 60.0,
          child: new TextField(
            controller: _loginController,
            keyboardType: TextInputType.emailAddress,
            style: new TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans'
            ),
            decoration: new InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: new Icon(
                Icons.email,
                color: Colors.white
              ),
              hintText: tr("login_email_hint"),
              hintStyle: cHintTextStyle
            ),
          )
        )
      ],
    );
  }

  Widget _buildPasswordTextfield() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Text(
          "login_passwd",
          style: cLabelStyle,
        ).tr(),
        const SizedBox(height: 10.0,),
        new Container(
          alignment: Alignment.centerLeft,
          decoration: cBoxDecorationStyle,
          height: 60.0,
          child: new TextField(
            controller: _passwordController,
            obscureText: true,
            style: new TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: new InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: new Icon(
                Icons.lock,
                color: Colors.white
              ),
              hintText: tr("login_passwd_hint"),
              hintStyle: cHintTextStyle
            ),
          ),
        )
      ]
    );
  }

  Widget _buildLoginButton(LoginStateBloc loginStateBloc) {
    return new Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: new RaisedButton(
        elevation: 5.0,
        padding: EdgeInsets.all(15.0),
        shape: new RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: new Text(
          "login_title",
          style: new TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ).tr(),
        onPressed: () {
          loginStateBloc.login(
            login: _loginController.text,
            password: _passwordController.text,
          );
        }
      ),
    );
  }

  Widget _buildTitleImage() {
    return Center(
      child: new Image.asset('assets/graphics/tvbox.png', height: 150,)
    );
  }

  Widget _buildLoginFormPage(LoginStateBloc loginStateBloc) {
    return new Container(
      height: double.infinity,
      child: new SingleChildScrollView(
        physics: new AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: 40.0,
          vertical: 120.0,
        ),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildTitleImage(),
            const SizedBox(height: 5.0),
            _buildTitleText(),
            const SizedBox(height: 5.0),
            _buildLoginTextField(),
            const SizedBox(height: 30.0,),
            _buildPasswordTextfield(),
            const SizedBox(height: 10.0),
            _buildLoginButton(loginStateBloc),
          ]
        )
      )
    );
  }

  Widget _buildLoadingPage() {
    return new Center(
      child: new CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var loginStateBloc = Provider.of<LoginStateBloc>(context);

    return new Scaffold(
      body: new Container(
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
        child: new StreamBuilder<LoginState>(
          stream: loginStateBloc.loginStateStream,
          initialData: loginStateBloc.currentLoginState,
          builder: (BuildContext ctx, AsyncSnapshot<LoginState> snapshot) {
            if(!snapshot.hasData || snapshot.data == null) return Container();

            var loginState = snapshot.data;
            if (loginState is LoginStateInit) {
              return _buildLoginFormPage(loginStateBloc);
            }
            else if (loginState is LoginStateLoading) {
              return _buildLoadingPage();
            }
            else if (loginState is LoginStateError) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Scaffold.of(ctx).showSnackBar(new SnackBar(
                  content: const Text("login_error_text").tr(),
                ));
              });

              return _buildLoginFormPage(loginStateBloc);
            }
            else if (loginState is LoginStateFieldValidationError) {
              SchedulerBinding.instance.addPersistentFrameCallback((_) {
                Scaffold.of(ctx).showSnackBar(new SnackBar(
                  content: new Text(loginState.errorText).tr(),
                ));
              });

              return _buildLoginFormPage(loginStateBloc);
            }
            else if (loginState is LoginStateSuccess) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                NavigationService.openDeviceListScreen(ctx);
              });
            }

            return _buildLoadingPage();
          },
        )
      )
    );
  }
}
