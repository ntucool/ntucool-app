import 'package:flutter/material.dart';

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

  void _login(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    List<Widget> listViewChildren;

    listViewChildren = [
      _UsernameInput(usernameController: usernameController),
      _PasswordInput(passwordController: passwordController),
    ];

    return Align(
      alignment: Alignment.topCenter,
      child: ListView(
        restorationId: 'saml_list_view',
        children: listViewChildren,
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
    return Align(
      alignment: Alignment.center,
      child: TextField(
        controller: passwordController,
        decoration: InputDecoration(
          labelText: 'Password',
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
      child: null,
    );
  }
}
