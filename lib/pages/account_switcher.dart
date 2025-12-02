import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fastscore_frontend/repositories.dart';
import 'auth_page.dart';
import 'profile_page.dart';

class AccountSwitcher extends StatefulWidget {
  const AccountSwitcher({super.key});

  @override
  State<AccountSwitcher> createState() => _AccountSwitcherState();
}

class _AccountSwitcherState extends State<AccountSwitcher> {
  bool? _wasLoggedIn;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<UserRepository>();

    return StreamBuilder<String?>(
      stream: repo.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final uid = snapshot.data;
        final isLoggedIn = uid != null;

        if (_wasLoggedIn == false && isLoggedIn) {
          _wasLoggedIn = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/');
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        _wasLoggedIn = isLoggedIn;

        if (isLoggedIn) {
          return const ProfilePage();
        } else {
          return const AuthPage();
        }
      },
    );
  }
}