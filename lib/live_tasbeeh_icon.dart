import 'dart:math' as math;
import 'package:flutter/material.dart';

class LiveTasbeehIcon extends StatefulWidget {
  final double size;
  final Color color;
  final bool animate;
  final bool isSelected;

  const LiveTasbeehIcon({
    super.key,
    this.size = 22,
    this.color = const Color(0xFF00E676),
    this.animate = true,
    this.isSelected = false,
  });

  @override
  State<LiveTasbeehIcon> createState() => _LiveTasbeehIconState();
}

class _LiveTasbeehIconState extends State<LiveTasbeehIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant LiveTasbeehIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _TasbeehPainter(
              color: widget.color,
              progress: widget.animate ? _controller.value : 0.0,
              isSelected: widget.isSelected,
            ),
          );
        },
      ),
    );
  }
}

class _TasbeehPainter extends CustomPainter {
  final Color color;
  final double progress;
  final bool isSelected;

  const _TasbeehPainter({
    required this.color,
    required this.progress,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Center and loop radii
    final double cx = w * 0.50;
    final double cy = h * 0.38;
    final double rx = w * 0.35;
    final double ry = h * 0.27;

    const int numBeads = 11;
    const double startAngle = 0.58 * math.pi;
    const double totalAngle = 1.84 * math.pi;

    // 1. Thread String Paint
    final threadPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.8, w * 0.035);

    final rect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: rx * 2,
      height: ry * 2,
    );
    canvas.drawArc(rect, startAngle, totalAngle, false, threadPaint);

    // Connecting string to Imam bead
    final double imamTopX = cx;
    final double imamTopY = cy + ry + (h * 0.02);
    canvas.drawLine(
      Offset(cx - rx * 0.22, cy + ry * 0.94),
      Offset(imamTopX, imamTopY),
      threadPaint,
    );
    canvas.drawLine(
      Offset(cx + rx * 0.22, cy + ry * 0.94),
      Offset(imamTopX, imamTopY),
      threadPaint,
    );

    // 2. Loop Beads with Live Traveling Shimmer
    final double beadRadius = w * 0.075;

    for (int i = 0; i < numBeads; i++) {
      final double fraction = i / (numBeads - 1);
      final double angle = startAngle + (totalAngle * fraction);

      final double bx = cx + rx * math.cos(angle);
      final double by = cy + ry * math.sin(angle);

      // Traveling light wave effect (smooth dhikr shimmer)
      final double wave =
          (math.sin((progress * 2 * math.pi) - (i * 0.6)) + 1.0) / 2.0;

      // Soft glow around highlighted bead
      if (wave > 0.65) {
        final glowPaint = Paint()
          ..color = color.withValues(alpha: 0.32 * wave)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);
        canvas.drawCircle(Offset(bx, by), beadRadius + 1.5, glowPaint);
      }

      // Bead Body
      final beadPaint = Paint()
        ..color = Color.lerp(
          color.withValues(alpha: 0.85),
          Colors.white,
          wave * 0.55,
        )!
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(bx, by), beadRadius, beadPaint);

      // Specular Reflection Highlight on pearl
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6 + (wave * 0.35))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(bx - beadRadius * 0.3, by - beadRadius * 0.3),
        beadRadius * 0.36,
        highlightPaint,
      );
    }

    // 3. Imam Bead (Minaret / Gathering Headpiece)
    final double imamWidth = w * 0.12;
    final double imamHeight = h * 0.16;
    final double imamY = imamTopY;

    final imamRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, imamY + imamHeight / 2),
        width: imamWidth,
        height: imamHeight,
      ),
      Radius.circular(imamWidth / 2),
    );

    final imamPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRRect(imamRect, imamPaint);

    // Collar ring on Imam
    final collarPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(cx, imamY + imamHeight * 0.32),
      imamWidth * 0.28,
      collarPaint,
    );

    // 4. Live Silk Tassel Swaying Smoothly
    final double tasselStartY = imamY + imamHeight;
    final double sway = math.sin(progress * 2 * math.pi) * (w * 0.045);

    final tasselPaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.9, w * 0.04)
      ..strokeCap = StrokeCap.round;

    // Center silk strand
    final centerTip = Offset(cx + sway * 0.6, h * 0.95);
    canvas.drawLine(Offset(cx, tasselStartY), centerTip, tasselPaint);

    // Left silk strand
    final leftTip = Offset(cx - (w * 0.08) + sway, h * 0.92);
    canvas.drawLine(Offset(cx, tasselStartY), leftTip, tasselPaint);

    // Right silk strand
    final rightTip = Offset(cx + (w * 0.08) + sway, h * 0.92);
    canvas.drawLine(Offset(cx, tasselStartY), rightTip, tasselPaint);

    // Tassel Pearl Tips
    final tipPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(centerTip, w * 0.035, tipPaint);
    canvas.drawCircle(leftTip, w * 0.03, tipPaint);
    canvas.drawCircle(rightTip, w * 0.03, tipPaint);
  }

  @override
  bool shouldRepaint(covariant _TasbeehPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isSelected != isSelected;
  }
}
