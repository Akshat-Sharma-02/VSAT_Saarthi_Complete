import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:torch_light/torch_light.dart';

class CompassScreen extends StatefulWidget {
  final double targetAzimuth;
  final double targetElevation;
  final String userLatitude;
  final String userLongitude;

  const CompassScreen({
    super.key,
    required this.targetAzimuth,
    required this.targetElevation,
    required this.userLatitude,
    required this.userLongitude,
  });

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  bool _torchOn = false;
  bool _azimuthLocked = false;
  bool _elevationLocked = false;
  bool _showReset = false;

  double _lockHeading = 0;
  double _lockPitch = 0; // ✅ Frozen Elevation
  double _userPitch = 0.0;
  double _lastBeepDiff = 999;

  StreamSubscription? _tiltSub;

  static const double compassSize = 300;
  static const double ringSize = 280;
  static const double center = compassSize / 2;
  static const double dotSize = 6;
  static const double dotRadius = ringSize / 2 + 8;

  @override
  void initState() {
    super.initState();

    _tiltSub = accelerometerEvents.listen((event) {
      final ax = event.x;
      final ay = event.y;
      final az = event.z;

      double pitch = atan2(ay, sqrt(ax * ax + az * az)) * (180 / pi);
      pitch = pitch.clamp(-90.0, 90.0);

      if (!_elevationLocked && mounted) {
        setState(() => _userPitch = pitch);
      }
    });
  }

  @override
  void dispose() {
    _tiltSub?.cancel();
    super.dispose();
  }

  void _pitchBeep(double diff) {
    if (diff > 75) return;
    if ((diff - _lastBeepDiff).abs() < 4) return;

    _lastBeepDiff = diff;
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
  }

  void _resetCompass() {
    if (!mounted) return;
    setState(() {
      _azimuthLocked = false;
      _elevationLocked = false;
      _showReset = false;
      _lockHeading = 0;
      _lockPitch = 0;
      _lastBeepDiff = 999;
    });
  }

  Future<void> _toggleTorch() async {
    try {
      if (_torchOn) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
      if (mounted) setState(() => _torchOn = !_torchOn);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05060A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1122),
        title: const Text(
          "Compass Alignment",
          style: TextStyle(fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: Icon(_torchOn ? Icons.flash_off : Icons.flash_on),
            onPressed: _toggleTorch,
          )
        ],
      ),
      body: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final heading = snap.data!.heading ?? 0;
          final displayHeading = _azimuthLocked ? _lockHeading : heading;

          double rawDiff = (widget.targetAzimuth - heading) % 360;
          if (rawDiff < 0) rawDiff += 360;
          double azDiff = rawDiff > 180 ? 360 - rawDiff : rawDiff;

          /// ✅ AZIMUTH LOCK ±1°
          if (!_azimuthLocked && azDiff <= 1 && !_showReset) {
            _azimuthLocked = true;
            _lockHeading = heading;
            HapticFeedback.heavyImpact();
            SystemSound.play(SystemSoundType.alert);
          }

          /// ✅ RESET IF MOVED AFTER LOCK
          if (_azimuthLocked && (heading - _lockHeading).abs() > 3) {
            _showReset = true;
          }

          if (!_azimuthLocked) _pitchBeep(azDiff);

          final double satelliteAngleRad =
              (widget.targetAzimuth - displayHeading) * pi / 180;

          final double dotX = dotRadius * sin(satelliteAngleRad);
          final double dotY = dotRadius * -cos(satelliteAngleRad);

          final Color dotColor = _azimuthLocked
              ? Colors.green
              : azDiff <= 1
                  ? Colors.green
                  : azDiff <= 75
                      ? Colors.orange
                      : Colors.red;

          /// ✅ EFFECTIVE PITCH (FREEZES AFTER LOCK)
          final double effectivePitch =
              _elevationLocked ? _lockPitch : _userPitch;

          final double elevationDiff =
              widget.targetElevation - effectivePitch;

