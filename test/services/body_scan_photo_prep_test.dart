import 'dart:typed_data';

import 'package:celia_flutter/services/body_scan_photo_prep.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

Uint8List _jpeg(int width, int height, {int? exifOrientation}) {
  final image = img.Image(width: width, height: height, numChannels: 3);
  img.fill(image, color: img.ColorRgb8(120, 90, 60));
  img.fillRect(
    image,
    x1: width ~/ 3,
    y1: height ~/ 8,
    x2: (width * 2) ~/ 3,
    y2: (height * 7) ~/ 8,
    color: img.ColorRgb8(200, 160, 140),
  );
  if (exifOrientation != null) {
    image.exif.imageIfd.orientation = exifOrientation;
  }
  return Uint8List.fromList(img.encodeJpg(image, quality: 90));
}

/// The only two sizes Bodygram accepts for a photo scan.
void _expectBodygramLegal(img.Image out) {
  final legal = (out.width == 1080 && out.height == 1920) ||
      (out.width == 720 && out.height == 1280);
  expect(legal, isTrue, reason: 'got ${out.width}x${out.height}');
}

void main() {
  test('720p selfie frame (1280x720 + EXIF rotate) becomes 720x1280', () {
    final out = img.decodeJpg(
      prepareBodyScanPhoto(_jpeg(1280, 720, exifOrientation: 6)),
    )!;
    expect(out.width, 720);
    expect(out.height, 1280);
  });

  test('720p frame is processed quickly (no freeze after the timer)', () {
    final input = _jpeg(1280, 720, exifOrientation: 6);
    final watch = Stopwatch()..start();
    prepareBodyScanPhoto(input);
    expect(watch.elapsedMilliseconds, lessThan(3000));
  });

  test('1080p selfie frame becomes 1080x1920', () {
    final out = img.decodeJpg(
      prepareBodyScanPhoto(_jpeg(1920, 1080, exifOrientation: 6)),
    )!;
    expect(out.width, 1080);
    expect(out.height, 1920);
  });

  test('4:3 portrait is cover-cropped with no black letterbox bars', () {
    final source = img.Image(width: 960, height: 1280, numChannels: 3);
    img.fill(source, color: img.ColorRgb8(255, 0, 0));
    final bytes = Uint8List.fromList(img.encodeJpg(source, quality: 90));
    final out = img.decodeJpg(prepareBodyScanPhoto(bytes))!;
    _expectBodygramLegal(out);

    final corner = out.getPixel(0, 0);
    expect(corner.r + corner.g + corner.b, greaterThan(0));
  });

  test('large 12 MP frame becomes a legal size under the upload cap', () {
    final prepared = prepareBodyScanPhoto(_jpeg(4032, 3024));
    _expectBodygramLegal(img.decodeJpg(prepared)!);
    expect(prepared.lengthInBytes, lessThanOrEqualTo(bodyScanPhotoMaxBytes));
  });

  test('already-correct sizes stay legal', () {
    _expectBodygramLegal(img.decodeJpg(prepareBodyScanPhoto(_jpeg(1080, 1920)))!);
    _expectBodygramLegal(img.decodeJpg(prepareBodyScanPhoto(_jpeg(720, 1280)))!);
  });

  test('readJpegSize reads dimensions without decoding', () {
    final size = readJpegSize(_jpeg(1280, 720))!;
    expect(size.width, 1280);
    expect(size.height, 720);
    expect(readJpegSize(Uint8List.fromList([1, 2, 3])), isNull);
  });

  test('legal-sized camera file is uploaded untouched and instantly', () async {
    final raw = _jpeg(1280, 720, exifOrientation: 6);
    final watch = Stopwatch()..start();
    final out = await preparePhotoForUpload(raw);
    expect(identical(out, raw), isTrue);
    expect(watch.elapsedMilliseconds, lessThan(200));
  });

  test('odd-sized camera file is re-encoded to a legal size', () async {
    final out = await preparePhotoForUpload(_jpeg(1600, 1200));
    _expectBodygramLegal(img.decodeJpg(out)!);
  });

  test('undecodable input throws instead of returning junk', () {
    final junk = Uint8List.fromList([1, 2, 3, 4]);
    expect(() => prepareBodyScanPhoto(junk), throwsA(isA<StateError>()));
  });
}
