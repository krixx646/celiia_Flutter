import 'package:flutter/material.dart';

/// Which of the two required photos the user is taking.
enum BodyScanPose { front, right }

/// Full-body alignment guide drawn over the camera preview.
///
/// Capture quality is the single biggest driver of whether the vendor can
/// produce a result at all, so this is doing real work rather than decoration:
/// the user has to be whole-body in frame, centred, and far enough back. The
/// silhouette is deliberately generous — it is an alignment aid, not a shape
/// the body has to match.
class BodySilhouetteOverlay extends StatelessWidget {
  const BodySilhouetteOverlay({
    super.key,
    required this.pose,
    this.aligned = false,
  });

  final BodyScanPose pose;

  /// Tints the guide once the countdown starts, so the user gets a signal
  /// that holding still now matters.
  final bool aligned;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _SilhouettePainter(
          pose: pose,
          color: aligned ? const Color(0xFF4ADE80) : Colors.white,
        ),
      ),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  _SilhouettePainter({required this.pose, required this.color});

  final BodyScanPose pose;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Leave headroom and footroom: the vendor rejects photos where the body is
    // cropped, and users consistently stand too close.
    final bodyHeight = size.height * 0.78;
    final top = (size.height - bodyHeight) / 2;
    final centreX = size.width / 2;

    final path = pose == BodyScanPose.front
        ? _frontPath(centreX, top, bodyHeight)
        : _sidePath(centreX, top, bodyHeight);

    // Dim everything outside the guide so the target area reads instantly.
    final scrim = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addPath(path, Offset.zero)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(scrim, Paint()..color = Colors.black.withValues(alpha: 0.45));

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = color.withValues(alpha: 0.9),
    );

    _drawFloorLine(canvas, size, top + bodyHeight);
    _drawHeadLine(canvas, size, top);
  }

  /// Rough front-facing outline: head, shoulders, arms held slightly out,
  /// and legs a little apart — the A-pose the vendor's guidelines ask for.
  Path _frontPath(double cx, double top, double h) {
    final headR = h * 0.075;
    final shoulderY = top + h * 0.19;
    final shoulderHalf = h * 0.115;
    final hipY = top + h * 0.52;
    final hipHalf = h * 0.09;
    final footY = top + h;
    final handHalf = h * 0.20;
    final handY = top + h * 0.46;

    return Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, top + headR), radius: headR))
      // Torso down the left, out to the hand, back in to the hip.
      ..moveTo(cx - headR * 0.5, top + headR * 1.9)
      ..lineTo(cx - shoulderHalf, shoulderY)
      ..lineTo(cx - handHalf, handY)
      ..lineTo(cx - handHalf * 0.82, handY + h * 0.03)
      ..lineTo(cx - hipHalf * 1.05, hipY)
      ..lineTo(cx - hipHalf, footY)
      ..lineTo(cx - hipHalf * 0.25, footY)
      ..lineTo(cx, hipY + h * 0.06)
      ..lineTo(cx + hipHalf * 0.25, footY)
      ..lineTo(cx + hipHalf, footY)
      ..lineTo(cx + hipHalf * 1.05, hipY)
      ..lineTo(cx + handHalf * 0.82, handY + h * 0.03)
      ..lineTo(cx + handHalf, handY)
      ..lineTo(cx + shoulderHalf, shoulderY)
      ..lineTo(cx + headR * 0.5, top + headR * 1.9)
      ..close();
  }

  /// Side-on outline: narrower, with the arm hanging in front of the torso.
  Path _sidePath(double cx, double top, double h) {
    final headR = h * 0.075;
    final shoulderY = top + h * 0.19;
    final depthHalf = h * 0.075;
    final hipY = top + h * 0.52;
    final footY = top + h;

    return Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, top + headR), radius: headR))
      ..moveTo(cx - depthHalf * 0.6, top + headR * 1.9)
      ..lineTo(cx - depthHalf, shoulderY)
      ..lineTo(cx - depthHalf * 1.15, hipY)
      ..lineTo(cx - depthHalf * 0.9, footY)
      ..lineTo(cx + depthHalf * 1.3, footY)
      ..lineTo(cx + depthHalf * 1.1, hipY)
      ..lineTo(cx + depthHalf * 1.2, shoulderY)
      ..lineTo(cx + depthHalf * 0.6, top + headR * 1.9)
      ..close();
  }

  void _drawFloorLine(Canvas canvas, Size size, double y) {
    _dashedLine(canvas, size, y);
  }

  void _drawHeadLine(Canvas canvas, Size size, double y) {
    _dashedLine(canvas, size, y);
  }

  void _dashedLine(Canvas canvas, Size size, double y) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeWidth = 1.5;

    const dash = 10.0;
    const gap = 8.0;
    for (double x = 16; x < size.width - 16; x += dash + gap) {
      canvas.drawLine(Offset(x, y), Offset(x + dash, y), paint);
    }
  }

  @override
  bool shouldRepaint(_SilhouettePainter oldDelegate) =>
      oldDelegate.pose != pose || oldDelegate.color != color;
}
