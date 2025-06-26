import 'package:drive_or_drunk_app/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';

class CustomDropdown {
  static void show({
    required BuildContext context,
    required Widget child,
    VoidCallback? onDismiss,
    Color? backgroundColor,
    BorderRadius? borderRadius,
  }) {
    showDialog(
        context: context,
        builder: (context) {
          return CustomDropdownModal(
            onDismiss: onDismiss ?? () => Navigator.of(context).pop(),
            borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.md),
            backgroundColor: backgroundColor ?? Theme.of(context).cardColor,
            child: child,
          );
        });
  }
}

class CustomDropdownModal extends StatefulWidget {
  const CustomDropdownModal(
      {super.key,
      required this.child,
      required this.onDismiss,
      required this.backgroundColor,
      required this.borderRadius});
  final Widget child;
  final VoidCallback onDismiss;
  final Color backgroundColor;
  final BorderRadius borderRadius;

  @override
  State<CustomDropdownModal> createState() => _CustomDropdownModalState();
}

class _CustomDropdownModalState extends State<CustomDropdownModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDismiss() async {
    await _animationController.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleDismiss,
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: AppSizes.appBarHeight - AppSizes.md,
                  left: AppSizes.md,
                  right: AppSizes.md),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _slideAnimation,
                    child: Material(
                      type: MaterialType.transparency,
                      child: GestureDetector(
                        onTap:
                            () {}, // Prevents the dialog from closing when tapping inside
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Arrow pointing up
                            Align(
                              alignment: const Alignment(0.95, 1),
                              child: CustomPaint(
                                painter: ArrowPainter(
                                  color: widget.backgroundColor,
                                  borderColor: Theme.of(context).dividerColor,
                                ),
                                size: const Size(40, 20),
                              ),
                            ),
                            // Modal content

                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: widget.backgroundColor,
                                borderRadius: widget.borderRadius,
                                border: Border.all(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSizes.md),
                                child: widget.child,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the arrow indicator
class ArrowPainter extends CustomPainter {
  final Color color;
  final Color? borderColor;
  final double borderWidth;

  ArrowPainter({
    required this.color,
    this.borderColor,
    this.borderWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(size.width * 0.2, size.height);
    path.lineTo(size.width * 0.8, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Draw border if specified
    if (borderColor != null) {
      final borderPaint = Paint()
        ..color = borderColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is ArrowPainter &&
        (oldDelegate.color != color ||
            oldDelegate.borderColor != borderColor ||
            oldDelegate.borderWidth != borderWidth);
  }
}
