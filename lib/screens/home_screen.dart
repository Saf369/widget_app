import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDCD5E6), Color(0xFFF3F0EE), Color(0xFFEEEBE8)],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.all(Radius.circular(44)),
      ),
      child: Stack(
        children: [
          // Background blur ellipses
          Positioned(
            right: -105,
            top: -170,
            child: Container(
              width: 330,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFA8A2B2).withOpacity(0.26),
              ),
            ),
          ),
          Positioned(
            right: -80,
            top: 40,
            child: Container(
              width: 200,
              height: 420,
              decoration: BoxDecoration(
                color: const Color(0xFFBDB8C4).withOpacity(0.14),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB9C2C7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 28),
                        ),
                        const Spacer(),
                        // Search
                        _GlassIconButton(icon: Icons.search_rounded),
                        const SizedBox(width: 8),
                        // More
                        _GlassIconButton(child: _ThreeDots(color: const Color(0xFF1A1A1A))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Greeting
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Text(
                      'Hello, Anna',
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF5B5B60),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Text(
                      'Your Custom\nSyllabus',
                      style: GoogleFonts.urbanist(
                        fontSize: 48,
                        fontWeight: FontWeight.w400,
                        height: 50 / 48,
                        letterSpacing: -0.96,
                        color: const Color(0xFF141414),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Filter row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      children: [
                        // Filter button
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _FilterLine(width: 14),
                              const SizedBox(height: 4),
                              _FilterLine(width: 10),
                              const SizedBox(height: 4),
                              _FilterLine(width: 6),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        // Chips
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: const [
                                _Chip(label: 'Architecture'),
                                SizedBox(width: 8),
                                _Chip(label: 'Housing Design'),
                                SizedBox(width: 8),
                                _Chip(label: 'Building Tech'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Spatial Aptitude Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: _SpatialAptitudeCard(),
                  ),
                  const SizedBox(height: 16),
                  // Engineering Graphics Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: _CourseRow(
                      color: const Color(0xFFE8CACF),
                      iconColor: const Color(0xFFDDA9AF),
                      title: 'Engineering Graphics',
                      subtitle: 'Application of spatial reasoning to visualize mechanical parts',
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Visual Communication Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: _CourseRow(
                      color: const Color(0xFFCDE6E2),
                      iconColor: const Color(0xFFB5D8D4),
                      title: 'Visual Communication',
                      subtitle: 'Sketching, rendering and presenting design ideas to clients',
                      faded: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Placeholder next row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Container(
                      height: 62,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6E1EE),
                        borderRadius: BorderRadius.circular(31),
                      ),
                    ),
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

class _FilterLine extends StatelessWidget {
  final double width;
  const _FilterLine({required this.width});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 1.6,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  const _GlassIconButton({this.icon, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
      ),
      child: Center(
        child: child ??
            Icon(icon, color: const Color(0xFF1A1A1A), size: 22),
      ),
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

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFF7A7A80).withOpacity(0.55),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(width: 8),
          Text('×',
              style: GoogleFonts.urbanist(
                  fontSize: 17, color: const Color(0xFF6B6B70))),
        ],
      ),
    );
  }
}

class _SpatialAptitudeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 272,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFCBBFDD), Color(0xFFC4B8D8)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Header section
          Positioned(
            left: 24,
            top: 22,
            child: Text(
              'Spatial Aptitude',
              style: GoogleFonts.urbanist(
                fontSize: 26,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 62,
            right: 60,
            child: Text(
              'Visualization, transformation, and analysis\nof shapes in space.',
              style: GoogleFonts.urbanist(
                fontSize: 15,
                height: 20 / 15,
                color: const Color(0xFF5A4E80),
              ),
            ),
          ),
          // More button
          Positioned(
            right: 13,
            top: 13,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.7), width: 1),
              ),
              child: Center(child: _ThreeDots(color: const Color(0xFF3A3A44))),
            ),
          ),
          // Stats panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 159,
              decoration: const BoxDecoration(
                color: Color(0xFFD8D0E5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  // Art gradient SVG placeholder
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 185,
                      height: 159,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          transform: GradientRotation(127 * 3.14159 / 180),
                          colors: [
                            Color(0xFF9C4F63),
                            Color(0xFF7B4AA8),
                            Color(0xFF9A5BB8),
                          ],
                          stops: [0.0, 0.38, 0.74],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.auto_stories_rounded,
                            color: Colors.white54, size: 64),
                      ),
                    ),
                  ),
                  // Divider vertical
                  Positioned(
                    left: 81,
                    top: 0,
                    child: Container(width: 1, height: 103, color: Colors.white.withOpacity(0.6)),
                  ),
                  // Divider horizontal
                  Positioned(
                    left: 0,
                    top: 103,
                    child: Container(width: 120, height: 1, color: Colors.white.withOpacity(0.5)),
                  ),
                  // Pages label
                  Positioned(
                    left: 24,
                    top: 17,
                    child: Text('Pages',
                        style: GoogleFonts.urbanist(
                            fontSize: 13, color: const Color(0xFF5A4E80))),
                  ),
                  // Pages count
                  Positioned(
                    left: 24,
                    top: 34,
                    child: Text('24',
                        style: GoogleFonts.urbanist(
                            fontSize: 40,
                            fontWeight: FontWeight.w400,
                            color: Colors.white)),
                  ),
                  // Videos label
                  Positioned(
                    left: 98,
                    top: 76,
                    child: Text('Videos',
                        style: GoogleFonts.urbanist(
                            fontSize: 13, color: const Color(0xFF5A4E80))),
                  ),
                  // Videos count
                  Positioned(
                    left: 98,
                    top: 93,
                    child: Text('10',
                        style: GoogleFonts.urbanist(
                            fontSize: 40,
                            fontWeight: FontWeight.w400,
                            color: Colors.white)),
                  ),
                  // Clock icon
                  Positioned(
                    left: 24,
                    top: 110,
                    child: const Icon(Icons.access_time_rounded,
                        size: 16, color: Color(0xFF5A4E80)),
                  ),
                  // Duration
                  Positioned(
                    left: 22,
                    top: 131,
                    child: Text('1.5 Hour',
                        style: GoogleFonts.urbanist(
                            fontSize: 12, color: const Color(0xFF5A4E80))),
                  ),
                  // Open button
                  Positioned(
                    right: 15,
                    bottom: 15,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16161A),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('↗',
                            style: GoogleFonts.urbanist(
                                fontSize: 18, color: Colors.white)),
                      ),
                    ),
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

class _CourseRow extends StatelessWidget {
  final Color color;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool faded;
  const _CourseRow({
    required this.color,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.faded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: faded ? 0.45 : 1.0,
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(31),
          border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
        ),
        child: Stack(
          children: [
            // Circle icon
            Positioned(
              left: 3,
              top: 3,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.brush_rounded, color: Colors.white, size: 24),
                ),
              ),
            ),
            // Title & subtitle
            Positioned(
              left: 66,
              top: 12,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.urbanist(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF141414))),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.urbanist(
                        fontSize: 12, color: const Color(0xFF6E5A62)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
