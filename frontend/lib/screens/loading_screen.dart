import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/four_point_star.dart';

class LoadingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  
  const LoadingScreen({super.key, required this.onComplete});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with TickerProviderStateMixin {
  int _progress = 60;
  bool _isCompleted = false;
  late Timer _timer;
  
  // Animation controllers for ripples
  late AnimationController _rippleController;
  late AnimationController _ambientController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    
    // Ripple animation
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Ambient floating animation
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    
    // Pulse animation for amber dot
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Progress simulation
    _timer = Timer.periodic(const Duration(milliseconds: 70), (timer) {
      if (!mounted) return;
      if (_progress < 100) {
        setState(() {
          _progress += 1;
        });
      } else {
        timer.cancel();
        _onLoadComplete();
      }
    });
  }

  void _onLoadComplete() {
    if (!mounted) return;
    setState(() {
      _isCompleted = true;
    });
    
    // Wait for completion state to show, then trigger callback
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  void _triggerCompletion() {
    if (_isCompleted) return;
    _timer.cancel();
    setState(() {
      _progress = 100;
    });
    _onLoadComplete();
  }

  @override
  void dispose() {
    _timer.cancel();
    _rippleController.dispose();
    _ambientController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildRippleRing(double delayDelay) {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        // Offset the progress for different rings
        double progress = (_rippleController.value + delayDelay) % 1.0;
        
        // Scale from 0.3 to 2.6 as per HTML spec
        double scale = 0.3 + (progress * 2.3);
        
        // Opacity: starts at 0.85, dips to 0.6 at half, 0 at end
        double opacity = 1.0;
        if (progress < 0.5) {
          opacity = 0.85 - ((progress / 0.5) * 0.25);
        } else {
          opacity = 0.6 * (1.0 - ((progress - 0.5) / 0.5));
        }

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.75), width: 1),
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.06),
                    const Color(0xFFE6E1F5).withOpacity(0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.4, 0.75, 1.0],
                ),
                boxShadow: [
                  BoxShadow(color: Colors.white.withOpacity(0.4), blurRadius: 14),
                  BoxShadow(color: Colors.white.withOpacity(0.25), blurRadius: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFFECE8F4), // Main bg from HTML
      body: Stack(
        children: [
          // Top ambient blur
          Positioned(
            top: -size.height * 0.15,
            left: -size.width * 0.15,
            width: size.width * 1.3,
            height: size.height * 0.6,
            child: Opacity(
              opacity: 0.9,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE7E2F2), Color(0xFFE4DEEE), Color(0xFFE9E4F4)],
                  ),
                ),
              ),
            ),
          ),
          
          // Bottom lilac tint
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.1,
            width: size.width * 1.2,
            height: size.height * 0.5,
            child: Opacity(
              opacity: 0.8,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xFFDED6EB), Color(0xFFE7E0F1), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          
          // Subtle warm pink blush
          AnimatedBuilder(
            animation: _ambientController,
            builder: (context, child) {
              return Positioned(
                top: size.height * 0.42 + (_ambientController.value * -12),
                right: -size.width * 0.15 + (_ambientController.value * 8),
                width: 260,
                height: 340,
                child: Opacity(
                  opacity: 0.6,
                  child: Transform.scale(
                    scale: 1.0 + (_ambientController.value * 0.08),
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 64, sigmaY: 64),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [Color(0xFFFCE8E6), Color(0xFFF6DEE2), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          ),
          
          // Top subtle highlight
          Positioned(
            top: size.height * 0.18,
            left: size.width * 0.20,
            width: 200,
            height: 200,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ),
          ),

          // Central Ripple & Disc System
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                SizedBox(
                  width: 340,
                  height: 340,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Static Concentric Guides
                      Container(
                        width: 310, height: 310,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                        ),
                      ),
                      // Accent sparkle star on the outer guide ring
                      Transform.translate(
                        offset: const Offset(127.0, -88.9),
                        child: const FourPointStar(
                          size: 15,
                          hasGlow: true,
                        ),
                      ),
                      Container(
                        width: 220, height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
                          boxShadow: [
                            BoxShadow(color: Colors.white.withOpacity(0.4), blurRadius: 20)
                          ]
                        ),
                      ),
                      Container(
                        width: 160, height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                        ),
                      ),
                      
                      // Dynamic Ripples
                      _buildRippleRing(0.0),
                      _buildRippleRing(0.33),
                      _buildRippleRing(0.66),
                      
                      // Central Disc
                      AnimatedBuilder(
                        animation: _ambientController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, -6 * _ambientController.value),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glow
                                ImageFiltered(
                                  imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                  child: Container(
                                    width: 112, height: 112,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF3B0764).withOpacity(0.2), // purple-950/20
                                    ),
                                  ),
                                ),
                                // Black Button
                                GestureDetector(
                                  onTap: _triggerCompletion,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: _isCompleted ? 108 : 102,
                                    height: _isCompleted ? 108 : 102,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF111315),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF4E3878).withOpacity(0.28 + (_ambientController.value * 0.07)),
                                          blurRadius: 36 + (_ambientController.value * 8),
                                          offset: const Offset(0, 16),
                                          spreadRadius: -8
                                        ),
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.4 + (_ambientController.value * 0.2)),
                                          blurRadius: 20 + (_ambientController.value * 8),
                                          spreadRadius: 2 + (_ambientController.value * 2)
                                        ),
                                      ]
                                    ),
                                    child: const Center(
                                      child: FourPointStar(
                                        size: 40,
                                        hasGlow: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Typography & Progress
                Text(
                  "Welcome to",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15, color: const Color(0xFF504A59), fontWeight: FontWeight.normal
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Custom Syllabus",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 33, color: const Color(0xFF111315), fontWeight: FontWeight.w600, letterSpacing: -0.5
                  ),
                ),
                const SizedBox(height: 32),
                
                // Progress Bar
                Container(
                  width: 172,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7D0E2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 172 * (_progress / 100),
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF111315),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Status Text
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isCompleted ? "Courses compiled! " : "Preparing your courses... ",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, color: const Color(0xFF655E71), fontWeight: FontWeight.w500
                      ),
                    ),
                    Text(
                      "$_progress%",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, color: const Color(0xFF544E60), fontWeight: FontWeight.w600
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                
                // Glass Status Pill
                GestureDetector(
                  onTap: _triggerCompletion,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.82),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF5F4E87).withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isCompleted ? Colors.green : const Color(0xFFE57E24),
                                    boxShadow: _isCompleted ? [] : [
                                      BoxShadow(
                                        color: const Color(0xFFE57E24).withOpacity(0.7 * (1.0 - _pulseController.value)),
                                        spreadRadius: _pulseController.value * 5,
                                      )
                                    ]
                                  ),
                                );
                              }
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _isCompleted ? "Setup complete" : "Syncing your timetable",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5, color: const Color(0xFF202226), fontWeight: FontWeight.w500
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }
}
