import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute, debugPrint;
import 'package:image/image.dart' as img;

/// Max longest edge for calorie-scanner uploads. Keeps vision usable while
/// cutting upload size and OpenAI vision latency vs full camera JPEGs.
const int mealScanMaxEdge = 1280;

/// Soft target for the encoded JPEG payload before base64 (~+33%).
const int mealScanTargetMaxBytes = 450000;

/// Prepares a camera JPEG for meal analysis upload.
///
/// Falls back to the original bytes if resize fails, so scanning never dies
/// solely because compression failed.
Future<Uint8List> prepareMealScanPhotoForUpload(Uint8List raw) async {
  if (raw.isEmpty) return raw;

  try {
    final prepared = await compute(prepareMealScanPhoto, raw)
        .timeout(const Duration(seconds: 8));
    if (prepared.isEmpty) return raw;
    return prepared;
  } catch (e) {
    debugPrint('Meal scan photo prep fell back to original: $e');
    return raw;
  }
}

/// Top-level isolate entry: resize longest edge and re-encode as JPEG.
Uint8List prepareMealScanPhoto(Uint8List original) {
  img.Image? decoded;
  try {
    decoded = img.decodeJpg(original);
  } catch (_) {
    decoded = null;
  }
  if (decoded == null) {
    throw StateError('Could not decode meal-scan JPEG');
  }

  var working = img.bakeOrientation(decoded);
  final longest =
      working.width > working.height ? working.width : working.height;

  if (longest > mealScanMaxEdge) {
    final scale = mealScanMaxEdge / longest;
    working = img.copyResize(
      working,
      width: (working.width * scale).round().clamp(1, mealScanMaxEdge),
      height: (working.height * scale).round().clamp(1, mealScanMaxEdge),
      interpolation: img.Interpolation.linear,
    );
  }

  // Already small enough and within edge limit — keep original encoding when
  // possible to avoid an unnecessary quality hit.
  if (longest <= mealScanMaxEdge &&
      original.lengthInBytes <= mealScanTargetMaxBytes) {
    return original;
  }

  Uint8List encoded = Uint8List.fromList(img.encodeJpg(working, quality: 78));
  for (final quality in const [70, 62, 55]) {
    if (encoded.lengthInBytes <= mealScanTargetMaxBytes) break;
    encoded = Uint8List.fromList(img.encodeJpg(working, quality: quality));
  }
  return encoded;
}
