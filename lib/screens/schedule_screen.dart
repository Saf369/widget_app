import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF7F6F2),
        borderRadius: BorderRadius.all(Radius.circular(44)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF7F6F2),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFE2E0D8),
                  width: 1.0,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month & Add button
                    Row(
                      children: [
                        Text(
                          'June, 2026',
                          style: GoogleFonts.urbanist(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF141414),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF141414), size: 22),
                        const Spacer(),
                        // Add button
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFFE2E0D8), width: 1.5),
                          ),
                          child: const Icon(Icons.add_rounded,
                              color: Color(0xFF141414), size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // View Mode row
                    Row(
                      children: [
                        Text(
                          'VIEW MODE',
                          style: GoogleFonts.urbanist(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: const Color(0xFF94949C),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9E8E3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              _ViewModeTab(label: 'Hour', isActive: false),
                              _ViewModeTab(label: 'Day', isActive: true),
                              _ViewModeTab(label: 'Week', isActive: false),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Week days
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: const [
                          _DayCell(day: 'Mon', date: '11', isActive: false),
                          _DayCell(day: 'Tue', date: '11', isActive: false),
                          _DayCell(day: 'Wed', date: '12', isActive: false),
                          _DayCell(day: 'Thu', date: '13', isActive: false),
                          _DayCell(day: 'Fri', date: '14', isActive: true),
                          _DayCell(day: 'Sat', date: '15', isActive: false),
                          _DayCell(day: 'Sun', date: '16', isActive: false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Schedule body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
              children: [
                // 10 AM - Theory Test
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _TimeLabel(label: '10', suffix: 'AM'),
                    const SizedBox(width: 16),
                    Expanded(child: _TheoryTestCard()),
                  ],
                ),
                const SizedBox(height: 24),
                
                // 11 AM - Free Time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _TimeLabel(label: '11', suffix: 'AM'),
                    const SizedBox(width: 16),
                    Expanded(child: _FreeTimeCard()),
                  ],
                ),
                const SizedBox(height: 24),
                
                // 13 AM - Design Test
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _TimeLabel(label: '13', suffix: 'AM'),
                    const SizedBox(width: 16),
                    Expanded(child: _DesignTestCard()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewModeTab extends StatelessWidget {
  final String label;
  final bool isActive;
  const _ViewModeTab({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF141414) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: GoogleFonts.urbanist(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : const Color(0xFF5F5F64),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final String day;
  final String date;
  final bool isActive;
  const _DayCell({required this.day, required this.date, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF141414) : const Color(0xFFEFEFEA),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: GoogleFonts.urbanist(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : const Color(0xFF7A7A80),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date,
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : const Color(0xFF141414),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  final String label;
  final String suffix;
  const _TimeLabel({required this.label, required this.suffix});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.urbanist(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF202020))),
          Text(suffix,
              style: GoogleFonts.urbanist(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: const Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}

class _TheoryTestCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: const Color(0xFFD7A1A7), // Matches HTML roseCard
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          // Title
          Positioned(
            left: 16,
            top: 20,
            child: Text('Theory Test',
                style: GoogleFonts.urbanist(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A))),
          ),
          // Subtitle
          Positioned(
            left: 16,
            top: 54,
            right: 16,
            child: Text(
              'Covers main ideas and principles from the\nDesign Theory topic.',
              style: GoogleFonts.urbanist(
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4A3A40)),
            ),
          ),
          // More button
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFC48692),
                shape: BoxShape.circle,
              ),
              child: Center(child: _ThreeDots(color: const Color(0xFF1A1A1A))),
            ),
          ),
          // Stats panel
          Positioned(
            left: 4,
            top: 104,
            right: 4,
            bottom: 4,
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
              ),
              child: Stack(
                children: [
                  // Decorative arcs
                  Positioned(
                    right: -20,
                    top: 0,
                    child: _Arc(size: 150, color: const Color(0xFF8A5A60).withOpacity(0.25)),
                  ),
                  Positioned(
                    right: -50,
                    top: -40,
                    child: _Arc(size: 180, color: const Color(0xFF8A5A60).withOpacity(0.2)),
                  ),
                  // Divider
                  Positioned(
                    left: 140,
                    top: 16,
                    bottom: 16,
                    child: Container(
                        width: 1,
                        color: const Color(0xFFC48692)),
                  ),
                  // Room
                  Positioned(
                    left: 16,
                    top: 16,
                    child: Text('Room',
                        style: GoogleFonts.urbanist(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4A3A40))),
                  ),
                  Positioned(
                    left: 16,
                    top: 36,
                    child: Text('244',
                        style: GoogleFonts.urbanist(
                            fontSize: 32, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A))),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 20,
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 14, color: Color(0xFF4A3A40)),
                        const SizedBox(width: 4),
                        Text('1 Hour',
                            style: GoogleFonts.urbanist(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4A3A40))),
                      ],
                    ),
                  ),
                  // Points
                  Positioned(
                    left: 156,
                    top: 16,
                    child: Text('Points',
                        style: GoogleFonts.urbanist(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4A3A40))),
                  ),
                  Positioned(
                    left: 156,
                    top: 36,
                    child: Text('40',
                        style: GoogleFonts.urbanist(
                            fontSize: 32, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A))),
                  ),
                  // Avatar (person circle)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8943A),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: Colors.white, size: 18),
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

class _FreeTimeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F6F0), // Matches HTML lightFreeCard
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFECE7DC), width: 1.0),
      ),
      child: Stack(
        children: [
          // Decorative arcs
          Positioned(
            left: -48,
            top: 28,
            child: _Arc(size: 120, color: const Color(0xFFB9A8D8)),
          ),
          Positioned(
            right: 20,
            top: -20,
            child: _Arc(size: 120, color: const Color(0xFF9FD4C8)),
          ),
          Positioned(
            right: -20,
            top: 40,
            child: _Arc(size: 130, color: const Color(0xFFE3A9A9)),
          ),
          // Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 2),
                Text('You Have 2 hours',
                    style: GoogleFonts.urbanist(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5F5F64))),
                Text('Free Time',
                    style: GoogleFonts.urbanist(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF141414))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Arc extends StatelessWidget {
  final double size;
  final Color color;
  const _Arc({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.2),
      ),
    );
  }
}

class _DesignTestCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFC4B9DC), // Matches HTML lavenderCard
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 20,
            child: Text('Design Test',
                style: GoogleFonts.urbanist(
                    fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFF16121C))),
          ),
          Positioned(
            left: 16,
            top: 54,
            child: Text('Room 244  •  1:00 – 2:00 PM',
                style: GoogleFonts.urbanist(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5A4E80))),
          ),
          // More button
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFA690C5),
                shape: BoxShape.circle,
              ),
              child: Center(child: _ThreeDots(color: const Color(0xFF16121C))),
            ),
          ),
          // Inner Pill
          Positioned(
            left: 4,
            top: 96,
            right: 4,
            bottom: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(38),
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('244',
                        style: GoogleFonts.urbanist(
                            fontSize: 36, fontWeight: FontWeight.w700, color: const Color(0xFF16121C))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text('1 Hour',
                          style: GoogleFonts.urbanist(
                              fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF16121C))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
          width: 4,
          height: 4,
          margin: EdgeInsets.only(right: i < 2 ? 3 : 0),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
