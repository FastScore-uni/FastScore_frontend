import 'package:fastscore_frontend/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:fastscore_frontend/repositories.dart';
import 'package:provider/provider.dart';


class ProfilePage extends StatelessWidget{
  const ProfilePage({super.key});


  Future<void> _handleLogOut(BuildContext context) async{
    debugPrint("Wylogowanie przez email");
    final repo = context.read<UserRepository>();
    try {
      await repo.signOutUser();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/auth',
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint("Błąd wylogowania: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
        child:Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Witaj zalogowany użytkowniku'),
                  SizedBox(height: 18),
                  OutlinedButton(
                    onPressed: () {
                      _handleLogOut(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text('Wyloguj się'),
                  ),
                ],
              )
            ),
        ),
    );
  }
}