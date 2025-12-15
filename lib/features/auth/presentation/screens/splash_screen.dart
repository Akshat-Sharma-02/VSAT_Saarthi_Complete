import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _fadeAnim = CurvedAnimation(
      parent: _fadeCtrl,
      curve: Curves.easeIn,
    );

    _fadeCtrl.forward();

    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Widget tryLoad(String path,
      {BoxFit fit = BoxFit.cover,
      double? width,
      double? height,
      double opacity = 1}) {
    return Opacity(
      opacity: opacity,
      child: Image.asset(
        path,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => const SizedBox(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF000000),
                  Color(0xFF14213D),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Positioned(
            right: -40,
            top: 80,
            child: tryLoad(
              "assets/bg/satellite_watermark.png",
              width: 240,
              opacity: 0.12,
            ),
          ),

          Positioned(
            left: -80,
            bottom: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFCA311).withOpacity(0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                
                  tryLoad(
                    'assets/logo/ISRO.png',
                    width: 110,
                    height: 110,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "VSAT Saarthi",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Smart VSAT Companion",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFFE5E5E5),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFFCA311),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}