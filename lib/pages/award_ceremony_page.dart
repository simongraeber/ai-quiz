import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/team.dart';
import '../utils/image_construktion.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import '../widgets/inf_button.dart';
import '../widgets/team_points_animation.dart';
import 'dart:typed_data';

/// this page is used to display the places of the teams and to download a picture of the podium
class AwardPage extends StatefulWidget { // todo fix for mobile
  const AwardPage({Key? key, required this.teams}) : super(key: key);
  final List<Team> teams;

  @override
  State<AwardPage> createState() => _AwardPageState();
}

class _AwardPageState extends State<AwardPage>
    with SingleTickerProviderStateMixin {
  bool _teamsPresented = false;
  final List<int> _presentedTeam = [];
  bool initial = true;
  final Duration _duration = const Duration(seconds: 5);
  late Future<Uint8List> _image;
  late Uint8List? _imageComplete;
  bool _completeImage = false;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final displayTeamController = DisplayTeamController();

  Future<Uint8List> getCompleteImage(Uint8List background) async {
    if (_completeImage == true) {
      return Future.value(_imageComplete!);
    }
    _completeImage = true;
    _imageComplete = await getPodiumImageWithOpenAI(widget.teams, background);
    return _imageComplete!;
  }

  /// a entry in the list of teams with their place, name and points
  /// [place] the place of the team
  /// [teamName] the name of the team
  /// [points] the points of the team
  /// [animation] the animation of the entry
  Widget _listTileAnimated(
      int place, String teamName, int points, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        child: ListTile(
          tileColor: Theme.of(context).canvasColor,
          leading: Text(place.toString(), style: Theme.of(context).textTheme.titleMedium,),
          title: Text(teamName, style: Theme.of(context).textTheme.titleMedium,),
          trailing: Text(points.toString(), style: Theme.of(context).textTheme.titleMedium,),
        ),
      ),
    );
  }

  /// this function is controlling the animation of the list
  /// it shows one team after another
  void _presentTeams() async {
    await Future.delayed(const Duration(seconds: 1));
    for (int i = 0; i < widget.teams.length; i++) {
      int teamNumber = (widget.teams.length - 1) - i;
      displayTeamController.showTeam(teamNumber);
      await Future.delayed(const Duration(seconds: 1));
      _presentedTeam.insert(0, teamNumber);
      _listKey.currentState!.insertItem(0);
      await Future.delayed(_duration);
    }
    setState(() {
      _teamsPresented = true;
    });
  }

  /// shows the podiums Image and download button
  Widget podiumsImage(Uint8List image, double size) {
    return Stack(alignment: Alignment.topCenter, children: [
      Image.memory(image, height: size, width: size),
      Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: IconButton(
            onPressed: () {
              downloadImage(image);
            },
            icon: const Icon(
              Icons.download,
            ),
            tooltip: "download",
          ),
        ),
      )
    ]);
  }

  @override
  initState() {
    super.initState();
    widget.teams.sort((a, b) => b.points.compareTo(a.points));
  }

  @override
  Widget build(BuildContext context) {
    double imageSize = 500;
    double tableHeight = MediaQuery.of(context).size.height - imageSize - 50;
    double paddingAboveImage = 0;

    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      if (MediaQuery.of(context).size.width > 600) {
        imageSize = MediaQuery.of(context).size.height * 0.8 - 300;
        paddingAboveImage = MediaQuery.of(context).size.height * 0.05;
        tableHeight = MediaQuery.of(context).size.height - imageSize  - paddingAboveImage - 50;

      }
    } else {
      if (MediaQuery.of(context).size.width > 600) {
        tableHeight = MediaQuery.of(context).size.height - imageSize - 50;
      }
    }

    if (initial) {
      initial = false;
      _image = getPodiumImage(widget.teams);
      _presentTeams();
    }
    return Scaffold(
        body: Stack(children: [
          Stack(
            children: [
              // The team images and the podium
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: paddingAboveImage),
                  child: FutureBuilder(
                      future: _image,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && _teamsPresented) {
                          Uint8List image = snapshot.data as Uint8List;
                          return Stack(
                            children: [
                              podiumsImage(image, imageSize),
                              FutureBuilder(
                                future: getCompleteImage(image),
                                builder: (context, openAIImage) {
                                  if(openAIImage.hasError){
                                    return const SizedBox();
                                  }else if (openAIImage.hasData) {
                                    return TweenAnimationBuilder<double>(
                                        tween: Tween<double>(begin: 0.0, end: 1),
                                        curve: Curves.easeIn,
                                        duration: const Duration(seconds: 5),
                                        builder: (BuildContext context,
                                            double opacity, Widget? child) {
                                          return Opacity(
                                            opacity: opacity,
                                            child: openAIImage.data == null? const SizedBox() : podiumsImage(openAIImage.data!, imageSize),
                                          );
                                        });
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ],
                          );
                        } else {
                          return ChangeNotifierProvider.value(
                              value: displayTeamController,
                              child: AnimateTeams(teams: widget.teams, imageSize: imageSize,));
                        }
                      }),
                ),
              ),
              // table with the teams
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  constraints: BoxConstraints(maxWidth: 600, minHeight: tableHeight),
                  child: AnimatedList(
                    shrinkWrap: true,
                    initialItemCount: 0,
                    key: _listKey,
                    itemBuilder: (context, index, animation) {
                      return _listTileAnimated(
                          _presentedTeam[index] + 1,
                          widget.teams[_presentedTeam[index]].name,
                          widget.teams[_presentedTeam[index]].points,
                          animation);
                    },
                  ),
                ),
              ),
            ],
          ),
          // info button
          Align(
            alignment: Alignment.topLeft,
            //info button
            child: InfoButton(infoText: AppLocalizations.of(context)!.infoRankingPage,),

          ),
        ]));
  }
}
