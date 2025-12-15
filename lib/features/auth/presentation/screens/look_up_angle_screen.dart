// -----------------------
// LOOK UP ANGLE SCREEN (FINAL PRODUCTION VERSION ✅)
// -----------------------

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'compass_screen.dart';

class LookUpAngleScreen extends StatefulWidget {
  const LookUpAngleScreen({super.key});

  @override
  State<LookUpAngleScreen> createState() => _LookUpAngleScreenState();
}

class _LookUpAngleScreenState extends State<LookUpAngleScreen> {
  static const String satListUrl =
      'https://satellite-detail.onrender.com/satellite/getsatellite';
  static const String lookupApiUrl =
      'https://satellite-detail.onrender.com/angle/calculatelookupangle';

  final _userLat = TextEditingController();
  final _userLon = TextEditingController();
  final _satLat = TextEditingController();
  final _satLon = TextEditingController();
  final _satAlt = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  List<String> _satellites = [];
  String? _selectedSatellite;

  final List<String> _providers = ['Dish TV', 'DD Free Dish', 'TATA Play'];
  String? _selectedProvider;

  String? _azimuth;
  String? _elevation;

  bool _gpsLoading = false;
  bool _calculating = false;

  @override
  void initState() {
    super.initState();
    _userLat.text = "28.613939";
    _userLon.text = "77.209023";
    _selectedProvider = "Dish TV";

    _satLat.text = "0.000000";
    _satLon.text = "93.5";
    _satAlt.text = "35786";

    _fetchSatellites();
  }

  @override
  void dispose() {
    _userLat.dispose();
    _userLon.dispose();
    _satLat.dispose();
    _satLon.dispose();
    _satAlt.dispose();
    super.dispose();
  }

  void _resetDefaults() {
    setState(() {
      _userLat.text = "28.613939";
      _userLon.text = "77.209023";
      _selectedProvider = "Dish TV";
      _selectedSatellite = "GSAT-15";
      _satLat.text = "0.000000";
      _satLon.text = "93.5";
      _satAlt.text = "35786";
    });
  }

