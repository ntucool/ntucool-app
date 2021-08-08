import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ntucool/src/http/cookies.dart' show SimpleCookie;

import 'client.dart';
import 'dashboard.dart';
import 'storage.dart';

class SamlPage extends StatefulWidget {
  const SamlPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SamlPageState();
}

class _SamlPageState extends State<SamlPage> with RestorationMixin {
  final RestorableTextEditingController _usernameController =
      RestorableTextEditingController();
  final RestorableTextEditingController _passwordController =
      RestorableTextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _MainView(
          usernameController: _usernameController.value,
          passwordController: _passwordController.value,
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

  Future<bool> _login(
      BuildContext context, String username, String password) async {
    var client = Provider.of<AppClient>(context, listen: false);
    var file = await cookieFile;
    var exists = await file.exists();
    if (exists) {
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
    var courses = client.api.courses.getCourses();
    await courses.forEach((element) {
      print(element);
    });
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
            ),
            body: Dashboard(),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.coronavirus), label: 'coronavirus'),
              ],
            ),
          );
        },
      ),
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listViewChildren;

    listViewChildren = [
      _UsernameInput(usernameController: usernameController),
      _PasswordInput(passwordController: passwordController),
      _LoginButton(onTap: () {
        _login(context, usernameController.text, passwordController.text);
      }),
    ];

    return Expanded(
      child: Align(
        alignment: Alignment.topCenter,
        child: ListView(
          restorationId: 'saml_list_view',
          children: listViewChildren,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
      ),
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
    return Align(
      alignment: Alignment.center,
      child: TextField(
        textInputAction: TextInputAction.next,
        controller: usernameController,
        decoration: InputDecoration(
          labelText: 'Username',
        ),
      ),
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
    return Container(
      child: Align(
        alignment: Alignment.center,
        child: TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
          ),
          obscureText: true,
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: _FilledButton(
        text: 'Login',
        onTap: onTap,
      ),
    );
  }
}

class _FilledButton extends StatelessWidget {
  const _FilledButton({Key? key, required this.text, required this.onTap})
      : super(key: key);

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onTap,
      child: Row(
        children: [
          const Icon(Icons.lock),
          const SizedBox(width: 6),
          Text(text),
        ],
      ),
    );
  }
}
