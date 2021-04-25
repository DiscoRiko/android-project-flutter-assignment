import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_repository.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmedPasswordController =
      new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Login')),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                child: Text(
                    'Welcome to Startup Names Generator\nplease log in below'),
                padding: EdgeInsets.all(16)),
            Container(
                child: TextField(
                  decoration: InputDecoration(hintText: 'Email'),
                  controller: emailController,
                ),
                padding: EdgeInsets.all(16)),
            Container(
                child: TextField(
                    decoration: InputDecoration(hintText: 'Password'),
                    controller: passwordController,
                    obscureText: true),
                padding: EdgeInsets.all(16)),
            Column(
              children: [
                Center(
                  child: Consumer<AuthRepository>(
                    builder: (context, authenticator, _) =>
                        authenticator.status == Status.Authenticating
                            ? CircularProgressIndicator()
                            : Padding(
                                padding: const EdgeInsets.all(16),
                                child: TextButton(
                                    onPressed: () async {
                                      bool sign_in_succeed =
                                          await authenticator.signIn(
                                              emailController.text,
                                              passwordController.text);
                                      sign_in_succeed
                                          ? Navigator.of(context).pop()
                                          : ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "There was an error logging into the app"),
                                                  backgroundColor: Colors.red));
                                    },
                                    child: Text('Login'),
                                    style: TextButton.styleFrom(
                                        primary: Colors.white,
                                        backgroundColor: Colors.red)),
                              ),
                  ),
                ),
                TextButton(
                    onPressed: () => showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          bool password_confirmed = true;
                          return StatefulBuilder(
                            builder: (BuildContext context,
                                StateSetter setStateModal) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      child: Text(
                                          'Please confirm your password below:'),
                                      padding: EdgeInsets.all(16)),
                                  Container(
                                      child: TextField(
                                        decoration: InputDecoration(
                                            hintText: 'Password',
                                            errorText: password_confirmed
                                                ? null
                                                : "Passwords must match"),
                                        controller: confirmedPasswordController,
                                        obscureText: true,
                                      ),
                                      padding: EdgeInsets.all(16)),
                                  Center(
                                    child: Consumer<AuthRepository>(
                                      builder: (context, authenticator, _) =>
                                          authenticator.status ==
                                                  Status.Authenticating
                                              ? CircularProgressIndicator()
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  child: TextButton(
                                                      onPressed: () async {
                                                        setStateModal(() {
                                                          password_confirmed =
                                                              passwordController
                                                                      .text ==
                                                                  confirmedPasswordController
                                                                      .text;
                                                        });
                                                        if (password_confirmed) {
                                                          _signUpAndLogIn(
                                                              authenticator,
                                                              emailController
                                                                  .text,
                                                              passwordController
                                                                  .text);
                                                        }
                                                      },
                                                      child: Text('Confirm'),
                                                      style:
                                                          TextButton.styleFrom(
                                                              primary:
                                                                  Colors.white,
                                                              backgroundColor:
                                                                  Colors.teal)),
                                                ),
                                    ),
                                  ),
                                ],
                                mainAxisSize: MainAxisSize.min,
                              );
                            },
                          );
                        }),
                    child: Text('New User? Click to sign up'),
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Colors.teal,
                    ))
              ],
            )
          ],
        ));
  }

  void _signUpAndLogIn(
      AuthRepository authenticator, String email, String password) async {
    await authenticator.signUp(email, password);
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }
}
