import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ntucool/src/http/cookies.dart' show SimpleCookie;

import 'client.dart';
import 'home.dart';
import 'storage.dart' show cookieFile;

class SamlPage extends StatefulWidget {
  const SamlPage({Key? key}) : super(key: key);

  @override
  _SamlPageState createState() => _SamlPageState();
}

class _SamlPageState extends State<SamlPage> with RestorationMixin {
  final RestorableTextEditingController _usernameController =
      RestorableTextEditingController();
  final RestorableTextEditingController _passwordController =
      RestorableTextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: _MainView(
              usernameController: _usernameController.value,
              passwordController: _passwordController.value,
            ),
          ),
        ),
      ),
    );
  }

  @override
  String get restorationId => 'saml_page';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_usernameController, restorationId);
    registerForRestoration(_passwordController, restorationId);
  }
}

class _MainView extends StatelessWidget {
  const _MainView({
    Key? key,
    required this.usernameController,
    required this.passwordController,
  }) : super(key: key);

  final TextEditingController usernameController;
  final TextEditingController passwordController;

  Future<bool> _signIn(
      BuildContext context, String username, String password) async {
    var client = Provider.of<AppClient>(context, listen: false);
    var file = await cookieFile;
    var exists = await file.exists();
    if (username.isEmpty && password.isEmpty && exists) {
      var json = jsonDecode(await file.readAsString());
      var cookies = SimpleCookie.fromJson(json);
      client.session.cookieJar.updateCookies(cookies);
    } else {
      var ok = await client.saml(username, password);
      assert(ok);
      var file = await cookieFile;
      await file.writeAsString(
          jsonEncode(client.session.cookieJar.filterCookies(client.baseUrl)));
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return Home();
        },
      ),
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.catching_pokemon,
          size: 64,
        ),
        SizedBox(height: 24),
        _UsernameInput(usernameController: usernameController),
        SizedBox(height: 12),
        _PasswordInput(passwordController: passwordController),
        SizedBox(height: 12),
        _SignInButton(onPressed: () {
          _signIn(context, usernameController.text, passwordController.text);
        }),
      ],
    );
  }
}

class _UsernameInput extends StatelessWidget {
  const _UsernameInput({
    Key? key,
    required this.usernameController,
  }) : super(key: key);

  final TextEditingController usernameController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: usernameController,
      decoration: InputDecoration(
        labelText: 'User name',
        border: OutlineInputBorder(),
      ),
      textInputAction: TextInputAction.next,
    );
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput({
    Key? key,
    required this.passwordController,
  }) : super(key: key);

  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
        // alignLabelWithHint: true,
      ),
      obscureText: true,
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text('Sign In'),
      style: ElevatedButton.styleFrom(elevation: 0),
    );
  }
}
