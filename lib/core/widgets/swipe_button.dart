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
  final bool isLoading;

  const SwipeButton({
    super.key,
    required this.text,
    required this.onSwiped,
    this.activeColor = AppColors.primary,
    this.backgroundColor = AppColors.primaryContainer,
    this.icon = Icons.arrow_forward_rounded,
    this.isCompleted = false,
    this.isLoading = false,
  });

  @override
  State<SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<SwipeButton> with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  bool _isConfirmed = false;
  AnimationController? _animController;
  Animation<double>? _anim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        if (_anim != null) {
          setState(() {
            _dragPosition = _anim!.value;
          });
        }
      });
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  void reset() {
    if (mounted) {
      _animController?.stop();
      setState(() {
        _dragPosition = 0.0;
        _isConfirmed = false;
      });
    }
  }

  void _animateTo(double target) {
    if (!mounted || _animController == null) return;
    _animController!.stop();
    _anim = Tween<double>(begin: _dragPosition, end: target).animate(
      CurvedAnimation(parent: _animController!, curve: Curves.easeOutCubic),
    );
    _animController!.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(SwipeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset if text changed (milestone progressed) or if loading stopped without confirmation
    if (widget.text != oldWidget.text ||
        widget.isCompleted != oldWidget.isCompleted ||
        (oldWidget.isLoading && !widget.isLoading && !widget.isCompleted)) {
      reset();
    }
  }

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
              // Center Label - responsive with padding to prevent collision with thumb
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: thumbSize + 8),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.text,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: widget.activeColor,
                        letterSpacing: 0.2,
                      ),
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
                    if (_isConfirmed || widget.isLoading) return;
                    setState(() {
                      _dragPosition += details.delta.dx;
                      if (_dragPosition < 0) _dragPosition = 0;
                      if (_dragPosition > maxDrag) _dragPosition = maxDrag;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isConfirmed || widget.isLoading) return;
                    if (_dragPosition >= maxDrag * 0.70) {
                      // Trigger confirmation
                      setState(() {
                        _dragPosition = maxDrag;
                        _isConfirmed = true;
                      });
                      HapticFeedback.heavyImpact();
                      widget.onSwiped();
                    } else {
                      // Smooth snap back
                      _animateTo(0.0);
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
                    child: Center(
                      child: widget.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(
                              widget.icon,
                              color: Colors.white,
                              size: 24,
                            ),
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
