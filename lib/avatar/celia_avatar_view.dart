import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'celia_avatar_controller.dart';

/// Embeds the native VRoid surface.
///
/// Android → Google Filament PlatformView.
/// iOS → SceneKit PlatformView.
class CeliaAvatarView extends StatefulWidget {
  const CeliaAvatarView({
    super.key,
    required this.controller,
    this.onReady,
    this.onError,
  });

  final CeliaAvatarController controller;
  final VoidCallback? onReady;
  final void Function(Object error)? onError;

  @override
  State<CeliaAvatarView> createState() => _CeliaAvatarViewState();
}

class _CeliaAvatarViewState extends State<CeliaAvatarView> {
  static const _viewType = 'eu.thefit.celia/vrm_avatar_view';
  var _loading = true;
  var _bootstrapped = false;
  String? _error;

  /// Driven by [AndroidView.onPlatformViewCreated] / its iOS counterpart, which
  /// fire once the native surface exists. Waiting on a fixed delay instead both
  /// raced the native side and left a timer pending after dispose.
  Future<void> _bootstrap() async {
    if (_bootstrapped) return;
    _bootstrapped = true;
    if (!mounted) return;
    try {
      await widget.controller.attach();
      await widget.controller.loadBundledModel();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = null;
      });
      widget.onReady?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
      widget.onError?.call(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const Center(child: Text('VRM avatar is mobile-only'));
    }

    final Widget nativeView;
    if (Platform.isAndroid) {
      nativeView = AndroidView(
        viewType: _viewType,
        layoutDirection: TextDirection.ltr,
        creationParamsCodec: const StandardMessageCodec(),
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        onPlatformViewCreated: (_) => _bootstrap(),
      );
    } else if (Platform.isIOS) {
      nativeView = UiKitView(
        viewType: _viewType,
        layoutDirection: TextDirection.ltr,
        creationParamsCodec: const StandardMessageCodec(),
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        onPlatformViewCreated: (_) => _bootstrap(),
      );
    } else {
      nativeView = const Center(
        child: Text('VRM avatar not supported on this platform'),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        nativeView,
        if (_loading)
          const ColoredBox(
            color: Color(0xFF101018),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (_error != null)
          ColoredBox(
            color: const Color(0xFF101018),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Avatar failed to load:\n$_error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