          /// ✅ ELEVATION LOCK ±4°
          if (_azimuthLocked &&
              !_elevationLocked &&
              elevationDiff.abs() <= 4) {
            _elevationLocked = true;
            _lockPitch = _userPitch;
            _showReset = true;
            HapticFeedback.heavyImpact();
            SystemSound.play(SystemSoundType.alert);
          }

          final Color elevationColor = _elevationLocked
              ? Colors.green
              : elevationDiff.abs() < 4
                  ? Colors.green
                  : elevationDiff.abs() < 12
                      ? Colors.orange
                      : Colors.red;

          final double elevationFill = ((1 -
                  min(elevationDiff.abs() / 60, 1))
              .clamp(0.0, 1.0))
              .toDouble();

          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  /// ✅ TOP CHIPS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _chip("Target Az",
                          "${widget.targetAzimuth.toStringAsFixed(1)}°"),
                      _chip("Your Az",
                          "${displayHeading.toStringAsFixed(1)}°"),
                      _chip("Target El",
                          "${widget.targetElevation.toStringAsFixed(1)}°"),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// ✅ COMPASS
                  SizedBox(
                    width: compassSize,
                    height: compassSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Color(0xFF3A4DF4), Colors.transparent],
                            ),
                          ),
                        ),

                        Transform.rotate(
                          angle: -displayHeading * pi / 180,
                          child: CustomPaint(
                            size: const Size(ringSize, ringSize),
                            painter: ScreenshotCompassPainter(),
                          ),
                        ),

                        Positioned(
                          left: center + dotX - dotSize / 2,
                          top: center + dotY - dotSize / 2,
                          child: Container(
                            width: dotSize,
                            height: dotSize,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: dotColor.withOpacity(0.9),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),

                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.keyboard_arrow_up, size: 32),
                            const SizedBox(height: 6),
                            Text(
                              "${displayHeading.toInt()}°",
                              style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// ✅ ELEVATION BAR
                  const Text("Elevation",
                      style:
                          TextStyle(color: Colors.white70, fontSize: 18)),
                  const SizedBox(height: 10),

                  Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 20,
                        width: 280,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      Container(
                        height: 20,
                        width: 280.0 * elevationFill,
                        decoration: BoxDecoration(
                          color: elevationColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Pitch: ${effectivePitch.toStringAsFixed(1)}° | Target: ${widget.targetElevation.toStringAsFixed(1)}°",
                    style: TextStyle(
                        color: elevationColor, fontSize: 18),
                  ),

                  const SizedBox(height: 20),

                  /// ✅ GUIDANCE
                  Text(
                    _azimuthLocked
                        ? "Azimuth Locked ✅ Now Match Elevation"
                        : rawDiff > 180
                            ? "Move Left by ${(360 - rawDiff).toStringAsFixed(1)}°"
                            : "Move Right by ${rawDiff.toStringAsFixed(1)}°",
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 18),
                  ),

                  const SizedBox(height: 16),

                  /// ✅ DARK BLUE RESET BUTTON
                  if (_showReset)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF1E40AF),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 36, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _resetCompass,
                      child: const Text(
                        "Reset Azimuth & Elevation",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _chip(String title, String value) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white60, fontSize: 17)),
        const SizedBox(height: 6),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1D4ED8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
        ),
      ],
    );
  }
}

// ================= DIGITAL RING =================
class ScreenshotCompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final minor = Paint()..color = Colors.white54;
    final major = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    final textPainter =
        TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.ltr);

    for (int i = 0; i < 360; i += 5) {
      final angle = (i - 90) * pi / 180;
      final isMajor = i % 30 == 0;
      final len = isMajor ? 14.0 : 7.0;
      final paint = isMajor ? major : minor;

      canvas.drawLine(
        Offset(c.dx + r * cos(angle), c.dy + r * sin(angle)),
        Offset(c.dx + (r - len) * cos(angle),
            c.dy + (r - len) * sin(angle)),
        paint,
      );

      if (isMajor) {
        textPainter.text = TextSpan(
          text: "$i",
          style:
              const TextStyle(color: Colors.white70, fontSize: 13),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
              c.dx + (r - 28) * cos(angle) -
                  textPainter.width / 2,
              c.dy + (r - 28) * sin(angle) -
                  textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}