import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import 'celia_avatar_controller.dart';
import 'celia_avatar_state.dart';
import 'celia_avatar_view.dart';

/// Compact VRoid strip for the coach chat screen.
///
/// Height follows available width (phone vs tablet) via [LayoutBuilder] so the
/// PlatformView never gets a fixed phone-only size that overflows or looks
/// tiny on large windows.
class CeliaChatAvatarPanel extends StatelessWidget {
  const CeliaChatAvatarPanel({
    super.key,
    required this.controller,
    required this.state,
    required this.theme,
  });

  final CeliaAvatarController controller;
  final CeliaAvatarState state;
  final ThemeProvider theme;

  static const _phoneHeight = 168.0;
  static const _tabletHeight = 220.0;
  static const _minHeight = 96.0;
  static const _largeScreenMinWidth = 600.0;

  String _statusLabel(AppLocalizations l10n) {
    switch (state) {
      case CeliaAvatarState.idle:
        return l10n.chatAvatarReady;
      case CeliaAvatarState.listening:
        return l10n.chatListening;
      case CeliaAvatarState.thinking:
        return l10n.chatAvatarThinking;
      case CeliaAvatarState.speaking:
        return l10n.chatAvatarSpeaking;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = _statusLabel(l10n);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _largeScreenMinWidth;
        final preferred = wide ? _tabletHeight : _phoneHeight;
        // Keep the strip shorter than it is wide so the message list stays
        // usable, but never invert the bounds: in split-screen the width can
        // fall below the minimum height, and clamp() throws on lower > upper.
        final widthCap = constraints.maxWidth * 0.45;
        final height = widthCap <= _minHeight
            ? _minHeight
            : preferred.clamp(_minHeight, widthCap);

        return Semantics(
          label: l10n.chatAvatarSemantics(status),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.isDarkMode
                    ? const Color(0xFF101018)
                    : const Color(0xFF1A1A24),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.accentOrange.withValues(
                    alpha: state == CeliaAvatarState.listening ||
                            state == CeliaAvatarState.speaking
                        ? 0.55
                        : 0.22,
                  ),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18.5),
                child: SizedBox(
                  width: double.infinity,
                  height: height.toDouble(),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CeliaAvatarView(controller: controller),
                      Positioned(
                        left: 12,
                        bottom: 10,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
