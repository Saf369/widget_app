import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/lecture_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'screens/upload_timetable_screen.dart';
import 'screens/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.unknown},
      ),
      home: const AppShell(),
    );
  }
}

enum AppState { login, upload, loading, home }

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  static AppShellState? of(BuildContext context) {
    return context.findAncestorStateOfType<AppShellState>();
  }

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  AppState _appState = AppState.login;

  void goToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
        onLogin: () => setState(() => _appState = AppState.upload),
      );
    }

    if (_appState == AppState.upload) {
      return UploadTimetableScreen(
        key: const ValueKey('app_upload_screen'),
        onUpload: () => setState(() => _appState = AppState.loading),
        onSkip: () => setState(() => _appState = AppState.loading),
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
      extendBody: true, // Keeping this just in case they have SafeArea elsewhere
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
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _BottomNavBar(
                  selectedIndex: _selectedIndex,
                  onTap: (i) => setState(() => _selectedIndex = i),
                ),
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
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.45), // Reduced opacity for more transparency
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 1.0,
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
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    width: isActive ? 64 : 44,
                    height: isActive ? 44 : 44,
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF0B0B0D) : Colors.white.withOpacity(0.25), // Distinct transparency for the icon circle
                      borderRadius: BorderRadius.circular(25),
                      border: isActive
                          ? null
                          : Border.all(
                              color: Colors.white, // Crisp white outline
                              width: 1.0,
                            ),
                    ),
                    child: Center(
                      child: AnimatedTheme(
                        data: Theme.of(context).copyWith(
                          iconTheme: IconThemeData(
                            color: isActive ? Colors.white : const Color(0xFF1A1A1F),
                            size: 20,
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
