import 'dart:typed_data';

import 'package:celia_flutter/services/meal_scan_photo_prep.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

Uint8List _jpeg(int width, int height) {
  final image = img.Image(width: width, height: height, numChannels: 3);
  img.fill(image, color: img.ColorRgb8(90, 140, 70));
  return Uint8List.fromList(img.encodeJpg(image, quality: 92));
}

void main() {
  test('large camera frame is resized to max edge 1280', () {
    final prepared = prepareMealScanPhoto(_jpeg(4032, 3024));
    final out = img.decodeJpg(prepared)!;
    final longest = out.width > out.height ? out.width : out.height;
    expect(longest, lessThanOrEqualTo(mealScanMaxEdge));
  });

  test('prepared payload is smaller than a typical high-res capture', () {
    final input = _jpeg(4032, 3024);
    final prepared = prepareMealScanPhoto(input);
    expect(prepared.lengthInBytes, lessThan(input.lengthInBytes));
    expect(prepared.lengthInBytes, lessThanOrEqualTo(mealScanTargetMaxBytes));
  });

  test('already-small image stays valid JPEG', () {
    final prepared = prepareMealScanPhoto(_jpeg(800, 600));
    expect(img.decodeJpg(prepared), isNotNull);
  });
}
