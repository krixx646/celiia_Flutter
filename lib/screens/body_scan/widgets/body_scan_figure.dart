import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/body_scan.dart';
import '../../../providers/theme_provider.dart';

/// A drawn body with the measured bands marked on it.
///
/// This is the results visual. The scan still estimates shape on the server,
/// but the phone never loads a 3D mesh.
class BodyScanFigure extends StatelessWidget {
  const BodyScanFigure({super.key, required this.theme, required this.scan});

  final ThemeProvider theme;
  final BodyScan scan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final thigh = _girthCm(scan, 'thighGirthR');
    final marks = <_Mark>[
      if (scan.bustCm != null)
        _Mark(0.30, l10n.bodyScanChest, scan.bustCm!),
      if (scan.waistCm != null)
        _Mark(0.42, l10n.bodyScanWaist, scan.waistCm!),
      if (scan.hipCm != null) _Mark(0.54, l10n.bodyScanHip, scan.hipCm!),
      if (thigh != null) _Mark(0.68, l10n.bodyScanThigh, thigh),
    ];

    return Container(
      height: 260,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.border),
      ),
      child: CustomPaint(
        painter: _FigurePainter(
          line: theme.textPrimary.withValues(alpha: 0.85),
          band: theme.accentOrange,
          label: theme.textSecondary,
          marks: marks,
        ),
      ),
    );
  }
}

double? _girthCm(BodyScan scan, String name) {
  for (final m in scan.measurements) {
    if (m.name == name && m.value > 0) return m.centimetres;
  }
  return null;
}

class _Mark {
  const _Mark(this.heightFraction, this.label, this.centimetres);

  /// Distance down the drawn body, from 0 at the top of the head.
  final double heightFraction;
  final String label;
  final double centimetres;
}

class _FigurePainter extends CustomPainter {
  _FigurePainter({
    required this.line,
    required this.band,
    required this.label,
    required this.marks,
  });

  final Color line;
  final Color band;
  final Color label;
  final List<_Mark> marks;

  @override
  void paint(Canvas canvas, Size size) {
    final bodyHeight = size.height * 0.92;
    final top = (size.height - bodyHeight) / 2;
    final centreX = size.width * 0.32;

    final path = _frontPath(centreX, top, bodyHeight);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.fill
        ..color = line.withValues(alpha: 0.06),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..color = line.withValues(alpha: 0.55),
    );

    final labelStyle = TextStyle(
      color: label,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    );

    for (final mark in marks) {
      final y = top + bodyHeight * mark.heightFraction;
      final from = Offset(centreX + bodyHeight * 0.12, y);
      final to = Offset(size.width * 0.58, y);
      canvas.drawLine(
        from,
        to,
        Paint()
          ..color = band
          ..strokeWidth = 1.5,
      );
      canvas.drawCircle(from, 3.5, Paint()..color = band);

      final text = TextPainter(
        text: TextSpan(
          text: '${mark.label}  ${mark.centimetres.toStringAsFixed(1)} cm',
          style: labelStyle,
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: size.width - to.dx - 4);
      text.paint(canvas, Offset(to.dx + 6, y - text.height / 2));
    }
  }

  /// Front outline in the same stance as the camera guide.
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

  @override
  bool shouldRepaint(_FigurePainter oldDelegate) =>
      oldDelegate.line != line ||
      oldDelegate.band != band ||
      oldDelegate.marks.length != marks.length;
}
