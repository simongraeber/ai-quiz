import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiz/utils/open_ai_api.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import '../utils/image_construktion.dart';
import '../utils/question.dart';

/// this page is used to display the question and to check the answer
/// it also displays the image of the question
class QuestionPage extends StatefulWidget {
  const QuestionPage({Key? key, required this.question, required this.image})
      : super(key: key);
  final Future<Question> question;
  final Future<Uint8List> image;

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {

  // the focus is used to select a button when the user presses the up or down arrow or up key
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();
  int _selectedButton = -1;

  /// this function shows a dialog explaining why the answer is as it is
  Future<void> showExplanationDialog(Future<String> explanation) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("🤓", style: TextStyle(fontSize: 60)),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: 280, maxHeight: 300),
                    child: SingleChildScrollView(
                      child: FutureBuilder<String>(
                        future: explanation,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(snapshot.data!);
                          } else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          }
                          return const CircularProgressIndicator();
                        },
                      ),
                    ),
                  ),
                ),
              ],
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
        });
  }

  /// this function shows a dialog informing the user if the answer was correct or not
  /// it returns true if the user wants to reject the answer
  Future<bool> showInfoDialog(
      bool correct, String realAnswerText, Future<String> explanation) async {
    bool rejectAnswer = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                correct ? "🥳" : "😢",
                style: const TextStyle(fontSize: 60),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(correct
                  ? AppLocalizations.of(context)!.correct
                  : AppLocalizations.of(context)!.incorrect),
              Text(
                correct ? "" : realAnswerText,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                showExplanationDialog(explanation);
              },
              child: const Text("info", style: TextStyle(color: Colors.grey)),
            ),
            correct
                ? const SizedBox()
                : TextButton(
                    onPressed: () {
                      rejectAnswer = true;
                      Navigator.of(context).pop();
                    },
                    child: Text(AppLocalizations.of(context)!.no,
                        style: const TextStyle(color: Colors.grey)),
                  ),
            TextButton(
              autofocus: true,
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return rejectAnswer;
  }

  /// this function is called when the user clicks on the "reject answer" button
  /// it shows a dialog and asks if the user really wants to reject the answer
  Future<bool> givePints(Future<String> explanation) async {
    bool givePints = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "🤨",
                  style: TextStyle(fontSize: 60),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  constraints:
                      const BoxConstraints(maxWidth: 280, maxHeight: 300),
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.all(5),
                  child: SingleChildScrollView(
                    child: FutureBuilder<String>(
                      future: explanation,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(snapshot.data!);
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        return const CircularProgressIndicator();
                      },
                    ),
                  ),
                ),
                Text(AppLocalizations.of(context)!.giveThePoints),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.giveThePointsYes),
              onPressed: () {
                givePints = true;
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context)!.cancel)),
          ],
        );
      },
    );
    return givePints;
  }

  /// this function is called when the user clicks on one of the answer buttons
  /// it checks if the answer is correct and returns to the game view page
  void checkAnswer(int answer) async {
    bool correct = false;
    int realAnswer = await widget.question.then((value) => value.correctAnswer);
    String realAnswerText =
        await widget.question.then((value) => value.getRealAnswer(context));
    if (answer == realAnswer) {
      correct = true;
    }
    if (!context.mounted) return; // if the context is not mounted anymore return
    Future<String> explanation =
        OpenAIApi().getExplanation(await widget.question, context);

    bool rejectAnswer =
        await showInfoDialog(correct, realAnswerText, explanation);

    if (rejectAnswer) {
      correct = await givePints(explanation);
    }
    if (!context.mounted) return; // if the context is not mounted anymore return
    Navigator.pop(context, correct);
  }

  /// this function is called an error occurs while loading the question
  Widget failDialogCard(String error) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "😱",
            style: TextStyle(fontSize: 60),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(AppLocalizations.of(context)!.questionError),
          const SizedBox(
            height: 10,
          ),
          Container(
            color: Colors.grey[800],
            constraints: const BoxConstraints(maxWidth: 280, maxHeight: 100),
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.all(5),
            child: SingleChildScrollView(
              child: Text(error,
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(AppLocalizations.of(context)!.questionErrorTip),
          const SizedBox(
            height: 10,
          ),
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  /// this function starts a listener for a up or down key press
  /// if the user presses the up or down key the focus will go to the next or previous answer button
  void startKeyListener() {
    RawKeyboard.instance.addListener((event) {
      List<FocusNode> focusNodes = [
        _focusNode1,
        _focusNode2,
        _focusNode3,
        _focusNode4,
      ];
      if (event.runtimeType == RawKeyDownEvent) {
        print("key pressed");
        if(_selectedButton == -1){
          _selectedButton = 0;
          focusNodes[_selectedButton].requestFocus();
          return;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          if (_selectedButton == 0) {
            _selectedButton = 3;
          } else {
            _selectedButton--;
          }
          focusNodes[_selectedButton].requestFocus();
        } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          if (_selectedButton == 3) {
            _selectedButton = 0;
          } else {
            _selectedButton++;
          }
          focusNodes[_selectedButton].requestFocus();
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startKeyListener();
  }

  @override
  void dispose() {
    super.dispose();
    RawKeyboard.instance.removeListener((event) {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        // background image
        FutureBuilder<Uint8List>(
          future: widget.image,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Stack(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width > 800
                          ? MediaQuery.of(context).size.width * 0.5
                          : MediaQuery.of(context).size.width,
                      child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: 0.5),
                          curve: Curves.easeIn,
                          duration: const Duration(seconds: 5),
                          builder: (BuildContext context, double opacity,
                              Widget? child) {
                            return Opacity(
                              opacity: opacity,
                              child: Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                              ),
                            );
                          }),
                    ),
                  ),
                  // download button bottom right
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      tooltip: "download",
                      icon: Icon(Icons.download,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withAlpha(200)),
                      onPressed: () async {
                        downloadImage(snapshot.data!);
                      },
                    ),
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
        // question and answers
        FutureBuilder<Question>(
          future: widget.question,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              //failDialog(snapshot.error.toString());
              return Center(child: failDialogCard(snapshot.error.toString()));
            }
            if (snapshot.hasData) {
              return Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    color: Colors.lightGreen,
                    width: double.infinity,
                    constraints: const BoxConstraints(
                      minHeight: 50,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5, left: 5),
                        child: Text(
                          snapshot.data!.questionText,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width > 800
                          ? MediaQuery.of(context).size.width * 0.5
                          : MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(
                            focusNode: _focusNode1,
                            onPressed: () {
                              checkAnswer(1);
                            },
                            child: Text(snapshot.data!.answerText01),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          ElevatedButton(
                            focusNode: _focusNode2,
                            onPressed: () {
                              checkAnswer(2);
                            },
                            child: Text(snapshot.data!.answerText02),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          ElevatedButton(
                            focusNode: _focusNode3,
                            onPressed: () {
                              checkAnswer(3);
                            },
                            child: Text(snapshot.data!.answerText03),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          ElevatedButton(
                            focusNode: _focusNode4,
                            onPressed: () {
                              checkAnswer(4);
                            },
                            child: Text(snapshot.data!.answerText04),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return Padding(
                padding: const EdgeInsets.only(top: 50),
                child: LinearProgressIndicator(
                  minHeight: 50,
                  backgroundColor: const Color(0xFF4CAF50).withAlpha(100),
                ));
          },
        ),
      ],
    ));
  }
}
