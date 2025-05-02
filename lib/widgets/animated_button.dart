import 'package:flutter/material.dart';
import '../utils/app_style.dart';

class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? color;
  final bool outlined;
  final IconData? icon;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.outlined = false,
    this.icon,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppStyle.defaultAnimationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = widget.outlined
        ? OutlinedButton.styleFrom(
            foregroundColor: widget.color ?? Theme.of(context).primaryColor,
            side: BorderSide(
              color: widget.color ?? Theme.of(context).primaryColor,
              width: _isHovered ? 2 : 1,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: AppStyle.defaultBorderRadius),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            foregroundColor: widget.color != null
                ? ThemeData.estimateBrightnessForColor(widget.color!) == Brightness.light
                    ? Colors.black
                    : Colors.white
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: AppStyle.defaultBorderRadius),
          );

    Widget buttonChild = ScaleTransition(
      scale: _scaleAnimation,
      child: widget.icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon),
                const SizedBox(width: 8),
                widget.child,
              ],
            )
          : widget.child,
    );

    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: widget.outlined
          ? OutlinedButton(
              onPressed: widget.onPressed,
              style: buttonStyle,
              child: buttonChild,
            )
          : ElevatedButton(
              onPressed: widget.onPressed,
              style: buttonStyle,
              child: buttonChild,
            ),
    );
  }
}
