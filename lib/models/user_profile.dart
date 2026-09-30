import 'nutrition_profile.dart';

/// Bumped when onboarding gains a step that existing users must answer.
///
/// Anyone whose stored [UserProfile.onboardingVersion] is below this is routed
/// back through onboarding, and only sees the steps they have no answer for.
/// This is why completion lives on the server profile and not in device
/// preferences, which were lost on reinstall and never knew about new steps.
/// Bumped to 2 when equipment preference was added to the training step, so
/// users who finished v1 are asked that question once without redoing the rest.
const int kOnboardingVersion = 2;

/// The wording of the terms and the non-medical disclaimer the user agreed to.
/// Stored with the acceptance so a later rewrite can be re-consented.
const String kTermsVersion = '2026-09-v1';

/// A value backed by a fixed string the API validates against.
mixin _Wire on Enum {
  String get wire;
}

enum PrimaryGoal with _Wire {
  loseWeight('lose_weight'),
  gainWeight('gain_weight'),
  buildMuscle('build_muscle');

  const PrimaryGoal(this.wire);
  @override
  final String wire;
}

enum DietPattern with _Wire {
  omnivore('omnivore'),
  vegetarian('vegetarian'),
  vegan('vegan'),
  pescatarian('pescatarian');

  const DietPattern(this.wire);
  @override
  final String wire;
}

/// Whether Celia plans for the user or the user plans for themselves. Used for
/// both nutrition and training, which the client specified separately.
enum PlanningMode with _Wire {
  automatic('automatic'),
  manual('manual');

  const PlanningMode(this.wire);
  @override
  final String wire;
}

enum TrainingLocation with _Wire {
  home('home'),
  gym('gym'),
  both('both');

  const TrainingLocation(this.wire);
  @override
  final String wire;
}

enum FitnessGoal with _Wire {
  loseFat('lose_fat'),
  strength('strength'),
  tone('tone'),
  health('health'),
  tactical('tactical'),
  custom('custom');

  const FitnessGoal(this.wire);
  @override
  final String wire;
}

enum TrainingIntensity with _Wire {
  easy('easy'),
  moderate('moderate'),
  intense('intense');

  const TrainingIntensity(this.wire);
  @override
  final String wire;
}

enum ExperienceLevel with _Wire {
  beginner('beginner'),
  regular('regular');

  const ExperienceLevel(this.wire);
  @override
  final String wire;
}

enum WearableProvider with _Wire {
  googleFit('google_fit'),
  healthConnect('health_connect'),
  appleHealth('apple_health'),
  fitbit('fitbit'),
  garmin('garmin');

  const WearableProvider(this.wire);
  @override
  final String wire;
}

/// The steps of the onboarding flow, in order.
///
/// [wearables] is included so the profile can record a connection, but the
/// integration itself does not exist yet: the step is informational and always
/// skippable, and it is deliberately absent from [UserProfile.missingSteps].
enum OnboardingStep {
  consent,
  physical,
  goal,
  nutrition,
  training,
  coaching,
  notifications,
  wearables,
  summary,
}

T? _enumFromWire<T extends _Wire>(List<T> values, Object? raw) {
  if (raw is! String) return null;
  for (final value in values) {
    if (value.wire == raw) return value;
  }
  return null;
}

/// The profile collected by onboarding, as stored by `/api/mobile/profile`.
///
/// Every field is nullable because the app saves after each step: a user who
/// closes the app halfway through keeps what they answered and resumes at the
/// first step that is still empty.
class UserProfile {
  const UserProfile({
    this.termsAcceptedAt,
    this.termsVersion,
    this.sex,
    this.age,
    this.weightKg,
    this.heightCm,
    this.bmrKcal,
    this.primaryGoal,
    this.dietPattern,
    this.dietaryConditions = const [],
    this.foodAllergies = const [],
    this.disorderedEatingHistory,
    this.nutritionMode,
    this.dailyWaterMl,
    this.dailyCalories,
    this.dailyProteinGrams,
    this.dailyCarbsGrams,
    this.dailyFatGrams,
    this.trainingLocation,
    this.usesEquipment,
    this.availableEquipment = const [],
    this.injuries = const [],
    this.medicalConditions = const [],
    this.fitnessGoal,
    this.desiredOutcomes = const [],
    this.trainingIntensity,
    this.experienceLevel,
    this.planningMode,
    this.minutesPerDay,
    this.preferredTrainingTime,
    this.currentMood,
    this.coachingFocus,
    this.notificationPrefs = const {},
    this.wearableProvider,
    this.onboardingVersion = 0,
    this.onboardingCompletedAt,
  });

