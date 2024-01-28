import 'package:flutter/material.dart';
import 'package:quiz/pages/team_page.dart';
import 'package:quiz/widgets/inf_button.dart';
import 'package:quiz/widgets/language_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;
import '../utils/open_ai_api.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import '../widgets/animated_elevated_button.dart';


/// this is the first page the user sees it explains the Quiz
/// and gets the Open AI API key from the user
class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _loading = false;

  /// checks if the API key is already saved in the shared preferences
  Future<bool> getAPIKeyFromPreferences() async {
    if (OpenAIApi().aPIKey == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString("APIKey") != null) {
        OpenAIApi().setAPIKey(prefs.getString("APIKey").toString());
        return true;
      }
      return false;
    }
    return true;
  }

  /// shows a dialog to the user to get the API key
  Future<String> getKeyFromUser() async {
    // the api key the user entered
    String providedAPIKey = "";

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("OpenAI API Key:"),
            content: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.aPIRequest),
                  TextButton(
                    onPressed: () {
                      html.window.open(
                          "https://platform.openai.com/account/api-keys",
                          "OpenAI API Keys");
                    },
                    child: const Text("OpenAI API Keys"),
                  ),
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: "sk-jxqXx0q3B...",
                    ),
                    onChanged: (value) {
                      providedAPIKey = value;
                    },
                    onSubmitted: (value) {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Ok"),
              )
            ],
          );
        });

    return providedAPIKey;
  }

  /// shows an exception dialog to the user
  /// [e] the exception to show
  void showExceptionDialog(Exception e) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "😱",
                  style: TextStyle(fontSize: 60),
                ),const SizedBox(
                  height: 10,
                ),
                Text(AppLocalizations.of(context)!.aPIKeyCheckError),
                Container(
                  color: Colors.grey[800],
                  constraints:
                      const BoxConstraints(maxWidth: 280, maxHeight: 300),
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.all(5),
                  child: SingleChildScrollView(
                    child: Text(e.toString(),
                        style:
                            const TextStyle(fontSize: 12)),
                  ),
                ),
                Text(AppLocalizations.of(context)!.aPIKeyCheckErrorTip),
                TextButton(
                  onPressed: () {
                    html.window
                        .open("https://status.openai.com/", "OpenAI Status");
                  },
                  child: const Text("OpenAI Status"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              autofocus: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Ok"),
            )
          ],
        );
      },
    );
  }

  /// gets the API key from the user
  Future<bool> getAPIKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // get the api key from the user
    String providedAPIKey = await getKeyFromUser();

    if (providedAPIKey == "") {
      if (!context.mounted) return false; // if the context is not mounted anymore return
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          Text(AppLocalizations.of(context)!.aPIKeyMissing, style: Theme.of(context).textTheme.bodyMedium,),
        ),
      );
      return false;
    }

    try {
      await OpenAIApi().setAPIKey(providedAPIKey);
    } on Exception catch (e) {
      showExceptionDialog(e);
      return false;
    }
    // save the api key
    prefs.setString("APIKey", OpenAIApi().aPIKey!);
    return true;
  }

  @override
  void initState() {
    super.initState();
    getAPIKeyFromPreferences();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'AI Quiz',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 80),
              AnimatedElevatedButton(
                onPressed: () async {
                  if (_loading) {
                    return;
                  }
                  setState(() {
                    _loading = true;
                  });
                  bool apiKeySet = await getAPIKeyFromPreferences();
                  if (!apiKeySet) {
                    if (!await getAPIKey()) {
                      setState(() {
                        _loading = false;
                      });
                      return;
                    }
                  }
                  setState(() {
                    _loading = false;
                  });
                  if (!context.mounted) return; // if the context is not mounted anymore return
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TeamPage()),
                  );
                },
                isLoading: _loading,
                isActive: !_loading,
                child: Text(AppLocalizations.of(context)!.start),
              ),
            ],
          ),
          // change language button
          const Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              height: 50,
                child: LanguageDropdown()
            ),
          ),
          //info button
          Align(
            alignment: Alignment.topLeft,
            child: InfoButton(infoText: AppLocalizations.of(context)!.infoWelcomePage,),
          ),
        ],
      ),
    );
  }
}
