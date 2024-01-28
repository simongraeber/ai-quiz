import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/team.dart';
import '../utils/open_ai_api.dart';
import '../utils/question.dart';
import '../widgets/inf_button.dart';
import '../widgets/team_card.dart';
import 'question_page.dart';
import 'award_ceremony_page.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

/// This is the page where the team are displayed with their points and the round
/// The active team can select a category and the difficulty and then the question page is opened
class GameVew extends StatefulWidget {
  const GameVew({Key? key, required this.teams}) : super(key: key);
  final List<Team> teams;

  @override
  State<GameVew> createState() => _GameVewState();
}

class _GameVewState extends State<GameVew> {
  int round = 1; // the current round
  int activeTeam = 0; // the index of the active team

  bool updateRound = false; // if the round is updated in the UI

  /// Increases the round by one and updates the UI
  void increaseRound() {
    setState(() {
      updateRound = true;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        round++;
        updateRound = false;
      });
    });
  }

  /// shows a dialog to select the category
  Future<String> getCategory() async {
    String category = "";
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.chooseCategory),
            content: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.chooseCategoryHint,
              ),
              onChanged: (value) {
                category = value;
              },
              onSubmitted: (value) {
                category = value;
                Navigator.of(context).pop();
              },
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
    return category;
  }

  /// shows a dialog to select the difficulty
  /// the difficulty is from 1 to 5
  /// 1 is very easy and 5 is very hard
  Future<int> getDifficulty() async {
    int difficulty = 1;
    await await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.chooseDifficulty),
            // drop down menu for the difficulty from 1 to 5
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return DropdownButton(
                  autofocus: true,
                  value: difficulty,
                  dropdownColor: Theme.of(context).colorScheme.background,
                  items: [
                    DropdownMenuItem(
                      value: 1,
                      child: Text(
                          AppLocalizations.of(context)!.chooseDifficultyEasy),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text(
                          AppLocalizations.of(context)!.chooseDifficultyMedium),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text(
                          AppLocalizations.of(context)!.chooseDifficultyHard),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      difficulty = value as int;
                    });
                    FocusScope.of(context).nextFocus();
                  },
                );
              },
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
    return difficulty;
  }

  /// This function is called when the active team selects a category and a difficulty
  /// It gets a question from the OpenAI API and then opens the question page
  /// If the answer was correct the points are added to the team
  void selectCategory(Team team) async {
    String category = await getCategory();
    if (category == "") {
      if (!context.mounted) return; // if the context is not mounted anymore return
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.categoryMustNotBeEmpty, style: Theme.of(context).textTheme.bodyMedium),
        ),
      );

      return;
    }
    int difficulty = await getDifficulty();

    // translate the difficulty to a string
    String? difficultyString;
    if (!context.mounted) return; // if the context is not mounted anymore return
    switch (difficulty) {
      case 1:
        difficultyString = AppLocalizations.of(context)!.chooseDifficultyEasy;
        break;
      case 2:
        difficultyString = AppLocalizations.of(context)!.chooseDifficultyMedium;
        break;
      case 3:
        difficultyString = AppLocalizations.of(context)!.chooseDifficultyHard;
        break;
    }

    Future<Question> question =
        OpenAIApi().getQuestion(category, difficultyString!, context);
    Future<Uint8List> imageUrl =
        OpenAIApi().getQuestionImage(question, category);

    // wait for the question page to return if the answer was correct
    var correct = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionPage(question: question, image: imageUrl),
      ),
    );

    // if the answer was correct add the points to the team
    if (correct == true) {
      setState(() {
        team.points += difficulty * 10;
      });
    }

    // if the last team answered the question
    if (correct != null) {
      // if null the question was not answered the same team stays active
      // next team
      if (activeTeam == widget.teams.length - 1) {
        increaseRound();
        setState(() {
          activeTeam = 0;
        });
      } else {
        setState(() {
          activeTeam++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // show all the teams with their pints and the round number
    return Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: updateRound ? Colors.white : const Color(0xFF1A212C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  AppLocalizations.of(context)!.round(round),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 446,
              child: ListView.builder(
                  itemCount: widget.teams.length,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return TeamCard(
                        team: widget.teams[index], active: index == activeTeam);
                  }),
            ),
            // the bottom to start a question
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                // a  big green button
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  onPressed: () {
                    selectCategory(widget.teams[activeTeam]);
                  },
                  child: Text(
                      AppLocalizations.of(context)!.chooseCategoryButton,
                      style:
                          const TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              //info button
              child: InfoButton(
                infoText: AppLocalizations.of(context)!.infoGamePage,
              ),
            ),
          ],
        ),
        // a button to calculate the winner
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return AwardPage(teams: widget.teams);
            }));
          },
          child: const Text("🏅", style: TextStyle(fontSize: 30)),
        ));
  }
}
