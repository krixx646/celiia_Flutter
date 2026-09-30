/// Equipment tags stored on clips and on the user profile.
///
/// These are the lowercase slugs the routine generator matches against
/// `exercise_clips.equipment`. UI labels are translated separately.
class EquipmentTags {
  EquipmentTags._();

  static const dumbbell = 'dumbbell';
  static const barbell = 'barbell';
  static const kettlebell = 'kettlebell';
  static const band = 'band';
  static const cable = 'cable';
  static const machine = 'machine';
  static const smith = 'smith';
  static const pullUpBar = 'pull_up_bar';
  static const jumpRope = 'jump_rope';
  static const mat = 'mat';

  /// Options offered when the user says they train with equipment.
  static const selectable = <String>[
    dumbbell,
    barbell,
    kettlebell,
    band,
    cable,
    machine,
    pullUpBar,
    jumpRope,
    mat,
  ];

  /// English chip labels for the generate sheet / onboarding (wire values stay
  /// as [selectable] tags). Kept here so sheet and onboarding do not drift.
  static const englishLabels = <String, String>{
    dumbbell: 'Dumbbells',
    barbell: 'Barbell',
    kettlebell: 'Kettlebell',
    band: 'Resistance Bands',
    cable: 'Cable machine',
    machine: 'Gym machines',
    pullUpBar: 'Pull-up Bar',
    jumpRope: 'Jump Rope',
    mat: 'Yoga Mat',
  };
}
