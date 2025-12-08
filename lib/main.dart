import 'dart:async';
import 'package:fastscore_frontend/home_page.dart';
import 'package:fastscore_frontend/pages/account_switcher.dart';
import 'package:fastscore_frontend/pages/my_songs_page.dart';
import 'package:fastscore_frontend/pages/notes_page.dart';
import 'package:fastscore_frontend/repositories.dart';
import 'package:fastscore_frontend/services/auth_service.dart';
import 'package:fastscore_frontend/services/firebase_service.dart';
import 'package:fastscore_frontend/theme/theme_provider.dart';
import 'package:fastscore_frontend/providers/sidebar_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:just_audio_web/just_audio_web.dart';

void main() async{

  // Global error handler
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  // Custom error widget to prevent crashes
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.red.shade50,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade700),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                details.exception.toString(),
                style: TextStyle(fontSize: 12, color: Colors.red.shade900),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  };

  // Catch errors not handled by Flutter framework
  runZonedGuarded(() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  final authService = AuthService();
  final firebaseService = FirebaseService();

  final userRepository = UserRepository(authService, firebaseService);
  final pieceRepository = PieceRepository(firebaseService);


    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => SidebarProvider()),
          Provider<AuthService>(create: (_) => authService),
          Provider<FirebaseService>(create: (_) => firebaseService),
          Provider<UserRepository>(create: (_) => userRepository),
          Provider<PieceRepository>(create: (_) => pieceRepository),
        ],
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('Uncaught error: $error');
    debugPrint('Stack trace: $stack');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'FastScore',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const MusicPage(),
            '/my-songs': (context) => const MySongsPage(),
            '/account': (context) => const AccountSwitcher(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/notes') {
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => NotesPage(
                  songTitle: args?['title'] ?? 'Utwór bez tytułu',
                  songId: args?['songId'],
                ),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
