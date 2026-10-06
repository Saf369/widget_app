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

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  bool _showLogin = true;

  final List<Widget> _screens = const [
    HomeScreen(),
    ScheduleScreen(),
    LectureScreen(),
    AiChatScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (_showLogin) {
      return LoginScreen(onLogin: () => setState(() => _showLogin = false));
    }

    return Scaffold(
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
      Icons.home_rounded,
      Icons.calendar_today_rounded,
      Icons.play_circle_outline_rounded,
      Icons.chat_bubble_outline_rounded,
      Icons.grid_view_rounded,
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: Colors.white.withOpacity(0.40),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E1B4B).withOpacity(0.08),
                blurRadius: 45,
                offset: const Offset(0, 20),
                spreadRadius: -12,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(items.length, (i) {
              final isActive = selectedIndex == i;
              
              return GestureDetector(
                onTap: () => onTap(i),
                child: Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 900),
                    curve: const Cubic(0.16, 1, 0.3, 1), // Ultra-fluid slow glide
                    width: isActive ? 68 : 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF111315)
                          : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isActive ? const Color(0xFF111315) : Colors.white.withOpacity(0.25),
                        width: 1,
                      ),
                      boxShadow: isActive
                          ? [
                              const BoxShadow(
                                color: Color(0x52111315), // 0.32 opacity
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Icon(
                        items[i],
                        color: isActive ? Colors.white : const Color(0xFF334155),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