  // Step 1 — consent.
  final DateTime? termsAcceptedAt;
  final String? termsVersion;

  // Step 2 — physical data.
  final NutritionGender? sex;
  final int? age;
  final double? weightKg;
  final double? heightCm;
  final double? bmrKcal;

  // Step 3 — overall goal.
  final PrimaryGoal? primaryGoal;

  // Step 4 — nutrition.
  final DietPattern? dietPattern;
  final List<String> dietaryConditions;
  final List<String> foodAllergies;
  final bool? disorderedEatingHistory;
  final PlanningMode? nutritionMode;
  final int? dailyWaterMl;
  final double? dailyCalories;
  final double? dailyProteinGrams;
  final double? dailyCarbsGrams;
  final double? dailyFatGrams;

  // Step 5 — training.
  final TrainingLocation? trainingLocation;

  /// Whether workouts may include equipment. Null until answered.
  final bool? usesEquipment;

  /// Kit the user owns when [usesEquipment] is true. Empty when bodyweight-only.
  final List<String> availableEquipment;

  final List<String> injuries;
  final List<String> medicalConditions;
  final FitnessGoal? fitnessGoal;
  final List<String> desiredOutcomes;
  final TrainingIntensity? trainingIntensity;
  final ExperienceLevel? experienceLevel;
  final PlanningMode? planningMode;
  final int? minutesPerDay;

  /// Local `HH:mm`, the default answer to the daily "what time are you
  /// training today?" prompt.
  final String? preferredTrainingTime;

  // Step 6 — life coaching.
  final String? currentMood;
  final String? coachingFocus;

  // Step 7 — notifications. Delivery is not built yet; this records consent
  // per notification type so nothing is ever sent the user did not ask for.
  final Map<String, bool> notificationPrefs;

  // Step 8 — wearables. Recorded only.
  final WearableProvider? wearableProvider;

  final int onboardingVersion;
  final DateTime? onboardingCompletedAt;

  bool get hasAcceptedTerms => termsAcceptedAt != null;

  bool get hasPhysicalData =>
      sex != null && (age ?? 0) > 0 && (weightKg ?? 0) > 0 && (heightCm ?? 0) > 0;

  /// Whether a step already has an answer, so returning users are only asked
  /// what is genuinely missing.
  bool isAnswered(OnboardingStep step) {
    return switch (step) {
      OnboardingStep.consent => hasAcceptedTerms,
      OnboardingStep.physical => hasPhysicalData,
      OnboardingStep.goal => primaryGoal != null,
      OnboardingStep.nutrition => dietPattern != null && nutritionMode != null,
      OnboardingStep.training =>
        trainingLocation != null &&
            usesEquipment != null &&
            (usesEquipment == false || availableEquipment.isNotEmpty) &&
            fitnessGoal != null &&
            experienceLevel != null &&
            trainingIntensity != null,
      OnboardingStep.coaching => currentMood != null,
      OnboardingStep.notifications => notificationPrefs.isNotEmpty,
      // Optional by design: connecting a wearable is not a prerequisite for
      // using the app, and no integration reads it yet.
      OnboardingStep.wearables => true,
      // Always shown at the end of a run; it collects nothing.
      OnboardingStep.summary => false,
    };
  }

