import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/lecture_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'screens/loading_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const CustomSyllabusApp());
}

class CustomSyllabusApp extends StatelessWidget {
  const CustomSyllabusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Syllabus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.urbanistTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5A4E80)),
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}

enum AppState { login, loading, home }

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  AppState _appState = AppState.login;

  final List<Widget> _screens = const [
    HomeScreen(),
    ScheduleScreen(),
    LectureScreen(),
    AiChatScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: _buildAppStateWidget(),
    );
  }

  Widget _buildAppStateWidget() {
    if (_appState == AppState.login) {
      return LoginScreen(
        key: const ValueKey('app_login_screen'),
        onLogin: () => setState(() => _appState = AppState.loading),
      );
    }

    if (_appState == AppState.loading) {
      return LoadingScreen(
        key: const ValueKey('app_loading_screen'),
        onComplete: () => setState(() => _appState = AppState.home),
      );
    }

    return Scaffold(
      key: const ValueKey('app_home_scaffold'),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeOutQuint,
            switchOutCurve: Curves.easeInQuint,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04), // Gentle slide up
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: SizedBox(
              key: ValueKey<int>(_selectedIndex),
              width: double.infinity,
              height: double.infinity,
              child: _screens[_selectedIndex],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _BottomNavBar(
                selectedIndex: _selectedIndex,
                onTap: (i) => setState(() => _selectedIndex = i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      Icons.home_outlined,
      Icons.calendar_today_outlined,
      Icons.play_circle_outline_rounded,
      Icons.chat_bubble_outline_rounded,
      Icons.grid_view_outlined,
    ];

    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      height: 72,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF766694).withOpacity(0.12),
            blurRadius: 32,
            offset: const Offset(0, 16),
            spreadRadius: -8,
          ),
          BoxShadow(
            color: const Color(0xFF111315).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: Colors.white.withOpacity(0.95),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(items.length, (i) {
                final isActive = selectedIndex == i;
                return GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    width: isActive ? 100 : 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF101114) : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                      border: isActive
                          ? null
                          : Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                    ),
                    child: Center(
                      child: AnimatedTheme(
                        data: Theme.of(context).copyWith(
                          iconTheme: IconThemeData(
                            color: isActive ? Colors.white : const Color(0xFF101114),
                            size: 24,
                          ),
                        ),
                        child: Icon(items[i]),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
