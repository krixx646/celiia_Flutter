enum NutritionGender { male, female, other }

class NutritionTargets {
  const NutritionTargets({
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });

  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
}

class NutritionProfile {
  const NutritionProfile({
    required this.weightKg,
    required this.heightCm,
    required this.age,
    required this.gender,
    required this.dailyCalories,
    required this.dailyProteinGrams,
    required this.dailyCarbsGrams,
    required this.dailyFatGrams,
    this.updatedAt,
  });

  final double weightKg;
  final double heightCm;
  final int age;
  final NutritionGender gender;
  final double dailyCalories;
  final double dailyProteinGrams;
  final double dailyCarbsGrams;
  final double dailyFatGrams;
  final DateTime? updatedAt;

  bool get isComplete =>
      weightKg > 0 && heightCm > 0 && age > 0 && dailyCalories > 0;

  NutritionTargets get targets => NutritionTargets(
    calories: dailyCalories,
    proteinGrams: dailyProteinGrams,
    carbsGrams: dailyCarbsGrams,
    fatGrams: dailyFatGrams,
  );

  factory NutritionProfile.fromJson(Map<String, dynamic> json) {
    return NutritionProfile(
      weightKg: _double(json['weightKg']),
      heightCm: _double(json['heightCm']),
      age: _int(json['age']),
      gender: _genderFromString(json['gender']?.toString()),
      dailyCalories: _double(json['dailyCalories']),
      dailyProteinGrams: _double(json['dailyProteinGrams']),
      dailyCarbsGrams: _double(json['dailyCarbsGrams']),
      dailyFatGrams: _double(json['dailyFatGrams']),
      updatedAt: json['updatedAt'] is DateTime
          ? json['updatedAt'] as DateTime
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weightKg': weightKg,
      'heightCm': heightCm,
      'age': age,
      'gender': gender.name,
      'dailyCalories': dailyCalories,
      'dailyProteinGrams': dailyProteinGrams,
      'dailyCarbsGrams': dailyCarbsGrams,
      'dailyFatGrams': dailyFatGrams,
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  static NutritionProfile calculate({
    required double weightKg,
    required double heightCm,
    required int age,
    required NutritionGender gender,
  }) {
    final bmr = _basalMetabolicRate(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
    );
    const activityMultiplier = 1.55;
    final calories = (bmr * activityMultiplier).roundToDouble();

    final proteinGrams = (weightKg * 1.8).roundToDouble();
    final fatGrams = ((calories * 0.25) / 9).roundToDouble();
    final carbCalories = calories - (proteinGrams * 4) - (fatGrams * 9);
    final carbsGrams = (carbCalories / 4)
        .clamp(0, double.infinity)
        .roundToDouble();

    return NutritionProfile(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
      dailyCalories: calories,
      dailyProteinGrams: proteinGrams,
      dailyCarbsGrams: carbsGrams,
      dailyFatGrams: fatGrams,
      updatedAt: DateTime.now(),
    );
  }

  static double _basalMetabolicRate({
    required double weightKg,
    required double heightCm,
    required int age,
    required NutritionGender gender,
  }) {
    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    return switch (gender) {
      NutritionGender.male => base + 5,
      NutritionGender.female => base - 161,
      NutritionGender.other => base - 78,
    };
  }

  static double _double(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static NutritionGender _genderFromString(String? value) {
    return switch (value) {
      'male' => NutritionGender.male,
      'female' => NutritionGender.female,
      _ => NutritionGender.other,
    };
  }
}