  /// Steps still to ask, in order. Empty only when onboarding is finished for
  /// the current [kOnboardingVersion].
  List<OnboardingStep> get missingSteps => OnboardingStep.values
      .where((step) => step != OnboardingStep.summary && !isAnswered(step))
      .toList(growable: false);

  bool get isOnboardingComplete =>
      onboardingCompletedAt != null &&
      onboardingVersion >= kOnboardingVersion &&
      missingSteps.isEmpty;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      termsAcceptedAt: _dateTime(json['termsAcceptedAt']),
      termsVersion: json['termsVersion'] as String?,
      sex: _sexFromWire(json['sex']),
      age: _int(json['age']),
      weightKg: _double(json['weightKg']),
      heightCm: _double(json['heightCm']),
      bmrKcal: _double(json['bmrKcal']),
      primaryGoal: _enumFromWire(PrimaryGoal.values, json['primaryGoal']),
      dietPattern: _enumFromWire(DietPattern.values, json['dietPattern']),
      dietaryConditions: _stringList(json['dietaryConditions']),
      foodAllergies: _stringList(json['foodAllergies']),
      disorderedEatingHistory: json['disorderedEatingHistory'] as bool?,
      nutritionMode: _enumFromWire(PlanningMode.values, json['nutritionMode']),
      dailyWaterMl: _int(json['dailyWaterMl']),
      dailyCalories: _double(json['dailyCalories']),
      dailyProteinGrams: _double(json['dailyProteinGrams']),
      dailyCarbsGrams: _double(json['dailyCarbsGrams']),
      dailyFatGrams: _double(json['dailyFatGrams']),
      trainingLocation: _enumFromWire(
        TrainingLocation.values,
        json['trainingLocation'],
      ),
      usesEquipment: json['usesEquipment'] as bool?,
      availableEquipment: _stringList(json['availableEquipment']),
      injuries: _stringList(json['injuries']),
      medicalConditions: _stringList(json['medicalConditions']),
      fitnessGoal: _enumFromWire(FitnessGoal.values, json['fitnessGoal']),
      desiredOutcomes: _stringList(json['desiredOutcomes']),
      trainingIntensity: _enumFromWire(
        TrainingIntensity.values,
        json['trainingIntensity'],
      ),
      experienceLevel: _enumFromWire(
        ExperienceLevel.values,
        json['experienceLevel'],
      ),
      planningMode: _enumFromWire(PlanningMode.values, json['planningMode']),
      minutesPerDay: _int(json['minutesPerDay']),
      preferredTrainingTime: json['preferredTrainingTime'] as String?,
      currentMood: json['currentMood'] as String?,
      coachingFocus: json['coachingFocus'] as String?,
      notificationPrefs: _boolMap(json['notificationPrefs']),
      wearableProvider: _enumFromWire(
        WearableProvider.values,
        json['wearableProvider'],
      ),
      onboardingVersion: _int(json['onboardingVersion']) ?? 0,
      onboardingCompletedAt: _dateTime(json['onboardingCompletedAt']),
    );
  }

  /// Activity factor implied by the training answers, for the BMR scaling.
  double get activityMultiplier {
    return switch (trainingIntensity) {
      TrainingIntensity.easy => 1.375,
      TrainingIntensity.moderate => 1.55,
      TrainingIntensity.intense => 1.725,
      null => 1.55,
    };
  }

  /// Surplus or deficit implied by the overall goal, where 1.0 is maintenance.
  ///
  /// A deficit is never applied to someone who reported a history of
  /// disordered eating: for them the goal still shapes the coaching, but the
  /// calorie target stays at maintenance rather than the app pushing a
  /// restriction it is not qualified to supervise.
  double get calorieMultiplier {
    if (primaryGoal == PrimaryGoal.loseWeight &&
        disorderedEatingHistory == true) {
      return 1.0;
    }
    return switch (primaryGoal) {
      PrimaryGoal.loseWeight => 0.85,
      PrimaryGoal.gainWeight => 1.15,
      PrimaryGoal.buildMuscle => 1.10,
      null => 1.0,
    };
  }

  /// Daily calorie and macro targets for this profile, or null while the
  /// physical data step is still unanswered.
  NutritionProfile? computeTargets() {
    if (!hasPhysicalData) return null;
    return NutritionProfile.calculate(
      weightKg: weightKg!,
      heightCm: heightCm!,
      age: age!,
      gender: sex!,
      activityMultiplier: activityMultiplier,
      calorieMultiplier: calorieMultiplier,
    );
  }

  /// The payload for `PUT /api/mobile/profile`.
  ///
  /// Null fields are omitted rather than sent as null: the endpoint treats a
  /// missing key as "leave this alone", so a partially filled draft can be
  /// saved after every step without erasing earlier answers.
  Map<String, dynamic> toWireJson() {
    return {
      if (termsAcceptedAt != null)
        'termsAcceptedAt': termsAcceptedAt!.toUtc().toIso8601String(),
      if (termsVersion != null) 'termsVersion': termsVersion,
      if (sex != null) 'sex': sex!.name,
      if (age != null) 'age': age,
      if (weightKg != null) 'weightKg': weightKg,
      if (heightCm != null) 'heightCm': heightCm,
      if (bmrKcal != null) 'bmrKcal': bmrKcal,
      if (primaryGoal != null) 'primaryGoal': primaryGoal!.wire,
      if (dietPattern != null) 'dietPattern': dietPattern!.wire,
      'dietaryConditions': dietaryConditions,
      'foodAllergies': foodAllergies,
      if (disorderedEatingHistory != null)
        'disorderedEatingHistory': disorderedEatingHistory,
      if (nutritionMode != null) 'nutritionMode': nutritionMode!.wire,
      if (dailyWaterMl != null) 'dailyWaterMl': dailyWaterMl,
      if (dailyCalories != null) 'dailyCalories': dailyCalories,
      if (dailyProteinGrams != null) 'dailyProteinGrams': dailyProteinGrams,
      if (dailyCarbsGrams != null) 'dailyCarbsGrams': dailyCarbsGrams,
      if (dailyFatGrams != null) 'dailyFatGrams': dailyFatGrams,
      if (trainingLocation != null) 'trainingLocation': trainingLocation!.wire,
      if (usesEquipment != null) 'usesEquipment': usesEquipment,
      'availableEquipment': availableEquipment,
      'injuries': injuries,
      'medicalConditions': medicalConditions,
      if (fitnessGoal != null) 'fitnessGoal': fitnessGoal!.wire,
      'desiredOutcomes': desiredOutcomes,
      if (trainingIntensity != null)
        'trainingIntensity': trainingIntensity!.wire,
      if (experienceLevel != null) 'experienceLevel': experienceLevel!.wire,
      if (planningMode != null) 'planningMode': planningMode!.wire,
      if (minutesPerDay != null) 'minutesPerDay': minutesPerDay,
      if (preferredTrainingTime != null)
        'preferredTrainingTime': preferredTrainingTime,
      if (currentMood != null) 'currentMood': currentMood,
      if (coachingFocus != null) 'coachingFocus': coachingFocus,
      if (notificationPrefs.isNotEmpty) 'notificationPrefs': notificationPrefs,
      if (wearableProvider != null)
        'wearableProvider': wearableProvider!.wire,
      'onboardingVersion': onboardingVersion,
      if (onboardingCompletedAt != null)
        'onboardingCompletedAt': onboardingCompletedAt!.toUtc().toIso8601String(),
    };
  }

  UserProfile copyWith({
    DateTime? termsAcceptedAt,
    String? termsVersion,
    NutritionGender? sex,
    int? age,
    double? weightKg,
    double? heightCm,
    double? bmrKcal,
    PrimaryGoal? primaryGoal,
    DietPattern? dietPattern,
    List<String>? dietaryConditions,
    List<String>? foodAllergies,
    bool? disorderedEatingHistory,
    PlanningMode? nutritionMode,
    int? dailyWaterMl,
    double? dailyCalories,
    double? dailyProteinGrams,
    double? dailyCarbsGrams,
    double? dailyFatGrams,
    TrainingLocation? trainingLocation,
    bool? usesEquipment,
    List<String>? availableEquipment,
    List<String>? injuries,
    List<String>? medicalConditions,
    FitnessGoal? fitnessGoal,
    List<String>? desiredOutcomes,
    TrainingIntensity? trainingIntensity,
    ExperienceLevel? experienceLevel,
    PlanningMode? planningMode,
    int? minutesPerDay,
    String? preferredTrainingTime,
    String? currentMood,
    String? coachingFocus,
    Map<String, bool>? notificationPrefs,
    WearableProvider? wearableProvider,
    int? onboardingVersion,
    DateTime? onboardingCompletedAt,
    // copyWith treats null as "unchanged", but "Not now" on the wearable step
    // has to be able to take a previous answer back out.
    bool clearWearableProvider = false,
  }) {
    return UserProfile(
      termsAcceptedAt: termsAcceptedAt ?? this.termsAcceptedAt,
      termsVersion: termsVersion ?? this.termsVersion,
      sex: sex ?? this.sex,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      bmrKcal: bmrKcal ?? this.bmrKcal,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      dietPattern: dietPattern ?? this.dietPattern,
      dietaryConditions: dietaryConditions ?? this.dietaryConditions,
      foodAllergies: foodAllergies ?? this.foodAllergies,
      disorderedEatingHistory:
          disorderedEatingHistory ?? this.disorderedEatingHistory,
      nutritionMode: nutritionMode ?? this.nutritionMode,
      dailyWaterMl: dailyWaterMl ?? this.dailyWaterMl,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      dailyProteinGrams: dailyProteinGrams ?? this.dailyProteinGrams,
      dailyCarbsGrams: dailyCarbsGrams ?? this.dailyCarbsGrams,
      dailyFatGrams: dailyFatGrams ?? this.dailyFatGrams,
      trainingLocation: trainingLocation ?? this.trainingLocation,
      usesEquipment: usesEquipment ?? this.usesEquipment,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      injuries: injuries ?? this.injuries,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      desiredOutcomes: desiredOutcomes ?? this.desiredOutcomes,
      trainingIntensity: trainingIntensity ?? this.trainingIntensity,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      planningMode: planningMode ?? this.planningMode,
      minutesPerDay: minutesPerDay ?? this.minutesPerDay,
      preferredTrainingTime:
          preferredTrainingTime ?? this.preferredTrainingTime,
      currentMood: currentMood ?? this.currentMood,
      coachingFocus: coachingFocus ?? this.coachingFocus,
      notificationPrefs: notificationPrefs ?? this.notificationPrefs,
      wearableProvider: clearWearableProvider
          ? null
          : wearableProvider ?? this.wearableProvider,
      onboardingVersion: onboardingVersion ?? this.onboardingVersion,
      onboardingCompletedAt:
          onboardingCompletedAt ?? this.onboardingCompletedAt,
    );
  }

  static NutritionGender? _sexFromWire(Object? raw) {
    return switch (raw) {
      'male' => NutritionGender.male,
      'female' => NutritionGender.female,
      'other' => NutritionGender.other,
      _ => null,
    };
  }

  static DateTime? _dateTime(Object? raw) {
    if (raw is! String) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  static int? _int(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '');
  }

  static double? _double(Object? raw) {
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw?.toString() ?? '');
  }

  static List<String> _stringList(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .map((entry) => entry?.toString().trim() ?? '')
        .where((entry) => entry.isNotEmpty)
        .toList(growable: false);
  }

  static Map<String, bool> _boolMap(Object? raw) {
    if (raw is! Map) return const {};
    final map = <String, bool>{};
    raw.forEach((key, value) {
      if (value is bool) map[key.toString()] = value;
    });
    return map;
  }
}
