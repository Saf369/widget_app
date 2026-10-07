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
      child: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _ScheduleHeaderDelegate(),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
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
                
                // 1 PM - Design Test
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _TimeLabel(label: '1', suffix: 'PM'),
                    const SizedBox(width: 16),
                    Expanded(child: _DesignTestCard()),
                  ],
                ),
                const SizedBox(height: 24),
                
                // 3 PM - Studio Crit
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _TimeLabel(label: '3', suffix: 'PM'),
                    const SizedBox(width: 16),
                    Expanded(child: _StudioCritCard()),
                  ],
                ),
                const SizedBox(height: 24),
                
                // 4 PM - Lab Session
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _TimeLabel(label: '4', suffix: 'PM'),
                    const SizedBox(width: 16),
                    Expanded(child: _LabSessionCard()),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get maxExtent => 580.0;

  @override
  double get minExtent => 240.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = shrinkOffset / (maxExtent - minExtent);
    final percent = progress.clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        border: Border.all(color: const Color(0xFFF1F5F9).withOpacity(0.8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -15,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 1,
            spreadRadius: 1,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top fixed part
              _buildTopBar(context),
              
              const SizedBox(height: 28),
              
              // Animated calendar body
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Expanded Month View
                    if (percent < 1.0)
                      Opacity(
                        opacity: (1 - percent).clamp(0.0, 1.0),
                        child: IgnorePointer(
                          ignoring: percent > 0.0,
                          child: Transform.translate(
                            offset: Offset(0, -40 * percent),
                            child: OverflowBox(
                              alignment: Alignment.topCenter,
                              maxHeight: double.infinity,
                              child: const _ExpandedMonthCalendar(),
                            ),
                          ),
                        ),
                      ),
                    // Collapsed Week View
                    if (percent > 0.0)
                      Opacity(
                        opacity: percent.clamp(0.0, 1.0),
                        child: IgnorePointer(
                          ignoring: percent < 1.0,
                          child: Transform.translate(
                            offset: Offset(0, 40 * (1 - percent)),
                            child: OverflowBox(
                              alignment: Alignment.topCenter,
                              maxHeight: double.infinity,
                              child: _buildWeekRow(),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 16),
              
              // Bottom status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF111315),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Friday, June 14, 2026',
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF111315),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'SELECTED',
                    style: GoogleFonts.urbanist(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            Text(
              'June, 2026',
              style: GoogleFonts.urbanist(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF111315),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down,
                color: Color(0xFF111315), size: 28),
          ],
        ),
        const Spacer(),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            shape: BoxShape.circle,
            border: Border.all(
                color: const Color(0xFFECECED), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.add,
              color: Color(0xFF111315), size: 24),
        ),
      ],
    );
  }

  Widget _buildWeekRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        _DayCell(day: 'Mon', date: '10', isActive: false),
        _DayCell(day: 'Tue', date: '11', isActive: false),
        _DayCell(day: 'Wed', date: '12', isActive: false),
        _DayCell(day: 'Thu', date: '13', isActive: false),
        _DayCell(day: 'Fri', date: '14', isActive: true),
        _DayCell(day: 'Sat', date: '15', isActive: false),
        _DayCell(day: 'Sun', date: '16', isActive: false),
      ],
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
      width: 46,
      height: 56, // aspect 1/1.22
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF111315) : const Color(0xFFF2F3F4),
        borderRadius: BorderRadius.circular(26),
        boxShadow: isActive ? [
          BoxShadow(
            color: const Color(0xFF111315).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          )
        ] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: GoogleFonts.urbanist(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
              color: isActive ? Colors.white.withOpacity(0.9) : const Color(0xFF65696E),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date,
            style: GoogleFonts.urbanist(
              fontSize: 19,
              fontWeight: FontWeight.w400,
              height: 1.0,
              color: isActive ? Colors.white : const Color(0xFF111315),
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

class _ScheduleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color darkAccent;
  final Color lightAccent;
  final String room;
  final String points;
  final String duration;
  
  const _ScheduleCard({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.darkAccent,
    required this.lightAccent,
    required this.room,
    required this.points,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          // Title
          Positioned(
            left: 16,
            top: 20,
            child: Text(title,
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
              subtitle,
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
              decoration: BoxDecoration(
                color: lightAccent,
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
                    child: _Arc(size: 150, color: darkAccent.withOpacity(0.25)),
                  ),
                  Positioned(
                    right: -50,
                    top: -40,
                    child: _Arc(size: 180, color: darkAccent.withOpacity(0.2)),
                  ),
                  // Divider
                  Positioned(
                    left: 140,
                    top: 16,
                    bottom: 16,
                    child: Container(
                        width: 1,
                        color: lightAccent),
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
                    child: Text(room,
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
                        Text(duration,
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
                    child: Text(points,
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

class _TheoryTestCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _ScheduleCard(
      title: 'Theory Test',
      subtitle: 'Covers main ideas and principles from the\nDesign Theory topic.',
      backgroundColor: Color(0xFFD7A1A7), // roseCard
      darkAccent: Color(0xFF8A5A60),
      lightAccent: Color(0xFFC48692),
      room: '244',
      points: '40',
      duration: '1 Hour',
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
    return const _ScheduleCard(
      title: 'Design Test',
      subtitle: 'Applied design principles\nand practice review.',
      backgroundColor: Color(0xFFC4B9DC), // lavenderCard
      darkAccent: Color(0xFF5A4E80),
      lightAccent: Color(0xFFA690C5),
      room: '244',
      points: '60',
      duration: '1 Hour',
    );
  }
}

class _StudioCritCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _ScheduleCard(
      title: 'Studio Crit',
      subtitle: 'Peer review of your studio\nwork with tutors.',
      backgroundColor: Color(0xFFBDE4C9), // greenCard
      darkAccent: Color(0xFF4A7D5C),
      lightAccent: Color(0xFF90C5A3),
      room: '301',
      points: '25',
      duration: '1 Hour',
    );
  }
}

class _LabSessionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _ScheduleCard(
      title: 'Lab Session',
      subtitle: 'Hands-on model making\nworkshop in the lab.',
      backgroundColor: Color(0xFFE9CCAA), // orangeCard
      darkAccent: Color(0xFF8A603A),
      lightAccent: Color(0xFFD1AE87),
      room: 'B12',
      points: '30',
      duration: '1.5 Hours',
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

class _MonthViewSheet extends StatelessWidget {
  const _MonthViewSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'June, 2026',
            style: GoogleFonts.urbanist(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111315),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: GoogleFonts.urbanist(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF757575),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 30, // June has 30 days. June 1, 2026 is a Monday.
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final day = index + 1;
              final isSelected = day == 14;
              return Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF5B4AE4) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  day.toString(),
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF111315),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ExpandedMonthCalendar extends StatelessWidget {
  const _ExpandedMonthCalendar();

  @override
  Widget build(BuildContext context) {
    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    // Generate dates (simplified for UI demonstration)
    // June 2026 starts on Monday, 30 days. We'll show 5 weeks = 35 cells.
    final dates = List.generate(35, (index) {
      if (index < 30) return index + 1;
      return (index - 30) + 1; // July dates
    });

    return Column(
      children: [
        // Days of week header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: daysOfWeek.map((day) {
            return SizedBox(
              width: 42,
              child: Center(
                child: Text(
                  day,
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8), // Gray
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // Grid of dates
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 12,
            crossAxisSpacing: 8,
            childAspectRatio: 0.8, // Slightly taller to fit event indicators
          ),
          itemCount: 35,
          itemBuilder: (context, index) {
            final date = dates[index];
            final isNextMonth = index >= 30;
            final isSelected = !isNextMonth && date == 14;
            
            // Determine events
            List<Color> events = [];
            if (!isNextMonth) {
              if (date == 3) events = [const Color(0xFFBDE4C9)]; // Green
              if ([4, 7, 17, 25, 28].contains(date)) events = [const Color(0xFFD7A1A7)]; // Pink
              if ([5, 12, 20, 26].contains(date)) events = [const Color(0xFFE9CCAA)]; // Yellow
              if ([6, 13, 21, 28].contains(date)) events = [const Color(0xFFC4B9DC)]; // Purple
              if (date == 14) events = [const Color(0xFFD7A1A7), const Color(0xFFC4B9DC)];
              if (date == 25) events = [const Color(0xFFD7A1A7), const Color(0xFFC4B9DC)];
            }

            return Container(
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF111315) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: const Color(0xFF111315).withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.toString(),
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isNextMonth 
                          ? const Color(0xFFCBD5E1) 
                          : isSelected ? Colors.white : const Color(0xFF111315),
                    ),
                  ),
                  if (events.isNotEmpty) const SizedBox(height: 6),
                  if (events.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: events.map((color) => Container(
                        width: 14,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )).toList(),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _LegendItem(color: Color(0xFFD7A1A7), label: 'Theory'),
            SizedBox(width: 16),
            _LegendItem(color: Color(0xFFC4B9DC), label: 'Design'),
            SizedBox(width: 16),
            _LegendItem(color: Color(0xFFBDE4C9), label: 'Studio'),
            SizedBox(width: 16),
            _LegendItem(color: Color(0xFFE9CCAA), label: 'Lab'),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
