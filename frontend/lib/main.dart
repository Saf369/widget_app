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
import 'package:home_widget/home_widget.dart';
import 'widgets/home_widget_ui.dart';

@pragma("vm:entry-point")
Future<void> backgroundCallback(Uri? uri) async {
  // If we ever need to fetch data in the background, we can do it here.
  // For tab clicks, we now handle them 100% natively for instant speed!
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.registerInteractivityCallback(backgroundCallback);
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed (probably not configured for this platform yet): \$e');
  }

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
  int _previousIndex = 0;
  AppState _appState = AppState.login;

  @override
  void initState() {
    super.initState();
    _updateNativeWidget();
  }

  Future<void> _updateNativeWidget() async {
    try {
      final currentTab = await HomeWidget.getWidgetData<String>('active_tab');
      if (currentTab == null) {
        await HomeWidget.saveWidgetData<String>('active_tab', 'day');
      }
      await HomeWidget.updateWidget(name: 'TimetableWidgetProvider');
      await HomeWidget.updateWidget(name: 'TimetableGlanceWidgetReceiver');
    } catch (e) {
      debugPrint('Error updating widget: $e');
    }
  }

  void goToTab(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _previousIndex = _selectedIndex;
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
      backgroundColor: const Color(0xFFF3F0EE),
      extendBody: true,
      body: Stack(
        children: [
          Stack(
            children: List.generate(_screens.length, (index) {
              final isActive = index == _selectedIndex;
              
              Offset targetOffset;
              if (isActive) {
                targetOffset = Offset.zero;
              } else {
                targetOffset = const Offset(0.0, 0.08);
              }

              return IgnorePointer(
                ignoring: !isActive,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.fastOutSlowIn,
                  offset: targetOffset,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeIn,
                    opacity: isActive ? 1.0 : 0.0,
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: _screens[index],
                    ),
                  ),
                ),
              );
            }),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _BottomNavBar(
                  selectedIndex: _selectedIndex,
                  onTap: (i) => goToTab(i),
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / items.length;
                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      left: selectedIndex * itemWidth,
                      top: 0,
                      bottom: 0,
                      width: itemWidth,
                      child: Center(
                        child: Container(
                          width: 64,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B0B0D),
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(items.length, (i) {
                        final isActive = selectedIndex == i;
                        return GestureDetector(
                          onTap: () => onTap(i),
                          behavior: HitTestBehavior.opaque,
                          child: SizedBox(
                            width: itemWidth,
                            height: 44,
                            child: Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeOutCubic,
                                width: isActive ? 64 : 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.transparent : Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(25),
                                  border: isActive
                                      ? Border.all(color: Colors.transparent, width: 1.0)
                                      : Border.all(color: Colors.white, width: 1.0),
                                ),
                                child: Center(
                                  child: TweenAnimationBuilder<Color?>(
                                    tween: ColorTween(
                                      begin: const Color(0xFF1A1A1F),
                                      end: isActive ? Colors.white : const Color(0xFF1A1A1F),
                                    ),
                                    duration: const Duration(milliseconds: 350),
                                    builder: (context, color, _) {
                                      return Icon(items[i], color: color, size: 20);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
