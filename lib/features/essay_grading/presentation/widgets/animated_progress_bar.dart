import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Animated gradient progress bar (purple → blue)
/// Used in splash screen and analyzing screen
class AnimatedProgressBar extends StatefulWidget {
  /// If null, shows indeterminate animation
  final double? progress;

  /// Height of the progress bar
  final double height;

  const AnimatedProgressBar({
    super.key,
    this.progress,
    this.height = 6,
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.progress != null) {
      // Determinate progress bar
      return Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(widget.height / 2),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: widget.progress!.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.purpleBlueGradient,
              borderRadius: BorderRadius.circular(widget.height / 2),
            ),
          ),
        ),
      );
    }

    // Indeterminate progress bar
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.height / 2),
            child: Stack(
              children: [
                Positioned(
                  left: (MediaQuery.of(context).size.width - 80) *
                      _controller.value -
                      60,
                  child: Container(
                    width: 120,
                    height: widget.height,
                    decoration: BoxDecoration(
                      gradient: AppColors.purpleBlueGradient,
                      borderRadius: BorderRadius.circular(widget.height / 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
