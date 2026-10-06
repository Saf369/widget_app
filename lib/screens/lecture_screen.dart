import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class LectureScreen extends StatelessWidget {
  const LectureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD8D0E8), Color(0xFFC8BEDC)],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Sphere Pink
          Positioned(
            right: -10,
            top: -70,
            child: Container(
              width: 190,
              height: 190,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFFE48FA6), Color(0xFFA2506F)],
                ),
              ),
            ),
          ),
          // Sphere Violet
          Positioned(
            right: 0,
            top: 215,
            child: Container(
              width: 125,
              height: 125,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFFB56FDC), Color(0xFF5E2E8A)],
                ),
              ),
            ),
          ),
          // Sphere Small
          Positioned(
            right: 43,
            top: 185,
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0xFFC58AE0), Color(0xFF7A44A8)],
                ),
              ),
            ),
          ),
          // Cage rectangles (gradient overlays)
          Positioned(
            right: -30,
            top: -20,
            child: Container(
              width: 100,
              height: 245,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF6F6F8), Color(0xFF9C9CAA)],
                ),
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
          // SafeArea content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      // Back placeholder
                      const SizedBox(width: 54, height: 54),
                      const Spacer(),
                      // Share
                      _GlassButton(
                        child: const Icon(Icons.share_outlined,
                            color: Color(0xFF141414), size: 20),
                      ),
                      const SizedBox(width: 8),
                      // More
                      _GlassButton(
                        child: _ThreeDots(color: const Color(0xFF141414)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                // Lecture label
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Lecture',
                    style: GoogleFonts.urbanist(
                        fontSize: 19,
                        color: const Color(0xFF5F5878)),
                  ),
                ),
                const SizedBox(height: 4),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 29),
                  child: Text(
                    'Spatial\nAptitude',
                    style: GoogleFonts.urbanist(
                      fontSize: 50,
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                      letterSpacing: -1.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: const [
                      _Tab(label: 'Literature', isActive: false),
                      SizedBox(width: 3),
                      _Tab(label: 'Videos', isActive: true),
                      SizedBox(width: 3),
                      _Tab(label: 'Audio', isActive: false, textColor: Color(0xFF6B4FA3)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Lesson list
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: const Color(0xBFD3CBE4),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(34),
                        topRight: Radius.circular(34),
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _LessonRow(
                            title: 'Perspective Basics',
                            subtitle: 'How depth and distance are repr...',
                            duration: '23:28',
                          ),
                          const SizedBox(height: 4),
                          _LessonRow(
                            title: 'Mental Folding Exercises',
                            subtitle: 'Train your ability to imagine folde...',
                            duration: '15:48',
                          ),
                          const SizedBox(height: 4),
                          _LessonRow(
                            title: 'Spatial Logic in Design',
                            subtitle: 'Connecting geometry, structure...',
                            duration: '12:16',
                          ),
                          const SizedBox(height: 4),
                          _LessonRow(
                            title: 'Design Theory',
                            subtitle: 'Connecting geometry, structure...',
                            duration: '15:25',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Progress Card
                Container(
                  height: 172,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x244D4073),
                        blurRadius: 18,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Decorative arcs
                      Positioned(
                        right: -25,
                        bottom: -5,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFFE7C9D2), width: 1),
                          ),
                        ),
                      ),
                      // Figure (simple illustration)
                      Positioned(
                        left: 58,
                        top: 24,
                        child: Container(
                          width: 48,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1CDB4),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 48,
                        top: 8,
                        child: Container(
                          width: 70,
                          height: 86,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8A4B2B),
                            borderRadius: BorderRadius.circular(35),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        top: 95,
                        child: Container(
                          width: 165,
                          height: 130,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B6A45),
                            borderRadius: BorderRadius.circular(80),
                          ),
                        ),
                      ),
                      // Progress info
                      Positioned(
                        right: 50,
                        top: 36,
                        child: Text('Your progress',
                            style: GoogleFonts.urbanist(
                                fontSize: 13,
                                color: const Color(0xFF5F5878))),
                      ),
                      Positioned(
                        right: 40,
                        top: 52,
                        child: Text('72%',
                            style: GoogleFonts.urbanist(
                              fontSize: 64,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -1.92,
                              color: const Color(0xFF141414),
                            )),
                      ),
                      Positioned(
                        right: 20,
                        top: 128,
                        child: SizedBox(
                          width: 123,
                          child: Text(
                            'Of the topic has been\nsuccessfully covered.',
                            style: GoogleFonts.urbanist(
                              fontSize: 13,
                              height: 18 / 13,
                              color: const Color(0xFF6C6580),
                            ),
                          ),
                        ),
                      ),
                      // Badge
                      Positioned(
                        right: 16,
                        top: 16,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFFD9D3E4), width: 1),
                          ),
                          child: Center(
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFF1A1A1A).withOpacity(0.7),
                                    width: 1.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Coming Soon Overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Coming Soon Banner
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Transform.rotate(
                  angle: -1.1,
                  child: OverflowBox(
                    maxWidth: 2000,
                    minWidth: 2000,
                    child: Container(
                      height: 52,
                      color: const Color(0xFF0E0E10),
                      alignment: Alignment.center,
                      child: Text(
                        'COMING SOON  •  LECTURES  •  COMING SOON  •  LECTURES  •  COMING SOON  •  LECTURES  •  COMING SOON  •  LECTURES  •  COMING SOON',
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          letterSpacing: 6,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                        softWrap: false,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Unblurred Back Button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: GestureDetector(
                  onTap: () {
                    AppShell.of(context)?.goToTab(0);
                  },
                  child: const _GlassButton(
                    child: Text('←',
                        style: TextStyle(fontSize: 22, color: Color(0xFF141414))),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final Widget child;
  const _GlassButton({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
      ),
      child: Center(child: child),
    );
  }
}

class _ThreeDots extends StatelessWidget {
  final Color color;
  const _ThreeDots({required this.color});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (i) => Container(
          width: 5,
          height: 5,
          margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color? textColor;
  const _Tab({required this.label, required this.isActive, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF0E0E10)
            : Colors.white.withOpacity(0.28),
        borderRadius: BorderRadius.circular(21),
        border: isActive
            ? null
            : Border.all(color: Colors.white.withOpacity(0.7), width: 1),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 15,
            color: isActive
                ? Colors.white
                : (textColor ?? const Color(0xFF1A1A1A).withOpacity(0.7)),
          ),
        ),
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;
  const _LessonRow({required this.title, required this.subtitle, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 66,
      decoration: BoxDecoration(
        color: const Color(0xD9C8BFE0),
        borderRadius: BorderRadius.circular(33),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
      ),
      child: Stack(
        children: [
          // Play circle bg
          Positioned(
            left: 4,
            top: 4,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFB9AED3),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withOpacity(0.5), width: 1),
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 24),
            ),
          ),
          // Title
          Positioned(
            left: 74,
            top: 13,
            right: 70,
            child: Text(title,
                style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
          ),
          // Subtitle
          Positioned(
            left: 74,
            top: 36,
            right: 70,
            child: Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.urbanist(
                  fontSize: 12, color: const Color(0xFF5A4E80)),
            ),
          ),
          // Duration
          Positioned(
            right: 14,
            top: 24,
            child: Text(duration,
                style: GoogleFonts.urbanist(
                    fontSize: 15, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
