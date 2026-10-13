import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/lecture_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'screens/upload_timetable_screen.dart';
import 'screens/loading_screen.dart';
import 'models/schedule.dart';
import 'package:home_widget/home_widget.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';

@pragma("vm:entry-point")
Future<void> backgroundCallback(Uri? uri) async {
  // If we ever need to fetch data in the background, we can do it here.
  // For tab clicks, we now handle them 100% natively for instant speed!
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    HomeWidget.registerInteractivityCallback(backgroundCallback);
  }

  await loadSavedTimetable();
  
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    if (options != null) {
      await Firebase.initializeApp(options: options);
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
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

enum AppState { upload, loading, home }

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
  late final Stream<User?> _authStream = AuthService().authStateChanges;
  AppState _appState = hasUserUploadedTimetable ? AppState.home : AppState.upload;
  String? _checkedUid;
  bool _isCheckingCloud = false;

  static const List<Widget> _screens = [
    HomeScreen(),
    ScheduleScreen(),
    LectureScreen(),
    AiChatScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _updateNativeWidget();
  }

  void _checkUserTimetable(String uid) {
    if (_checkedUid == uid || _isCheckingCloud) return;
    _checkedUid = uid;
    _isCheckingCloud = true;

    ApiService.getTimetable().then((cloudEntries) {
      if (!mounted) return;
      if (cloudEntries != null && cloudEntries.isNotEmpty) {
        // User already has timetable saved in Firestore
        updateGlobalTimetable(cloudEntries);
        setState(() {
          _appState = AppState.home;
          _isCheckingCloud = false;
        });
      } else if (hasUserUploadedTimetable && globalTimetable.isNotEmpty) {
        // User has local uploaded timetable
        setState(() {
          _appState = AppState.home;
          _isCheckingCloud = false;
        });
      } else {
        // New user! Needs to upload timetable
        setState(() {
          _appState = AppState.upload;
          _isCheckingCloud = false;
        });
      }
    }).catchError((err) {
      debugPrint('Cloud timetable check: $err');
      if (!mounted) return;
      setState(() {
        _appState = hasUserUploadedTimetable ? AppState.home : AppState.upload;
        _isCheckingCloud = false;
      });
    });
  }

  Future<void> _updateNativeWidget() async {
    if (kIsWeb) return;
    try {
      final currentTab = await HomeWidget.getWidgetData<String>('active_tab');
      if (currentTab == null) {
        await HomeWidget.saveWidgetData<String>('active_tab', 'day');
      }
      await HomeWidget.updateWidget(
        name: 'TimetableGlanceWidgetReceiver',
        qualifiedAndroidName: 'com.example.frontend.TimetableGlanceWidgetReceiver',
      );
    } catch (e) {
      debugPrint('Error updating widget: $e');
    }
  }

  void goToTab(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        // Still initializing Firebase Auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFECE8F4),
            body: SizedBox.expand(),
          );
        }

        // Not signed in — auth middleware gate
        if (!snapshot.hasData || snapshot.data == null) {
          _checkedUid = null;
          _isCheckingCloud = false;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: LoginScreen(
              key: const ValueKey('app_login_screen'),
              onLogin: () {},
            ),
          );
        }

        // Signed in — check timetable for this user
        final user = snapshot.data!;
        if (_checkedUid != user.uid) {
          _checkUserTimetable(user.uid);
        }

        // Signed in — show the authenticated app
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
      },
    );
  }

  Widget _buildAppStateWidget() {
    if (_appState == AppState.upload) {
      return UploadTimetableScreen(
        key: const ValueKey('app_upload_screen'),
        onUpload: () => setState(() => _appState = AppState.loading),
        onSkip: () => setState(() => _appState = AppState.home),
      );
    }

    if (_appState == AppState.loading) {
      return LoadingScreen(
        key: const ValueKey('app_loading_screen'),
        onComplete: () => setState(() => _appState = AppState.home),
      );
    }

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedIndex != 0) {
          goToTab(0);
        }
      },
      child: Scaffold(
        key: const ValueKey('app_home_scaffold'),
        backgroundColor: const Color(0xFFF3F0EE),
        extendBody: true,
        body: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: _screens,
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.45),
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
                    // Smooth sliding black pill indicator
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      left: selectedIndex * itemWidth,
                      top: 0,
                      bottom: 0,
                      width: itemWidth,
                      child: Center(
                        child: Container(
                          width: 54,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B0B0D),
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                      ),
                    ),
                    // Equal width touch targets
                    Row(
                      children: List.generate(items.length, (i) {
                        final isActive = selectedIndex == i;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => onTap(i),
                            behavior: HitTestBehavior.opaque,
                            child: SizedBox(
                              height: 44,
                              child: Center(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.easeOutCubic,
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.transparent
                                        : Colors.white.withOpacity(0.25),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isActive
                                          ? Colors.transparent
                                          : Colors.white.withOpacity(0.8),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      items[i],
                                      color: isActive
                                          ? Colors.white
                                          : const Color(0xFF1A1A1F),
                                      size: 20,
                                    ),
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
