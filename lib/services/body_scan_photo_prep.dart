import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute, debugPrint;
import 'package:image/image.dart' as img;

/// Bodygram accepts JPEGs of exactly 1080x1920 or 720x1280 (portrait), up to
/// 3 MB. Our backend also caps each photo at roughly 1.3 MB of JPEG.
const int bodyScanHdWidth = 1080;
const int bodyScanHdHeight = 1920;
const int bodyScanSdWidth = 720;
const int bodyScanSdHeight = 1280;
const int bodyScanPhotoMaxBytes = 1300000;

/// Kept for callers and tests that only need the larger accepted size.
const int bodyScanPhotoWidth = bodyScanHdWidth;
const int bodyScanPhotoHeight = bodyScanHdHeight;

/// Anything larger than this is shrunk before the cover-crop. It is a safety
/// net only: the camera is opened at 720p, so normal captures skip it.
const int _maxWorkingEdge = 2560;

/// Sizes the vendor accepts, in either orientation. A camera that saves a
/// landscape frame with an EXIF rotation flag was accepted when the back
/// camera was used, so we keep accepting that exact shape.
bool isBodygramLegalSize(int width, int height) {
  return (width == 1080 && height == 1920) ||
      (width == 1920 && height == 1080) ||
      (width == 720 && height == 1280) ||
      (width == 1280 && height == 720);
}

/// Reads the pixel size from a JPEG header without decoding the picture, so
/// the check costs microseconds even in a debug build.
({int width, int height})? readJpegSize(Uint8List bytes) {
  if (bytes.length < 4 || bytes[0] != 0xFF || bytes[1] != 0xD8) return null;
  var i = 2;
  while (i + 9 < bytes.length) {
    if (bytes[i] != 0xFF) {
      i++;
      continue;
    }
    final marker = bytes[i + 1];
    if (marker == 0xFF) {
      i++;
      continue;
    }
    final isFrameHeader = marker >= 0xC0 &&
        marker <= 0xCF &&
        marker != 0xC4 &&
        marker != 0xC8 &&
        marker != 0xCC;
    if (isFrameHeader) {
      final height = (bytes[i + 5] << 8) | bytes[i + 6];
      final width = (bytes[i + 7] << 8) | bytes[i + 8];
      return (width: width, height: height);
    }
    if (marker == 0x01 || (marker >= 0xD0 && marker <= 0xD8)) {
      i += 2;
      continue;
    }
    final length = (bytes[i + 2] << 8) | bytes[i + 3];
    i += 2 + length;
  }
  return null;
}

/// What the capture screen calls. The camera's own file goes straight through
/// when it is already a size Bodygram accepts and small enough to upload (the
/// path that worked with the back camera). Only odd sizes are re-encoded, and
/// if that is slow or fails the original is sent rather than losing the photo;
/// the server then reports a retake if the vendor refuses it.
Future<Uint8List> preparePhotoForUpload(Uint8List raw) async {
  final size = readJpegSize(raw);
  if (size != null &&
      isBodygramLegalSize(size.width, size.height) &&
      raw.lengthInBytes <= bodyScanPhotoMaxBytes) {
    return raw;
  }

  try {
    return await compute(prepareBodyScanPhoto, raw)
        .timeout(const Duration(seconds: 25));
  } catch (e) {
    debugPrint('Body scan photo prep fell back to the original file: $e');
    return raw;
  }
}

/// Turns whatever the camera saved into a photo the vendor will accept.
///
/// The capture UI previews with `BoxFit.cover`. We export the same way: scale
/// to fill the target and center-crop, never letterbox. The target is
/// 1080x1920 when the source is large enough, otherwise 720x1280 (no pointless
/// upscaling).
///
/// Runs on a background isolate via `compute`, so it must stay a top-level
/// function taking and returning plain data.
Uint8List prepareBodyScanPhoto(Uint8List original) {
  img.Image? decoded;
  try {
    decoded = img.decodeJpg(original);
  } catch (_) {
    decoded = null;
  }
  if (decoded == null) {
    throw StateError('Could not decode body-scan JPEG');
  }

  var working = img.bakeOrientation(decoded);

  final longest =
      working.width > working.height ? working.width : working.height;
  if (longest > _maxWorkingEdge) {
    final scale = _maxWorkingEdge / longest;
    working = img.copyResize(
      working,
      width: (working.width * scale).round().clamp(1, _maxWorkingEdge),
      height: (working.height * scale).round().clamp(1, _maxWorkingEdge),
      interpolation: img.Interpolation.linear,
    );
  }

  final shortEdge =
      working.width < working.height ? working.width : working.height;
  final useHd = shortEdge >= bodyScanHdWidth;
  final targetW = useHd ? bodyScanHdWidth : bodyScanSdWidth;
  final targetH = useHd ? bodyScanHdHeight : bodyScanSdHeight;

  // Cover: scale so the image fills the target, then crop the overflow.
  final widthScale = targetW / working.width;
  final heightScale = targetH / working.height;
  final cover = widthScale > heightScale ? widthScale : heightScale;
  final scaledW = (working.width * cover).round().clamp(targetW, 100000);
  final scaledH = (working.height * cover).round().clamp(targetH, 100000);
  final scaled = (scaledW == working.width && scaledH == working.height)
      ? working
      : img.copyResize(
          working,
          width: scaledW,
          height: scaledH,
          interpolation: img.Interpolation.linear,
        );

  final cropX = ((scaledW - targetW) / 2).round().clamp(0, scaledW);
  final cropY = ((scaledH - targetH) / 2).round().clamp(0, scaledH);
  final cropped = (cropX == 0 &&
          cropY == 0 &&
          scaled.width == targetW &&
          scaled.height == targetH)
      ? scaled
      : img.copyCrop(
          scaled,
          x: cropX,
          y: cropY,
          width: targetW,
          height: targetH,
        );

  Uint8List encoded = Uint8List.fromList(img.encodeJpg(cropped, quality: 88));
  for (final quality in const [78, 68, 58]) {
    if (encoded.lengthInBytes <= bodyScanPhotoMaxBytes) break;
    encoded = Uint8List.fromList(img.encodeJpg(cropped, quality: quality));
  }
  return encoded;
}
