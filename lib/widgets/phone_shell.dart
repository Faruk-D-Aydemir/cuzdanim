import 'dart:math' as math;

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Web ve masaüstünde iPhone çerçevesi; gerçek telefonda tam ekran.
class PhoneShell extends StatelessWidget {
  const PhoneShell({super.key, required this.child});

  final Widget child;

  static final DeviceInfo _device = Devices.ios.iPhone15Pro;

  static bool get _showFrame {
    if (kReleaseMode) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return false;
      default:
        return true;
    }
  }

  Size _windowSize(BuildContext context) {
    final view = View.of(context);
    return view.physicalSize / view.devicePixelRatio;
  }

  @override
  Widget build(BuildContext context) {
    if (!_showFrame) return child;

    final frameSize = _device.frameSize;
    final window = _windowSize(context);

    final scale = math.min(
      window.width * 0.98 / frameSize.width,
      window.height * 0.98 / frameSize.height,
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: const Color(0xFF121212),
        child: SizedBox(
          width: window.width,
          height: window.height,
          child: Center(
            child: SizedBox(
              width: frameSize.width * scale,
              height: frameSize.height * scale,
              child: FittedBox(
                fit: BoxFit.fill,
                child: SizedBox(
                  width: frameSize.width,
                  height: frameSize.height,
                  child: DeviceFrame(
                    device: _device,
                    screen: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
