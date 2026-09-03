/// A single body measurement as returned by the scan vendor.
///
/// Values arrive in millimetres; the getters below are what the UI should use
/// so the unit conversion lives in one place.
class BodyMeasurement {
  const BodyMeasurement({
    required this.name,
    required this.unit,
    required this.value,
  });

  final String name;
  final String unit;
  final double value;

  double get centimetres => unit == 'mm' ? value / 10 : value;

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    return BodyMeasurement(
      name: json['name']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      value: _double(json['value']) ?? 0,
    );
  }
}

/// The result of one body scan: composition estimates, circumferences and a
/// signed URL to the 3D mesh.
///
/// Every number here is an estimate from photo analysis, not a measurement.
/// Anything that displays one must say so — see [methodologySource].
class BodyScan {
  const BodyScan({
    required this.id,
    required this.scannedAt,
    required this.measurements,
    this.bodyFatPercentage,
    this.leanMassG,
    this.bodyFatMassG,
    this.weightG,
    this.waistGirthMm,
    this.hipGirthMm,
    this.bustGirthMm,
    this.meshUrl,
  });

  final String id;
  final DateTime scannedAt;
  final List<BodyMeasurement> measurements;
  final double? bodyFatPercentage;
  final double? leanMassG;
  final double? bodyFatMassG;
  final double? weightG;
  final double? waistGirthMm;
  final double? hipGirthMm;
  final double? bustGirthMm;

  /// Signed and short-lived, so it must be downloaded rather than stored.
  final String? meshUrl;

  double? get leanMassKg => leanMassG == null ? null : leanMassG! / 1000;
  double? get bodyFatMassKg => bodyFatMassG == null ? null : bodyFatMassG! / 1000;
  double? get weightKg => weightG == null ? null : weightG! / 1000;
  double? get waistCm => waistGirthMm == null ? null : waistGirthMm! / 10;
  double? get hipCm => hipGirthMm == null ? null : hipGirthMm! / 10;
  double? get bustCm => bustGirthMm == null ? null : bustGirthMm! / 10;

  /// Waist-to-hip ratio, a widely used health indicator we get for free.
  double? get waistToHipRatio {
    final waist = waistGirthMm;
    final hip = hipGirthMm;
    if (waist == null || hip == null || hip == 0) return null;
    return waist / hip;
  }

  bool get hasComposition => bodyFatPercentage != null;

  factory BodyScan.fromJson(Map<String, dynamic> json) {
    final rawMeasurements = json['measurements'];
    return BodyScan(
      id: json['id']?.toString() ?? '',
      scannedAt: DateTime.tryParse(json['scannedAt']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      measurements: rawMeasurements is List
          ? rawMeasurements
                .whereType<Map>()
                .map((m) => BodyMeasurement.fromJson(Map<String, dynamic>.from(m)))
                .toList()
          : const [],
      bodyFatPercentage: _double(json['bodyFatPercentage']),
      leanMassG: _double(json['leanMassG']),
      bodyFatMassG: _double(json['bodyFatMassG']),
      weightG: _double(json['weightG']),
      waistGirthMm: _double(json['waistGirthMm']),
      hipGirthMm: _double(json['hipGirthMm']),
      bustGirthMm: _double(json['bustGirthMm']),
      meshUrl: json['meshUrl']?.toString(),
    );
  }
}

/// How many scans the user has left in the current period.
class BodyScanQuota {
  const BodyScanQuota({required this.remaining, this.resetsAt});

  final int remaining;
  final DateTime? resetsAt;

  factory BodyScanQuota.fromJson(Map<String, dynamic> json) {
    return BodyScanQuota(
      remaining: (_double(json['remaining']) ?? 0).round(),
      resetsAt: DateTime.tryParse(json['resetsAt']?.toString() ?? '')?.toLocal(),
    );
  }
}

class BodyScanResult {
  const BodyScanResult({required this.scan, this.quota});

  final BodyScan scan;
  final BodyScanQuota? quota;
}

/// Why a scan could not be produced.
///
/// The photo categories are recoverable: the user retakes and tries again.
/// Everything else needs a different action, so the UI branches on this rather
/// than on a raw string from the server.
enum BodyScanError {
  photoFraming,
  photoQuality,
  photoPose,
  photoClothing,
  photoUnknown,
  photosTooLarge,
  quotaExhausted,
  notEligibleAge,
  invalidStats,
  notSignedIn,
  notConfigured,
  network,
  server,
}

class BodyScanException implements Exception {
  const BodyScanException(this.error, {this.details, this.resetsAt});

  final BodyScanError error;
  final String? details;

  /// When [error] is [BodyScanError.quotaExhausted], when the next scan unlocks.
  final DateTime? resetsAt;

  bool get isRetakeable => switch (error) {
    BodyScanError.photoFraming ||
    BodyScanError.photoQuality ||
    BodyScanError.photoPose ||
    BodyScanError.photoClothing ||
    BodyScanError.photoUnknown ||
    BodyScanError.photosTooLarge => true,
    _ => false,
  };

  @override
  String toString() => 'BodyScanException(${error.name}, $details)';
}

/// Shown wherever a body composition number appears.
///
/// App Store guideline 1.4.1 requires health figures to name their method and
/// its limits; this is the single source for that text so it cannot drift
/// between screens.
class BodyScanMethodology {
  const BodyScanMethodology._();

  static const String provider = 'Bodygram';

  /// Mean absolute error against DXA reported for smartphone 3D scanning.
  static const double meanAbsoluteErrorPercent = 3.5;

  static const String methodKey = 'bodyScanMethodology';
  static const String disclaimerKey = 'bodyScanDisclaimer';
}

double? _double(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
