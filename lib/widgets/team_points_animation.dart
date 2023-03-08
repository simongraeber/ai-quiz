import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz/utils/team.dart';


/// used to animate the images and names of teams
/// to change the team displayed use the [DisplayTeamController]
/// [teams] the teams that will be displayed
/// [imageSize] the size of the images
/// this widget is used in [AwardPage]
class AnimateTeams extends StatefulWidget {
  const AnimateTeams({Key? key, required this.teams, required this.imageSize}) : super(key: key);

  final List<Team> teams; // they will be displayed in reverse order
  final double imageSize;

  @override
  State<AnimateTeams> createState() => _AnimateTeamsState();
}

class _AnimateTeamsState extends State<AnimateTeams>
    with SingleTickerProviderStateMixin {
  Widget? displayedTeam;

  @override
  Widget build(BuildContext context) {

    final controller = Provider.of<DisplayTeamController>(context);
    int? number = controller.teamNumber;

    return AnimatedSwitcher(duration: const Duration(milliseconds: 500),
      child: number == null
        ? const Center(
      child: Text(
        "🎉 ",
        style: TextStyle(fontSize: 60),
      ),
    ) : _AnimatedTeamImageAndName(
          team: widget.teams[number], teamNumber: number, size: widget.imageSize),
    );
  }
}

/// whats for the teamImage then animates the image and the TeamPoints
class _AnimatedTeamImageAndName extends StatefulWidget {
  const _AnimatedTeamImageAndName(
      {Key? key, required this.team, required this.teamNumber, required this.size})
      : super(key: key);
  final Team team;
  final double size;
  final int teamNumber;

  @override
  State<_AnimatedTeamImageAndName> createState() =>
      _AnimatedTeamImageAndNameState();
}

class _AnimatedTeamImageAndNameState extends State<_AnimatedTeamImageAndName>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.team.image,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // move from top in
          return _AnimatedTeamImage(
            image: snapshot.data!,
            name: widget.team.name,
            teamNumber: widget.teamNumber,
            size: widget.size,
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}

/// used to animate the image of the team
/// fades in and moves from top to bottom
class _AnimatedTeamImage extends StatefulWidget {
  const _AnimatedTeamImage(
      {Key? key,
      required this.image,
        required this.size,
      required this.name,
      required this.teamNumber})
      : super(key: key);
  final Uint8List image;
  final double size;
  final String name;
  final int teamNumber;

  @override
  State<_AnimatedTeamImage> createState() => _AnimatedTeamImageState();
}

class _AnimatedTeamImageState extends State<_AnimatedTeamImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _sizeAnimation;
  int? _lastTeamNumber;

  @override
  void initState() {
    super.initState();
    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), //const Duration(milliseconds: 500),
    );
    _opacityAnimation =
        Tween<double>(begin: 0, end: 1).animate(_imageController);
    _sizeAnimation = Tween<double>(begin: 0, end: 1).animate(_imageController);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.teamNumber != _lastTeamNumber) {
      _imageController.reset();
      _imageController.forward();
      _lastTeamNumber = widget.teamNumber;
    }

    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: Center(
        child: AnimatedBuilder(
          animation: _imageController,
          builder: (context, child) {
            return SizedBox(
                width: _sizeAnimation.value * widget.size,
                height: _sizeAnimation.value * widget.size,
                child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Image.memory(
                          widget.image,
                          fit: BoxFit.cover,
                          width: widget.size,
                          height: widget.size,
                        ),
                        Container(
                          width: widget.size,
                          color: Theme.of(context)
                              .colorScheme
                              .background
                              .withAlpha(200),
                          child: Text(
                            widget.name,
                            style: TextStyle(
                              fontSize: _sizeAnimation.value * 20,
                            ),
                          ),
                        ),
                      ],
                    )
                )
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }
}

/// This Controller is used to notify that the next team should be displayed
class DisplayTeamController extends ChangeNotifier {
  int? _teamNumber;

  int? get teamNumber => _teamNumber;

  void showTeam(int value) {
    _teamNumber = value;
    notifyListeners();
  }
}
