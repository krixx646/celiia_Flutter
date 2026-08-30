/// VRoid Face morph target names from [Celia.vrm].
///
/// Filament loads these as standard glTF morph targets on the Face mesh.
/// Lip-sync drives the vowel shapes; blink/emotion can come later.
abstract final class CeliaAvatarMorphs {
  static const mouthA = 'Fcl_MTH_A';
  static const mouthI = 'Fcl_MTH_I';
  static const mouthU = 'Fcl_MTH_U';
  static const mouthE = 'Fcl_MTH_E';
  static const mouthO = 'Fcl_MTH_O';
  static const mouthClose = 'Fcl_MTH_Close';
  static const eyeClose = 'Fcl_EYE_Close';
  static const joy = 'Fcl_ALL_Joy';

  /// Simple amplitude → open-mouth mapping for TTS-driven lip sync V1.
  ///
  /// Returns a map of morph name → weight in 0..1.
  static Map<String, double> fromSpeechAmplitude(double amplitude) {
    final open = amplitude.clamp(0.0, 1.0);
    return {
      mouthA: open,
      mouthClose: (1.0 - open) * 0.35,
    };
  }
}
