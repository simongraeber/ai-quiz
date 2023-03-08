import 'package:flutter/material.dart';
import '../utils/team.dart';

/// A card with the team name, the points, and the Image of the team
/// active is a bool to show if the team is the active team or not active team will be bigger
/// [team] the team to display
/// [active] if the team is active or not the active team will be bigger
class TeamCard extends StatefulWidget {
  const TeamCard({Key? key, required this.team, this.active = true})
      : super(key: key);
  final Team team;
  final bool active;

  @override
  State<TeamCard> createState() => _TeamCardState();
}

class _TeamCardState extends State<TeamCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedContainer(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color(0xFF000917),
          ),
          duration: const Duration(milliseconds: 800),
          constraints: BoxConstraints(
            maxWidth: widget.active ? 300 : 100,
            maxHeight: widget.active ? 300 : 100,
          ),
          child: IntrinsicHeight(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  constraints: BoxConstraints(
                    maxWidth: widget.active ? 300.0 : 100.0,
                    maxHeight: widget.active ? 300.0 : 100.0,
                  ),
                  child: widget.team.image != null
                      ? FutureBuilder(
                          future: widget.team.image!,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                              );
                            } else {
                              return Container(
                                color: const Color(0xFF1A212C),
                              );
                            }
                          },
                        )
                      : Container(
                          color: const Color(0xFF1A212C),
                        ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      height: widget.active ? 180 : 70,
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      height: widget.active ? 250 : 100,
                      child: CustomPaint(
                        size: const Size(300, 250),
                        painter: ImageOverlayPainter(),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 800),
                        textAlign: TextAlign.center,
                        style: widget.active
                            ? Theme.of(context).textTheme.displaySmall!
                            : Theme.of(context).textTheme.bodyLarge!,
                        child: Text(
                          widget.team.name,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 5),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 800),
                        style: widget.active
                            ? Theme.of(context).textTheme.displayLarge!
                            : Theme.of(context).textTheme.headlineSmall!,
                        child: Text(widget.team.points.toString()),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        height: widget.active ? 0 : 75,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

/// the overlay for the team card
class ImageOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path0 = Path();
    path0.moveTo(size.width, size.height);
    path0.lineTo(size.width, 0);
    path0.cubicTo(size.width * 0.7, size.height * 0.1, size.width * 0.5,
        size.height * 0.20, size.width * 0.1, size.height * 0.25);
    path0.lineTo(0, size.height * 0.25);
    path0.lineTo(0, size.height);
    path0.close();

    Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = const Color(0xFF1E4788).withOpacity(0.4);
    canvas.drawPath(path0, paint0Fill);

    Path path1 = Path();
    path1.moveTo(size.width, size.height);
    path1.lineTo(size.width, size.height * 0.05);
    path1.cubicTo(size.width * 0.7, size.height * 0.15, size.width * 0.5,
        size.height * 0.25, size.width * 0.1, size.height * 0.28);
    path1.lineTo(0, size.height * 0.28);
    path1.lineTo(0, size.height);
    path1.close();

    Paint paint1Fill = Paint()..style = PaintingStyle.fill;
    paint1Fill.color = const Color(0xFF222B39).withOpacity(0.5);
    canvas.drawPath(path1, paint1Fill);

    Path path2 = Path();
    path2.moveTo(size.width, size.height);
    path2.lineTo(size.width, size.height * 0.1);
    path2.cubicTo(size.width * 0.7, size.height * 0.18, size.width * 0.5,
        size.height * 0.28, size.width * 0.1, size.height * 0.31);
    path2.lineTo(0, size.height * 0.31);
    path2.lineTo(0, size.height);
    path2.close();

    Paint paint2Fill = Paint()..style = PaintingStyle.fill;
    paint2Fill.color = const Color(0xFF000917).withOpacity(1.0);
    canvas.drawPath(path2, paint2Fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
