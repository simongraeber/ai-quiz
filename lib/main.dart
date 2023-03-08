import 'package:flutter/material.dart';
import 'package:quiz/pages/welcome_page.dart';
import 'l10n/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    // the provider is used to change the language from in the app
      create: (context) => LocaleProvider(),
      builder: (context, child) {
        final provider = Provider.of<LocaleProvider>(context);

        return MaterialApp(
          // the supported languages
          supportedLocales: L10n.all,
          // settings for the localization
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          // the selected language or the default system language
          locale: provider.locale,

          title: 'AI-Quiz',

          // the theme of the app colors and stuff
          theme: ThemeData(
            canvasColor: const Color(0xFF1A212C),
            iconTheme: const IconThemeData(color: Colors.lightGreen),
            colorScheme: const ColorScheme(
                background: Color(0xFF222B39),
                brightness: Brightness.light,
                primary: Colors.lightGreen,
                onPrimary: Colors.white,
                secondary: Colors.lightGreen,
                onSecondary: Colors.black,
                surface: Color(0xFF222B39),
                onSurface: Colors.black,
                error: Colors.red,
                onError: Colors.white,
                onBackground: Colors.white),
            scaffoldBackgroundColor: const Color(0xFF222B39),
            cardColor: const Color(0xFF222B39),
            // dialog color dark
            dialogBackgroundColor: const Color(0xFF222B39),
            // dialog text color white
            dialogTheme: const DialogTheme(
              titleTextStyle: TextStyle(color: Colors.white),
              contentTextStyle: TextStyle(color: Colors.white),
            ),

            inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.lightGreen),
              hintStyle: TextStyle(color: Colors.white),
            ),
            // text color white
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
              displayLarge: TextStyle(color: Colors.white),
              displayMedium: TextStyle(color: Colors.white),
              displaySmall: TextStyle(color: Colors.white),
              headlineSmall: TextStyle(color: Colors.white),
              titleMedium: TextStyle(color: Colors.white),
              titleSmall: TextStyle(color: Colors.white),
            ),
            cardTheme: const CardTheme(
              color: Color(0xFF1A212C),
            ),
            primarySwatch: Colors.lightGreen,
          ),

          // the app starts here with the welcome page
          home: const WelcomePage(),
        );
      });
}