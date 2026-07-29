class MealBoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  const MealBoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory MealBoundingBox.fromJson(Map<String, dynamic> json) {
    return MealBoundingBox(
      x: _doubleFromJson(json['x']),
      y: _doubleFromJson(json['y']),
      width: _doubleFromJson(json['width']),
      height: _doubleFromJson(json['height']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y, 'width': width, 'height': height};
  }
}

class MealFoodItem {
  final String name;
  final double servingGrams;
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double confidence;
  final String? notes;
  final MealBoundingBox? box;

  const MealFoodItem({
    required this.name,
    required this.servingGrams,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.confidence,
    this.notes,
    this.box,
  });

  factory MealFoodItem.fromJson(Map<String, dynamic> json) {
    final rawBox = json['box'];
    return MealFoodItem(
      name: (json['name'] ?? '').toString(),
      servingGrams: _doubleFromJson(json['servingGrams']),
      calories: _doubleFromJson(json['calories']),
      proteinGrams: _doubleFromJson(json['proteinGrams']),
      carbsGrams: _doubleFromJson(json['carbsGrams']),
      fatGrams: _doubleFromJson(json['fatGrams']),
      confidence: _doubleFromJson(json['confidence']),
      notes: json['notes']?.toString(),
      box: rawBox is Map<String, dynamic>
          ? MealBoundingBox.fromJson(rawBox)
          : null,
    );
  }

  MealFoodItem copyWith({
    String? name,
    double? servingGrams,
    double? calories,
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
    double? confidence,
    String? notes,
    MealBoundingBox? box,
  }) {
    return MealFoodItem(
      name: name ?? this.name,
      servingGrams: servingGrams ?? this.servingGrams,
      calories: calories ?? this.calories,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      confidence: confidence ?? this.confidence,
      notes: notes ?? this.notes,
      box: box ?? this.box,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'servingGrams': servingGrams,
      'calories': calories,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
      'confidence': confidence,
      if (notes != null) 'notes': notes,
      if (box != null) 'box': box!.toJson(),
    };
  }
}

class MealAnalysis {
  final String title;
  final String provider;
  final String summary;
  final double confidence;
  final double totalCalories;
  final double totalProteinGrams;
  final double totalCarbsGrams;
  final double totalFatGrams;
  final List<MealFoodItem> items;
  final List<String> warnings;

  const MealAnalysis({
    required this.title,
    required this.provider,
    required this.summary,
    required this.confidence,
    required this.totalCalories,
    required this.totalProteinGrams,
    required this.totalCarbsGrams,
    required this.totalFatGrams,
    required this.items,
    required this.warnings,
  });

  factory MealAnalysis.empty() {
    return const MealAnalysis(
      title: 'No meal detected',
      provider: 'local',
      summary: 'Point the camera at a meal to estimate nutrition.',
      confidence: 0,
      totalCalories: 0,
      totalProteinGrams: 0,
      totalCarbsGrams: 0,
      totalFatGrams: 0,
      items: [],
      warnings: [],
    );
  }

  factory MealAnalysis.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final rawWarnings = json['warnings'];
    return MealAnalysis(
      title: (json['title'] ?? 'Estimated Meal').toString(),
      provider: (json['provider'] ?? 'unknown').toString(),
      summary: (json['summary'] ?? 'Estimated from image.').toString(),
      confidence: _doubleFromJson(json['confidence']),
      totalCalories: _doubleFromJson(json['totalCalories']),
      totalProteinGrams: _doubleFromJson(json['totalProteinGrams']),
      totalCarbsGrams: _doubleFromJson(json['totalCarbsGrams']),
      totalFatGrams: _doubleFromJson(json['totalFatGrams']),
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(MealFoodItem.fromJson)
                .toList()
          : const [],
      warnings: rawWarnings is List
          ? rawWarnings.map((warning) => warning.toString()).toList()
          : const [],
    );
  }

  MealAnalysis copyWith({
    String? title,
    String? provider,
    String? summary,
    double? confidence,
    double? totalCalories,
    double? totalProteinGrams,
    double? totalCarbsGrams,
    double? totalFatGrams,
    List<MealFoodItem>? items,
    List<String>? warnings,
  }) {
    final nextItems = items ?? this.items;
    return MealAnalysis(
      title: title ?? this.title,
      provider: provider ?? this.provider,
      summary: summary ?? this.summary,
      confidence: confidence ?? this.confidence,
      totalCalories:
          totalCalories ??
          nextItems.fold(0, (sum, item) => sum + item.calories),
      totalProteinGrams:
          totalProteinGrams ??
          nextItems.fold(0, (sum, item) => sum + item.proteinGrams),
      totalCarbsGrams:
          totalCarbsGrams ??
          nextItems.fold(0, (sum, item) => sum + item.carbsGrams),
      totalFatGrams:
          totalFatGrams ??
          nextItems.fold(0, (sum, item) => sum + item.fatGrams),
      items: nextItems,
      warnings: warnings ?? this.warnings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'provider': provider,
      'summary': summary,
      'confidence': confidence,
      'totalCalories': totalCalories,
      'totalProteinGrams': totalProteinGrams,
      'totalCarbsGrams': totalCarbsGrams,
      'totalFatGrams': totalFatGrams,
      'items': items.map((item) => item.toJson()).toList(),
      'warnings': warnings,
    };
  }
}

double _doubleFromJson(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
