import 'dart:convert';

import 'package:celia_flutter/models/body_scan.dart';
import 'package:celia_flutter/models/nutrition_profile.dart';
import 'package:celia_flutter/services/body_scan_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth auth;

  setUp(() {
    auth = MockFirebaseAuth();
    final user = MockUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => user.getIdToken()).thenAnswer((_) async => 'token');
    BodyScanService.backendBaseUrl = () => 'https://example.test';
  });

  BodyScanService serviceReturning(
    Object body, {
    int status = 200,
    void Function(http.Request request)? onRequest,
  }) {
    final client = MockClient((request) async {
      onRequest?.call(request);
      return http.Response(
        body is String ? body : jsonEncode(body),
        status,
        headers: {'content-type': 'application/json'},
      );
    });
    return BodyScanService(firebaseAuth: auth, httpClient: client);
  }

  Future<BodyScanResult> submit(BodyScanService service) {
    return service.submitScan(
      frontJpegBytes: const [1, 2, 3],
      rightJpegBytes: const [4, 5, 6],
      age: 30,
      gender: NutritionGender.female,
      heightCm: 170,
      weightKg: 65,
    );
  }

  group('submitScan', () {
    test('parses composition, measurements and quota', () async {
      final service = serviceReturning({
        'scan': {
          'id': 'scan-1',
          'scannedAt': '2026-09-03T10:00:00.000Z',
          'bodyFatPercentage': 24.5,
          'leanMassG': 49000,
          'bodyFatMassG': 16000,
          'waistGirthMm': 780,
          'hipGirthMm': 960,
          'measurements': [
            {'name': 'waistGirth', 'unit': 'mm', 'value': 780},
          ],
          'meshUrl': 'https://signed.example/mesh.glb',
        },
        'quota': {'remaining': 0, 'resetsAt': '2026-10-03T10:00:00.000Z'},
      });

      final result = await submit(service);

      expect(result.scan.id, 'scan-1');
      expect(result.scan.bodyFatPercentage, 24.5);
      expect(result.scan.leanMassKg, 49);
      expect(result.scan.waistCm, 78);
      expect(result.scan.waistToHipRatio, closeTo(0.8125, 0.0001));
      expect(result.scan.measurements.single.centimetres, 78);
      expect(result.quota!.remaining, 0);
    });

    test('sends the photos base64 encoded with the vendor gender', () async {
      late Map<String, dynamic> sent;
      final service = serviceReturning(
        {
          'scan': {'id': 'x', 'scannedAt': '2026-09-03T10:00:00.000Z'},
        },
        onRequest: (request) =>
            sent = jsonDecode(request.body) as Map<String, dynamic>,
      );

      await submit(service);

      expect(sent['frontPhotoBase64'], base64Encode(const [1, 2, 3]));
      expect(sent['rightPhotoBase64'], base64Encode(const [4, 5, 6]));
      expect(sent['gender'], 'female');
      expect(sent['heightCm'], 170);
    });

    test('maps a vendor photo rejection to a retakeable error', () async {
      final service = serviceReturning(
        {'error': 'bad photos', 'code': 'body_not_in_frame', 'category': 'framing'},
        status: 422,
      );

      final error = await submit(service).then<Object?>((_) => null, onError: (e) => e);

      expect(error, isA<BodyScanException>());
      expect((error as BodyScanException).error, BodyScanError.photoFraming);
      expect(error.isRetakeable, isTrue);
    });

    test('surfaces quota exhaustion with its reset date', () async {
      final service = serviceReturning(
        {
          'error': 'Scan allowance used',
          'code': 'quotaExhausted',
          'resetsAt': '2026-10-03T10:00:00.000Z',
        },
        status: 402,
      );

      final error = await submit(service).then<Object?>((_) => null, onError: (e) => e);

      expect((error as BodyScanException).error, BodyScanError.quotaExhausted);
      expect(error.isRetakeable, isFalse);
      expect(error.resetsAt, isNotNull);
    });

    test('refuses under-18s before spending a request', () async {
      var called = false;
      final service = serviceReturning(
        {'scan': {}},
        onRequest: (_) => called = true,
      );

      final error = await service
          .submitScan(
            frontJpegBytes: const [1],
            rightJpegBytes: const [2],
            age: 16,
            gender: NutritionGender.female,
            heightCm: 170,
            weightKg: 65,
          )
          .then<Object?>((_) => null, onError: (e) => e);

      expect((error as BodyScanException).error, BodyScanError.notEligibleAge);
      expect(called, isFalse);
    });

    test('refuses a gender the vendor model cannot accept', () async {
      final service = serviceReturning({'scan': {}});

      final error = await service
          .submitScan(
            frontJpegBytes: const [1],
            rightJpegBytes: const [2],
            age: 30,
            gender: NutritionGender.other,
            heightCm: 170,
            weightKg: 65,
          )
          .then<Object?>((_) => null, onError: (e) => e);

      expect((error as BodyScanException).error, BodyScanError.invalidStats);
    });

    test('reports a signed-out user without calling the backend', () async {
      when(() => auth.currentUser).thenReturn(null);
      var called = false;
      final service = serviceReturning(
        {'scan': {}},
        onRequest: (_) => called = true,
      );

      final error = await submit(service).then<Object?>((_) => null, onError: (e) => e);

      expect((error as BodyScanException).error, BodyScanError.notSignedIn);
      expect(called, isFalse);
    });
  });

  group('fetchHistory', () {
    test('returns scans newest first as sent', () async {
      final service = serviceReturning({
        'scans': [
          {'id': 'b', 'scannedAt': '2026-09-01T10:00:00.000Z', 'bodyFatPercentage': 23},
          {'id': 'a', 'scannedAt': '2026-08-01T10:00:00.000Z', 'bodyFatPercentage': 25},
        ],
      });

      final scans = await service.fetchHistory();

      expect(scans.map((s) => s.id), ['b', 'a']);
      expect(scans.first.hasComposition, isTrue);
    });

    test('tolerates an empty history', () async {
      final service = serviceReturning({'scans': []});
      expect(await service.fetchHistory(), isEmpty);
    });
  });
}
