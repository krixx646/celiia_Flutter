import 'dart:convert';

import 'package:celia_flutter/models/nutrition_profile.dart';
import 'package:celia_flutter/models/user_profile.dart';
import 'package:celia_flutter/services/user_profile_service.dart';
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
    UserProfileService.backendBaseUrl = () => 'https://example.test';
  });

  UserProfileService serviceReturning(
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
    return UserProfileService(firebaseAuth: auth, httpClient: client);
  }

  test('a user who has never onboarded reads as no profile', () async {
    final service = serviceReturning({'profile': null});

    expect(await service.fetch(), isNull);
  });

  test('fetch parses the profile the backend stored', () async {
    final service = serviceReturning({
      'profile': {
        'primaryGoal': 'build_muscle',
        'trainingLocation': 'gym',
        'onboardingVersion': kOnboardingVersion,
      },
    });

    final profile = await service.fetch();

    expect(profile!.primaryGoal, PrimaryGoal.buildMuscle);
    expect(profile.trainingLocation, TrainingLocation.gym);
  });

  test('a save carries the bearer token and the answered fields', () async {
    Map<String, dynamic>? sent;
    String? authorization;

    final service = serviceReturning(
      {'profile': {'primaryGoal': 'lose_weight'}},
      onRequest: (request) {
        authorization = request.headers['Authorization'];
        sent = jsonDecode(request.body) as Map<String, dynamic>;
      },
    );

    await service.save(
      const UserProfile(
        primaryGoal: PrimaryGoal.loseWeight,
        sex: NutritionGender.male,
      ),
    );

    expect(authorization, 'Bearer token');
    expect(sent!['primaryGoal'], 'lose_weight');
    expect(sent!['sex'], 'male');
    // Nothing the user has not answered is sent, so a partial save cannot
    // blank out a field filled in on another device.
    expect(sent!.containsKey('currentMood'), isFalse);
  });

  test('an expired session surfaces as not signed in', () async {
    final service = serviceReturning({'error': 'Unauthorized'}, status: 401);

    expect(
      () => service.fetch(),
      throwsA(
        isA<UserProfileException>().having(
          (e) => e.message,
          'message',
          contains('Not signed in'),
        ),
      ),
    );
  });

  test('a signed-out caller never reaches the network', () async {
    when(() => auth.currentUser).thenReturn(null);
    final service = serviceReturning({'profile': null});

    expect(() => service.fetch(), throwsA(isA<UserProfileException>()));
  });

  test('a missing backend url is reported rather than guessed', () async {
    UserProfileService.backendBaseUrl = () => '';
    final service = serviceReturning({'profile': null});

    expect(() => service.fetch(), throwsA(isA<UserProfileException>()));
  });
}
