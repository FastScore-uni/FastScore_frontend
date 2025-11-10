import 'package:fastscore_frontend/home_page.dart';
import 'package:fastscore_frontend/pages/my_songs_page.dart';
import 'package:fastscore_frontend/pages/notes_page.dart';
import 'package:fastscore_frontend/theme/theme_provider.dart';
import 'package:fastscore_frontend/providers/sidebar_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SidebarProvider()),
      ],
      child: const MyApp(),
    ),
  );
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