  Future<void> _fetchSatellites() async {
    try {
      final res = await http.get(Uri.parse(satListUrl));
      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body) as List;

      if (!mounted) return;
      setState(() {
        _satellites = data.map((e) => e['satname'].toString()).toList();
        if (_satellites.contains("GSAT-15")) {
          _selectedSatellite = "GSAT-15";
        }
      });
    } catch (_) {}
  }

  String _providerToSatellite(String p) {
    if (p == 'Dish TV' || p == 'DD Free Dish') return 'GSAT-15';
    if (p == 'TATA Play') return 'GSAT-24';
    return '';
  }

  Future<void> _loadSatelliteDetails(String name) async {
    try {
      final res = await http.get(Uri.parse(satListUrl));
      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body) as List;
      for (final item in data) {
        if (item['satname'] == name) {
          if (!mounted) return;
          setState(() {
            _satLat.text = item['satlatitude'].toString();
            _satLon.text = item['satlongitude'].toString();
            _satAlt.text = item['sataltitude'].toString();
          });
          break;
        }
      }
    } catch (_) {}
  }

  // ✅ FULLY SAFE GPS HANDLER
  Future<void> _useGPS() async {
    setState(() => _gpsLoading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'GPS_DISABLED';

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw 'PERMISSION_DENIED';
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'PERMISSION_DENIED_FOREVER';
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        _userLat.text = pos.latitude.toStringAsFixed(6);
        _userLon.text = pos.longitude.toStringAsFixed(6);
      });
    } catch (e) {
      String msg = "Location error";

      if (e.toString().contains('GPS_DISABLED')) {
        msg = "Please enable GPS service.";
      } else if (e.toString().contains('PERMISSION_DENIED_FOREVER')) {
        msg =
            "Location permission permanently denied.\nEnable it from Settings.";
      } else if (e.toString().contains('PERMISSION_DENIED')) {
        msg = "Location permission denied.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _gpsLoading = false);
    }
  }

  Future<void> _calculateAngle() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _calculating = true);

    try {
      final body = {
        'longitude': _userLon.text,
        'latitude': _userLat.text,
        'satlatitude': _satLat.text,
        'satlongitude': _satLon.text,
        'sataltitude': _satAlt.text,
      };

      final res = await http.post(
        Uri.parse(lookupApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(res.body);

      if (!mounted) return;
      setState(() {
        _azimuth =
            double.parse(data['azimuth'].toString()).toStringAsFixed(5);
        _elevation =
            double.parse(data['elevation'].toString()).toStringAsFixed(5);
      });
    } finally {
      if (mounted) setState(() => _calculating = false);
    }
  }

  Widget _blueButton(String text, VoidCallback onTap, {bool loading = false}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3A4DF4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: loading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(text, style: const TextStyle(fontSize: 17)),
      ),
    );
  }

  Widget _glassCard(Widget child) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white24),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _input(String label, TextEditingController c) {
    return TextFormField(
      controller: c,
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF0F1320),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF141A2E),
      border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const NebulaBackground(),
          const BlinkingStarBackground(),
          const ShootingStarLayer(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedProvider,
                      decoration: _dropdownDecoration("Provider"),
                      items: _providers
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _selectedProvider = v);
                        final sat = _providerToSatellite(v!);
                        _selectedSatellite = sat;
                        _loadSatelliteDetails(sat);
                      },
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: _selectedSatellite,
                      decoration: _dropdownDecoration("Satellite"),
                      items: _satellites
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _selectedSatellite = v);
                        _loadSatelliteDetails(v!);
                      },
                    ),

                    const SizedBox(height: 16),

                    _glassCard(Column(children: [
                      _input("Latitude", _userLat),
                      const SizedBox(height: 12),
                      _input("Longitude", _userLon),
                      const SizedBox(height: 12),
                      _blueButton("Use GPS", _useGPS,
                          loading: _gpsLoading),
                      const SizedBox(height: 12),
                      _blueButton("Reset Defaults", _resetDefaults),
                    ])),

                    const SizedBox(height: 16),

                    _glassCard(Column(children: [
                      _input("Satellite Latitude", _satLat),
                      const SizedBox(height: 12),
                      _input("Satellite Longitude", _satLon),
                      const SizedBox(height: 12),
                      _input("Satellite Altitude", _satAlt),
                    ])),

                    const SizedBox(height: 20),

                    _blueButton("Calculate Look-Up Angle", _calculateAngle,
                        loading: _calculating),

                    if (_azimuth != null && _elevation != null) ...[
                      const SizedBox(height: 20),
                      _glassCard(Column(children: [
                        Text("Azimuth: $_azimuth°",
                            style:
                                const TextStyle(color: Colors.white)),
                        Text("Elevation: $_elevation°",
                            style:
                                const TextStyle(color: Colors.white)),
                        const SizedBox(height: 12),
                        _blueButton("Open Compass", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CompassScreen(
                                targetAzimuth:
                                    double.parse(_azimuth!),
                                targetElevation:
                                    double.parse(_elevation!),
                                userLatitude: _userLat.text,
                                userLongitude: _userLon.text,
                              ),
                            ),
                          );
                        })
                      ])),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= SPACE EFFECTS =================

class NebulaBackground extends StatelessWidget {
  const NebulaBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.0, -0.2),
          radius: 1.2,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF05060A),
          ],
        ),
      ),
    );
  }
}

class BlinkingStarBackground extends StatefulWidget {
  const BlinkingStarBackground({super.key});

  @override
  State<BlinkingStarBackground> createState() =>
      _BlinkingStarBackgroundState();
}

class _BlinkingStarBackgroundState extends State<BlinkingStarBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  late List<Offset> stars;

  @override
  void initState() {
    super.initState();
    stars = List.generate(
        120, (_) => Offset(_random.nextDouble(), _random.nextDouble()));

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(
        painter: _BlinkPainter(stars, _controller.value),
        size: MediaQuery.of(context).size,
      ),
    );
  }
}

class _BlinkPainter extends CustomPainter {
  final List<Offset> stars;
  final double blink;

  _BlinkPainter(this.stars, this.blink);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final paint =
          Paint()..color = Colors.white.withOpacity(0.3 + blink * 0.7);
      canvas.drawCircle(
        Offset(s.dx * size.width, s.dy * size.height),
        1.2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class ShootingStarLayer extends StatefulWidget {
  const ShootingStarLayer({super.key});

  @override
  State<ShootingStarLayer> createState() => _ShootingStarLayerState();
}

class _ShootingStarLayerState extends State<ShootingStarLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Offset _start;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _resetStar();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
  }

  void _resetStar() {
    _start = Offset(_random.nextDouble(), _random.nextDouble());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        if (_controller.value > 0.98) _resetStar();

        return CustomPaint(
          painter: _ShootingPainter(_start, _controller.value),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ShootingPainter extends CustomPainter {
  final Offset pos;
  final double anim;

  _ShootingPainter(this.pos, this.anim);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(1 - anim)
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(pos.dx * size.width, pos.dy * size.height),
      Offset(
          pos.dx * size.width + anim * 150,
          pos.dy * size.height + anim * 150),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}