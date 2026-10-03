import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../l10n/app_localizations.dart';

/// Shows whether the phone is upright enough for a body scan.
///
/// Bodygram's own flow relies on this: the phone sits on the floor or a low
/// surface facing the user, and a small lean back is fine, but a sideways
/// roll ruins framing. Green means hold and capture; amber means straighten.
class PhoneLevelBanner extends StatefulWidget {
  const PhoneLevelBanner({super.key});

  @override
  State<PhoneLevelBanner> createState() => _PhoneLevelBannerState();
}

class _PhoneLevelBannerState extends State<PhoneLevelBanner> {
  StreamSubscription<AccelerometerEvent>? _sub;
  bool _level = true;
  bool _hasReading = false;

  @override
  void initState() {
    super.initState();
    _sub = accelerometerEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    ).listen(
      _onAccel,
      onError: (_) {
        // No accelerometer (emulator / denied): stay quiet rather than
        // blocking capture behind a permanent warning.
        if (mounted) setState(() => _hasReading = false);
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onAccel(AccelerometerEvent e) {
    // Device coords: x right, y up, z out of screen. Upright portrait with a
    // slight lean has |y| dominant and |x| small. Flat on a table fails.
    final magnitude = math.sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
    if (magnitude < 1) return;
    final nx = e.x / magnitude;
    final ny = e.y / magnitude;
    final level = nx.abs() < 0.28 && ny.abs() > 0.72;
    if (!_hasReading || level != _level) {
      setState(() {
        _hasReading = true;
        _level = level;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasReading) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final color = _level ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24);
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Icon(
            _level ? Icons.check_circle_outline : Icons.screen_rotation_alt,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _level ? l10n.bodyScanLevelOk : l10n.bodyScanLevelTilt,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
