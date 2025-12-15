import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/material.dart';

class LossCalculatorScreen extends StatefulWidget {
  const LossCalculatorScreen({super.key});

  @override
  State<LossCalculatorScreen> createState() => _LossCalculatorScreenState();
}

class _LossCalculatorScreenState extends State<LossCalculatorScreen> {
  final _diameterCtrl = TextEditingController();
  final _freqCtrl = TextEditingController();
  final _wavelengthCtrl = TextEditingController();
  final _gainCtrl = TextEditingController();

  final _dataRateCtrl = TextEditingController();
  final _modFactorCtrl = TextEditingController();
  final _fecCtrl = TextEditingController();
  final _symbolRateCtrl = TextEditingController();

  final _distanceCtrl = TextEditingController();
  final _flossFreqCtrl = TextEditingController();
  final _txGainCtrl = TextEditingController();
  final _rxGainCtrl = TextEditingController();
  final _fsplCtrl = TextEditingController();
  final _fsplResultCtrl = TextEditingController();

  final _eirpCtrl = TextEditingController();
  final _gtCtrl = TextEditingController();
  final _bandwidthCtrl = TextEditingController();
  final _cnRatioCtrl = TextEditingController();

  bool _showGain = false;
  bool _showSymbolRate = false;
  bool _showFspl = false;
  bool _showCn = false;

  @override
  void initState() {
    super.initState();

    _diameterCtrl.text = "1.2";
    _freqCtrl.text = "12";
    _dataRateCtrl.text = "45000000";
    _modFactorCtrl.text = "2";
    _fecCtrl.text = "0.75";
    _distanceCtrl.text = "36000";
    _flossFreqCtrl.text = "12";
    _txGainCtrl.text = "45";
    _rxGainCtrl.text = "43";
    _eirpCtrl.text = "52";
    _gtCtrl.text = "15";
    _bandwidthCtrl.text = "36";

    _freqCtrl.addListener(_onFrequencyChanged);
    _onFrequencyChanged();
  }

  void _onFrequencyChanged() {
    final fGHz = double.tryParse(_freqCtrl.text);
    if (fGHz == null || fGHz == 0) return;
    final wavelength = 3e8 / (fGHz * 1e9);
    _wavelengthCtrl.text = wavelength.toStringAsFixed(6);
  }

  bool _filled(List<TextEditingController> c) =>
      c.every((e) => e.text.trim().isNotEmpty);

  void _calculateGain() {
    if (!_filled([_diameterCtrl, _freqCtrl])) return;

    final d = double.parse(_diameterCtrl.text);
    final f = double.parse(_freqCtrl.text) * 1e9;
    final lambda = 3e8 / f;
    const efficiency = 0.65;

    final gain =
        10 * math.log(efficiency * math.pow((math.pi * d / lambda), 2)) /
            math.ln10;

    _gainCtrl.text = gain.toStringAsFixed(2);
    setState(() => _showGain = true);
  }

  void _calculateSymbolRate() {
    if (!_filled([_dataRateCtrl, _modFactorCtrl, _fecCtrl])) return;

    final sr = double.parse(_dataRateCtrl.text) /
        (double.parse(_modFactorCtrl.text) *
            double.parse(_fecCtrl.text));

    _symbolRateCtrl.text = sr.toStringAsFixed(4);
    setState(() => _showSymbolRate = true);
  }

  void _calculateFspl() {
    if (!_filled([_distanceCtrl, _flossFreqCtrl])) return;

    final d = double.parse(_distanceCtrl.text);
    final f = double.parse(_flossFreqCtrl.text);

    final fspl = 92.45 +
        20 * math.log(d) / math.ln10 +
        20 * math.log(f) / math.ln10;

    _fsplCtrl.text = fspl.toStringAsFixed(2);
    _fsplResultCtrl.text = fspl.toStringAsFixed(2);
    setState(() => _showFspl = true);
  }

  void _calculateCnRatio() {
    if (!_filled(
        [_eirpCtrl, _fsplResultCtrl, _gtCtrl, _bandwidthCtrl])) return;

    const k = -228.6;

    final bandwidthHz =
        double.parse(_bandwidthCtrl.text) * 1e6;

    final cn = double.parse(_eirpCtrl.text) -
        double.parse(_fsplResultCtrl.text) +
        double.parse(_gtCtrl.text) -
        k -
        10 * math.log(bandwidthHz) / math.ln10;

    _cnRatioCtrl.text = cn.toStringAsFixed(2);
    setState(() => _showCn = true);
  }

  Widget _cosmicField(String label, TextEditingController c,
      {bool ro = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        readOnly: ro,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF141A2E),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _cosmicBtn(String t, VoidCallback f) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 6,
        bottom: 14,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3A4DF4),
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: f,
          child: Text(
            t,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassCard(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          child
        ],
      ),
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
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
              child: Column(children: [
                _glassCard("Antenna Gain", Column(children: [
                  _cosmicField("Dish Diameter (m)", _diameterCtrl),
                  _cosmicField("Frequency (GHz)", _freqCtrl),
                  _cosmicField("Wavelength", _wavelengthCtrl, ro: true),
                  _cosmicBtn("Calculate Gain", _calculateGain),
                  if (_showGain)
                    _cosmicField("Gain (dBi)", _gainCtrl, ro: true),
                ])),

                _glassCard("Symbol Rate", Column(children: [
                  _cosmicField("Data Rate", _dataRateCtrl),
                  _cosmicField("Modulation", _modFactorCtrl),
                  _cosmicField("FEC", _fecCtrl),
                  _cosmicBtn("Calculate Symbol Rate", _calculateSymbolRate),
                  if (_showSymbolRate)
                    _cosmicField("Symbol Rate", _symbolRateCtrl, ro: true),
                ])),

                _glassCard("Free Space Path Loss", Column(children: [
                  _cosmicField("Distance (km)", _distanceCtrl),
                  _cosmicField("Frequency (GHz)", _flossFreqCtrl),
                  _cosmicField("Tx Gain", _txGainCtrl),
                  _cosmicField("Rx Gain", _rxGainCtrl),
                  _cosmicBtn("Calculate FSPL", _calculateFspl),
                  if (_showFspl)
                    _cosmicField("FSPL", _fsplCtrl, ro: true),
                ])),

                _glassCard("Carrier to Noise Ratio", Column(children: [
                  _cosmicField("EIRP", _eirpCtrl),
                  _cosmicField("FSPL", _fsplResultCtrl, ro: true),
                  _cosmicField("G/T", _gtCtrl),
                  _cosmicField("Bandwidth", _bandwidthCtrl),
                  _cosmicBtn("Calculate C/N Ratio", _calculateCnRatio),
                  if (_showCn)
                    _cosmicField("C/N Ratio", _cnRatioCtrl, ro: true),
                ])),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}


class NebulaBackground extends StatelessWidget {
  const NebulaBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.0, -0.2),
          radius: 1.2,
          colors: [Color(0xFF1E3A8A), Color(0xFF05060A)],
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
  final Random _random = Random();
  late Offset _start;

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
      Offset(pos.dx * size.width + anim * 150,
          pos.dy * size.height + anim * 150),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}