import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fastscore_frontend/repositories.dart';
import 'auth_page.dart';
import 'profile_page.dart';

class AccountSwitcher extends StatelessWidget {
  const AccountSwitcher({super.key});

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

        if (uid != null) {
          return const ProfilePage();
        } else {
          return const AuthPage();
        }
      },
    );
  }
}