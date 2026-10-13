import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showAppHelpDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFE8E1F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.help_outline_rounded, color: Color(0xFF5A4E80), size: 24),
          ),
          const SizedBox(width: 12),
          Text(
            'Help & Guide',
            style: GoogleFonts.urbanist(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: const Color(0xFF141414),
            ),
          ),
        ],
      ),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HelpItem(
              icon: Icons.calendar_today_rounded,
              iconColor: Color(0xFF5A4E80),
              bgColor: Color(0xFFE8E1F0),
              title: 'Weekly Schedule',
              description: 'Swipe through days in the top bar or pick any date to see your classes, timings, and rooms.',
            ),
            SizedBox(height: 14),
            _HelpItem(
              icon: Icons.timer_outlined,
              iconColor: Color(0xFF2C6B3D),
              bgColor: Color(0xFFE4F0EC),
              title: 'Live Hero Countdown',
              description: 'The hero card on Home shows your current class progress and counts down to your next session.',
            ),
            SizedBox(height: 14),
            _HelpItem(
              icon: Icons.search_rounded,
              iconColor: Color(0xFFB5651D),
              bgColor: Color(0xFFFBEEDB),
              title: 'Search Classes',
              description: 'Tap the search icon in the top right to find any course, subject code, or room across the week.',
            ),
            SizedBox(height: 14),
            _HelpItem(
              icon: Icons.auto_awesome_rounded,
              iconColor: Color(0xFF7A4200),
              bgColor: Color(0xFFFFF3CD),
              title: 'AI Timetable Import',
              description: 'Upload your syllabus or timetable PDF/image. Gemini AI extracts and parses all classes automatically.',
            ),
            SizedBox(height: 14),
            _HelpItem(
              icon: Icons.widgets_rounded,
              iconColor: Color(0xFF1E5B7E),
              bgColor: Color(0xFFDBEEF8),
              title: 'Home Screen Widget',
              description: 'Add the app widget to your phone home screen to check upcoming lectures at a glance.',
            ),
          ],
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(
              child: Text(
                'Got it!',
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String description;

  const _HelpItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.urbanist(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF141414),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.urbanist(
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF5B5B60),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
