import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'look_up_angle_screen.dart';
import 'loss_calculator_screen.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = "";
  String userEmail = "";
  String userImage = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;
    setState(() {
      userName = prefs.getString('name') ?? "VSAT User";
      userEmail = prefs.getString('email') ?? "user@vsat.com";
      userImage = prefs.getString('image') ?? "";
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    try {
      await GoogleSignIn().signOut();
    } catch (_) {}

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05060A),

      // ✅ ✅ ✅ UPDATED APP BAR WITH LOGO
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1122),
        elevation: 6,
        shadowColor: Colors.black45,
        title: Row(
          children: [
            Image.asset(
              'assets/logo/logo_VSAT.png', // ✅ Correct Logo Path
              height: 30,
            ),
            const SizedBox(width: 10),
            const Text(
              "VSAT Saarthi",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),

      body: const _DashboardTabs(),
    );
  }
}

// ============================
// ✅ DASHBOARD TABS COMPONENT
// ============================

class _DashboardTabs extends StatefulWidget {
  const _DashboardTabs();

  @override
  State<_DashboardTabs> createState() => _DashboardTabsState();
}

class _DashboardTabsState extends State<_DashboardTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: const Color(0xFF0D1122),
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF3A4DF4),
            unselectedLabelColor: Colors.white60,
            indicatorColor: const Color(0xFF3A4DF4),
            indicatorWeight: 3,
            tabs: const [
              Tab(text: "Look Up Angle"),
              Tab(text: "Loss Calculator"),
            ],
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              LookUpAngleScreen(),
              LossCalculatorScreen(),
            ],
          ),
        ),
      ],
    );
  }
}