import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapparabic/providers/auth.dart';
import '../models/http_execption.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20),
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 94),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.deepOrange.shade900,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8,
                              color: Colors.black26,
                              offset: Offset(0, 2),
                            ),
                          ]),
                      child: Text(
                        'My Shop',
                        style: TextStyle(
                          color:
                              Theme.of(context).accentTextTheme.headline6.color,
                          fontSize: 35,
                          fontFamily: 'Anton',
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

enum AuthModel {
  Login,
  SignUp,
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formeKey = GlobalKey();
  AuthModel _authModel = AuthModel.Login;
  Map<String, String> _AuthData = {
    'email': '',
    'password': '',
  };
  var isLoading = false;
  final _passwordController = TextEditingController();

  AnimationController _controller;
  Animation<Offset> _sildAnimation;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _sildAnimation = Tween<Offset>(
      begin: Offset(0, -0.15),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
    _controller.dispose();
  }

  Future<void> submit() async {
    if (!_formeKey.currentState.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    _formeKey.currentState.save();
    setState(() {
      isLoading = true;
    });
    try {
      if (_authModel == AuthModel.Login) {
        await Provider.of<Auth>(context, listen: false)
            .login(_AuthData['email'], _AuthData['password']);
      } else {
        await Provider.of<Auth>(context, listen: false)
            .signUp(_AuthData['email'], _AuthData['password']);
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';

      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = "This email address is already in use";
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = "This is not a valid email address";
      } else if (error.toString().contains('WEEK_PASSWORD')) {
        errorMessage = "This is password is too week";
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = "Could not find a user with that email";
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = "Invalid password";
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage = 'Could not authenticate you.Please again later';
      _showErrorDialog(errorMessage);
    }
    setState(() {
      isLoading = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: [
          FlatButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Okay!'),
          )
        ],
      ),
    );
  }

  void _switchAuthMode() {
    if (_authModel == AuthModel.Login) {
      setState(() {
        _authModel = AuthModel.SignUp;
      });
      _controller.forward();
    } else {
      setState(() {
        _authModel = AuthModel.Login;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _authModel == AuthModel.SignUp ? 320 : 260,
        constraints: BoxConstraints(
          minHeight: _authModel == AuthModel.SignUp ? 320 : 260,
        ),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16),
        child: Form(
            key: _formeKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val.isEmpty || !val.contains('@')) {
                        return 'Invalid Email';
                      }
                      return null;
                    },
                    onSaved: (val) {
                      _AuthData['email'] = val;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                    obscureText: true,
                    controller: _passwordController,
                    validator: (val) {
                      if (val.isEmpty || val.length < 5) {
                        return 'Password is too short !';
                      }
                      return null;
                    },
                    onSaved: (val) {
                      _AuthData['password'] = val;
                    },
                  ),
                  AnimatedContainer(
                    constraints: BoxConstraints(
                      minHeight: _authModel == AuthModel.SignUp ? 60 : 0,
                      maxHeight: _authModel == AuthModel.SignUp ? 120 : 0,
                    ),
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: SlideTransition(
                          position: _sildAnimation,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                            ),
                            obscureText: true,
                            enabled: _authModel == AuthModel.SignUp,
                            validator: _authModel == AuthModel.SignUp
                                ? (val) {
                                    if (val != _passwordController.text) {
                                      return 'Password d\'ont match !';
                                    }
                                    return null;
                                  }
                                : null,
                          ),
                        )),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  if (isLoading) CircularProgressIndicator(),
                  RaisedButton(
                    child: Text(
                        _authModel == AuthModel.Login ? 'LOGIN' : 'SIGNUP'),
                    onPressed: submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                    color: Theme.of(context).primaryColor,
                    textColor:
                        Theme.of(context).primaryTextTheme.headline6.color,
                  ),
                  FlatButton(
                    child: Text(
                        '${_authModel == AuthModel.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                    onPressed: _switchAuthMode,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 4),
                    textColor: Theme.of(context).primaryColor,
                  )
                ],
              ),
            )),
      ),
    );
  }
}
