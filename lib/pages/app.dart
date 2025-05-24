import 'package:allycall/pages/fake_call_page.dart';
import 'package:allycall/pages/home_page.dart';
import 'package:allycall/pages/guide_page.dart';
import 'package:allycall/pages/map_page.dart';
import 'package:allycall/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:allycall/widgets/tab_bar.dart';
import 'package:allycall/state/global_flags.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int currentTabIndex = 0;
  String? selectedIngredient;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (GlobalFlags.isNewUser) {
        GlobalFlags.isNewUser = false; // reset
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                backgroundColor: Colors.white,
                title: Text(
                  'Welcome!',
                  style: GoogleFonts.livvic(fontWeight: FontWeight.w700),
                ),
                content: const Text('Your account was successfully created.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFFFAA6A8),
                    ),
                    child: const Text('Continue'),
                  ),
                ],
              ),
        );
      }
    });
  }

  Color getBackgroundColor() {
    switch (currentTabIndex) {
      case 0:
        return Colors.white;
      case 1:
        return const Color(0xFFF4F7F5);
      case 2:
        return const Color(0xFFF9F5F2);
      default:
        return Colors.white;
    }
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: getBackgroundColor(),
      body: TabBarView(
        controller: _tabController,
        children: [
          HomePage(tabController: _tabController,),
          MapPage(),
          FakeCallPage(),
          GuidePage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: CustomTabBar(tabController: _tabController),
    );
  }
}
