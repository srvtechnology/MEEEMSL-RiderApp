import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// SwipeButton provides an intuitive swipe-to-confirm action
/// preventing accidental taps for critical rider steps (Pickup, Complete Delivery).
class SwipeButton extends StatefulWidget {
  final String text;
  final VoidCallback onSwiped;
  final Color activeColor;
  final Color backgroundColor;
  final IconData icon;
  final bool isCompleted;

  const SwipeButton({
    super.key,
    required this.text,
    required this.onSwiped,
    this.activeColor = AppColors.primary,
    this.backgroundColor = AppColors.primaryContainer,
    this.icon = Icons.arrow_forward_rounded,
    this.isCompleted = false,
  });

  @override
  State<SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<SwipeButton> {
  double _dragPosition = 0.0;
  bool _isConfirmed = false;

  @override
  Widget build(BuildContext context) {
    const double height = 58.0;
    const double thumbSize = 48.0;
    const double padding = 5.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDrag = constraints.maxWidth - thumbSize - (padding * 2);

        return Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: widget.activeColor.withAlpha(50),
              width: 1.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Center Label
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: thumbSize),
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: widget.activeColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              // Active Swipe Trail
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: _dragPosition + thumbSize + padding * 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.activeColor.withAlpha(40),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              // Draggable Thumb
              Positioned(
                left: padding + _dragPosition,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isConfirmed) return;
                    setState(() {
                      _dragPosition += details.delta.dx;
                      if (_dragPosition < 0) _dragPosition = 0;
                      if (_dragPosition > maxDrag) _dragPosition = maxDrag;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isConfirmed) return;
                    if (_dragPosition >= maxDrag * 0.75) {
                      // Trigger confirmation
                      setState(() {
                        _dragPosition = maxDrag;
                        _isConfirmed = true;
                      });
                      HapticFeedback.heavyImpact();
                      widget.onSwiped();
                    } else {
                      // Snap back
                      setState(() {
                        _dragPosition = 0.0;
                      });
                    }
                  },
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: widget.activeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.activeColor.withAlpha(100),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
