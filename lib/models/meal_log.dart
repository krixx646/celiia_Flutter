import 'meal_analysis.dart';

class MealLog {
  final String id;
  final String userId;
  final String title;
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double confidence;
  final String provider;
  final List<MealFoodItem> items;
  final List<String> warnings;
  final DateTime loggedAt;

  const MealLog({
    required this.id,
    required this.userId,
    required this.title,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.confidence,
    required this.provider,
    required this.items,
    required this.warnings,
    required this.loggedAt,
  });

  factory MealLog.fromAnalysis({
    required String userId,
    required MealAnalysis analysis,
    DateTime? loggedAt,
  }) {
    return MealLog(
      id: '',
      userId: userId,
      title: analysis.title,
      calories: analysis.totalCalories,
      proteinGrams: analysis.totalProteinGrams,
      carbsGrams: analysis.totalCarbsGrams,
      fatGrams: analysis.totalFatGrams,
      confidence: analysis.confidence,
      provider: analysis.provider,
      items: analysis.items,
      warnings: analysis.warnings,
      loggedAt: loggedAt ?? DateTime.now(),
    );
  }

  factory MealLog.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final rawWarnings = json['warnings'];
    return MealLog(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      title: (json['title'] ?? 'Logged Meal').toString(),
      calories: _doubleFromJson(json['calories']),
      proteinGrams: _doubleFromJson(
        json['protein_grams'] ?? json['proteinGrams'],
      ),
      carbsGrams: _doubleFromJson(json['carbs_grams'] ?? json['carbsGrams']),
      fatGrams: _doubleFromJson(json['fat_grams'] ?? json['fatGrams']),
      confidence: _doubleFromJson(json['confidence']),
      provider: (json['provider'] ?? 'unknown').toString(),
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(MealFoodItem.fromJson)
                .toList()
          : const [],
      warnings: rawWarnings is List
          ? rawWarnings.map((warning) => warning.toString()).toList()
          : const [],
      loggedAt:
          DateTime.tryParse(
            (json['logged_at'] ?? json['loggedAt'] ?? '').toString(),
          ) ??
          DateTime.now(),
    );
  }

  MealLog copyWith({
    String? title,
    double? calories,
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
    double? confidence,
    String? provider,
    List<MealFoodItem>? items,
    List<String>? warnings,
    DateTime? loggedAt,
  }) {
    final nextItems = items ?? this.items;
    return MealLog(
      id: id,
      userId: userId,
      title: title ?? this.title,
      calories:
          calories ?? nextItems.fold(0, (sum, item) => sum + item.calories),
      proteinGrams:
          proteinGrams ??
          nextItems.fold(0, (sum, item) => sum + item.proteinGrams),
      carbsGrams:
          carbsGrams ?? nextItems.fold(0, (sum, item) => sum + item.carbsGrams),
      fatGrams:
          fatGrams ?? nextItems.fold(0, (sum, item) => sum + item.fatGrams),
      confidence: confidence ?? this.confidence,
      provider: provider ?? this.provider,
      items: nextItems,
      warnings: warnings ?? this.warnings,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'totalCalories': calories,
      'totalProteinGrams': proteinGrams,
      'totalCarbsGrams': carbsGrams,
      'totalFatGrams': fatGrams,
      'items': items.map((item) => item.toJson()).toList(),
      'warnings': warnings,
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'title': title,
      'calories': calories,
      'protein_grams': proteinGrams,
      'carbs_grams': carbsGrams,
      'fat_grams': fatGrams,
      'confidence': confidence,
      'provider': provider,
      'items': items.map((item) => item.toJson()).toList(),
      'warnings': warnings,
      'logged_at': loggedAt.toIso8601String(),
    };
  }
}

double _doubleFromJson(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
