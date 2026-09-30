import 'package:celia_flutter/models/nutrition_profile.dart';
import 'package:celia_flutter/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

/// A profile with every required step answered.
UserProfile completeDraft() => UserProfile(
  termsAcceptedAt: DateTime(2026, 9, 14),
  termsVersion: kTermsVersion,
  sex: NutritionGender.female,
  age: 34,
  weightKg: 68,
  heightCm: 170,
  primaryGoal: PrimaryGoal.loseWeight,
  dietPattern: DietPattern.omnivore,
  nutritionMode: PlanningMode.automatic,
  disorderedEatingHistory: false,
  trainingLocation: TrainingLocation.home,
  usesEquipment: false,
  availableEquipment: const [],
  fitnessGoal: FitnessGoal.loseFat,
  experienceLevel: ExperienceLevel.beginner,
  trainingIntensity: TrainingIntensity.moderate,
  currentMood: 'okay',
  notificationPrefs: const {'meals': true},
);

void main() {
  group('missing steps', () {
    test('a brand new profile has to answer every collecting step', () {
      const profile = UserProfile();

      expect(
        profile.missingSteps,
        containsAll([
          OnboardingStep.consent,
          OnboardingStep.physical,
          OnboardingStep.goal,
          OnboardingStep.nutrition,
          OnboardingStep.training,
          OnboardingStep.coaching,
          OnboardingStep.notifications,
        ]),
      );
    });

    test('the wearable step is never required', () {
      expect(const UserProfile().missingSteps, isNot(contains(OnboardingStep.wearables)));
    });

    test('a finished profile has nothing left to ask', () {
      expect(completeDraft().missingSteps, isEmpty);
    });

    test('a user who predates a step is only asked that step', () {
      // What an existing account looks like after the coaching step is added:
      // everything else already answered, so the flow is one question long.
      final json = completeDraft().toWireJson()..remove('currentMood');
      final profile = UserProfile.fromJson(json);

      expect(profile.missingSteps, [OnboardingStep.coaching]);
    });
  });

  group('completion', () {
    test('answering every step is not the same as having finished', () {
      // The version and the completion stamp are written together when the
      // user reaches the end, so a draft is not complete just because it is
      // full.
      expect(completeDraft().isOnboardingComplete, isFalse);
    });

    test('a profile from an older flow is sent back for the new steps', () {
      final stale = completeDraft().copyWith(
        onboardingVersion: kOnboardingVersion - 1,
        onboardingCompletedAt: DateTime(2026, 1, 1),
      );

      expect(stale.isOnboardingComplete, isFalse);
    });

    test('a profile at the current version is left alone', () {
      final current = completeDraft().copyWith(
        onboardingVersion: kOnboardingVersion,
        onboardingCompletedAt: DateTime(2026, 9, 14),
      );

      expect(current.isOnboardingComplete, isTrue);
    });
  });

  group('personalisation', () {
    test('losing weight runs a deficit and gaining runs a surplus', () {
      final lose = completeDraft().copyWith(primaryGoal: PrimaryGoal.loseWeight);
      final gain = completeDraft().copyWith(primaryGoal: PrimaryGoal.gainWeight);

      expect(lose.calorieMultiplier, lessThan(1));
      expect(gain.calorieMultiplier, greaterThan(1));
      expect(
        lose.computeTargets()!.dailyCalories,
        lessThan(gain.computeTargets()!.dailyCalories),
      );
    });

    test('a history of disordered eating never gets a deficit', () {
      final profile = completeDraft().copyWith(
        primaryGoal: PrimaryGoal.loseWeight,
        disorderedEatingHistory: true,
      );

      expect(profile.calorieMultiplier, 1.0);
    });

    test('training harder raises the calorie target', () {
      final easy = completeDraft().copyWith(
        trainingIntensity: TrainingIntensity.easy,
      );
      final intense = completeDraft().copyWith(
        trainingIntensity: TrainingIntensity.intense,
      );

      expect(
        easy.computeTargets()!.dailyCalories,
        lessThan(intense.computeTargets()!.dailyCalories),
      );
    });

    test('targets are unavailable until the physical step is answered', () {
      expect(const UserProfile().computeTargets(), isNull);
    });
  });

  group('wire format', () {
    test('unanswered fields are omitted so a save cannot erase an answer', () {
      final json = const UserProfile().toWireJson();

      expect(json.containsKey('sex'), isFalse);
      expect(json.containsKey('primaryGoal'), isFalse);
      expect(json['onboardingVersion'], 0);
    });

    test('enums travel as the slugs the backend validates', () {
      final json = completeDraft().toWireJson();

      expect(json['primaryGoal'], 'lose_weight');
      expect(json['trainingLocation'], 'home');
      expect(json['nutritionMode'], 'automatic');
      expect(json['sex'], 'female');
    });

    test('a round trip through the API shape keeps the answers', () {
      final original = completeDraft().copyWith(
        injuries: const ['knee'],
        foodAllergies: const ['peanuts'],
        preferredTrainingTime: '07:30',
        minutesPerDay: 30,
      );

      final restored = UserProfile.fromJson(original.toWireJson());

      expect(restored.primaryGoal, original.primaryGoal);
      expect(restored.injuries, ['knee']);
      expect(restored.foodAllergies, ['peanuts']);
      expect(restored.preferredTrainingTime, '07:30');
      expect(restored.minutesPerDay, 30);
      expect(restored.missingSteps, isEmpty);
    });

    test('unknown values from the server are ignored, not guessed at', () {
      final profile = UserProfile.fromJson({
        'primaryGoal': 'become_a_bird',
        'sex': 'unspecified',
      });

      expect(profile.primaryGoal, isNull);
      expect(profile.sex, isNull);
    });
  });
}
