import 'package:flutter/material.dart';

/// this is a elevated button
/// [isActive] when false the button is not clickable and has a different background color
/// [isLoading] when true the button shows a loading animation
/// [onInactivePressed] is called when the button is not active and is pressed
/// [onPressed] is called when the button is active and is pressed
/// [child] is the child of the button
class AnimatedElevatedButton extends StatefulWidget {
  const AnimatedElevatedButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.isActive = true,
    this.isLoading = false,
    this.onInactivePressed
  }) : super(key: key);

  final bool isActive;
  final Widget child;
  final VoidCallback onPressed;
  final VoidCallback? onInactivePressed;
  final bool isLoading;

  @override
  State<AnimatedElevatedButton> createState() => _AnimatedElevatedButtonState();
}

class _AnimatedElevatedButtonState extends State<AnimatedElevatedButton> with SingleTickerProviderStateMixin {
  // controller and animation for the loading animation
  late final AnimationController _controller;
  late final Animation<double> _animation;

  final Duration _animationDuration = const Duration(milliseconds: 1000);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        //how can a show a elevated Button but on pc don't show mouse cursor as hand
        onPressed: () {
          if (widget.isActive) {
            widget.onPressed();
          } else {
            widget.onInactivePressed?.call();
          }
        },
        // if the button is active and not loading, the style is the default style
        style: widget.isActive
            ? ElevatedButton.styleFrom()
            // if the button is not active or loading, the style is the default style with a different background color
            : ButtonStyle(
                mouseCursor: MaterialStateProperty.all<MouseCursor>(
                    SystemMouseCursors.basic),
                backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).primaryColor.withOpacity(0.3),
                ),
                overlayColor: MaterialStateProperty.all<Color>(
                  Colors.transparent,
                ),
                elevation: MaterialStateProperty.all(0),
              ),
        // if the button is loading, the opacity of the child is circling between 0 and 1
        child: widget.isLoading
            ? AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _animation.value,
                    child: child,
                  );
                },
                child: widget.child,
              )
            // if the button is not loading, the child is shown
            : widget.child
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
