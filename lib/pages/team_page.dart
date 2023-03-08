import 'package:flutter/material.dart';
import '../utils/team.dart';
import '../pages/game_vew_page.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import '../widgets/animated_elevated_button.dart';
import '../widgets/inf_button.dart';

/// this page is used to create teams and to start the game
class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  List<Team> teams = [];

  /// this function is called when the user clicks on the "add team" button
  /// it shows a dialog and asks for a team name
  Future<String> updateName(context) async {
    // shows a dialog and asking for a team name
    String teamName = "";
    // use HTML dialog to get the team name

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.teamName),
            content: TextField(
              autofocus: true,
              onChanged: (value) {
                teamName = value;
              },
              onSubmitted: (value) {
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
    return teamName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // name and list
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.theTeam,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 30),
              // list of teams
              SizedBox(
                width: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        tileColor: Theme.of(context).canvasColor,
                        title: Text(teams[index].name),
                        trailing: IconButton(
                          icon: Icon(Icons.delete,
                              color: Colors.red.withOpacity(0.5)),
                          onPressed: () {
                            setState(() {
                              teams.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              AnimatedElevatedButton(
                onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GameVew(teams: teams)),
                    );
                },
                onInactivePressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.noTeamAdded),
                    ),
                  );
                },
                isActive: teams.isNotEmpty,
                child: Text(AppLocalizations.of(context)!.start),
              ),
            ],
          ),
          //info button
          Align(
            alignment: Alignment.topLeft,
            child: InfoButton(infoText: AppLocalizations.of(context)!.infoTeamPage,),
          ),
        ],
      ),
      // add team button
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String teamName = await updateName(context);
          if (teamName != "") {
            Team team = Team(name: teamName);
            team.setImage();
            setState(() {
              teams.add(team);
            });
          }else{
            if (!context.mounted) return; // if the context is not mounted anymore return
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.emptyTeamName),
              ),
            );
          }
        },
        tooltip: AppLocalizations.of(context)!.addTeam,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
