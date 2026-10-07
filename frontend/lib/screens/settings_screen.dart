import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          // Background ellipses
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
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: const SizedBox(),
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
                          decoration: const BoxDecoration(
                            color: Color(0xFFB9C2C7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 28),
                        ),
                        const Spacer(),
                        _GlassIconButton(child: _ThreeDots(color: const Color(0xFF1A1A1A))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Label
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Text('Your preferences',
                        style: GoogleFonts.urbanist(
                            fontSize: 18, color: const Color(0xFF5B5B60))),
                  ),
                  const SizedBox(height: 4),
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: Text('Settings',
                        style: GoogleFonts.urbanist(
                          fontSize: 50,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -1.0,
                          color: const Color(0xFF141414),
                        )),
                  ),
                  const SizedBox(height: 24),
                  // Profile card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: _ProfileCard(),
                  ),
                  const SizedBox(height: 20),
                  // Section label
                  Padding(
                    padding: const EdgeInsets.only(left: 36, bottom: 8),
                    child: Text('Preferences',
                        style: GoogleFonts.urbanist(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF7A748C))),
                  ),
                  // Preferences group
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: _SettingsGroup(items: [
                      const _SettingsItem(
                        iconBg: Color(0xFFE8CACF),
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        trailing: _ToggleOn(),
                      ),
                      const _SettingsItem(
                        iconBg: Color(0xFFCDE6E2),
                        icon: Icons.alarm_rounded,
                        label: 'Study reminders',
                        trailing: _ToggleOn(),
                      ),
                      Opacity(
                        opacity: 0.6,
                        child: _SettingsItem(
                          iconBg: Color(0xFFD6CBE6),
                          icon: Icons.smart_toy_outlined,
                          label: 'AI Tutor',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF111315).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'COMING SOON',
                                  style: GoogleFonts.urbanist(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: const Color(0xFF5A5A60),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const _ToggleOff(),
                            ],
                          ),
                        ),
                      ),
                      const _SettingsItem(
                        iconBg: Color(0xFFD7DCE8),
                        icon: Icons.dark_mode_outlined,
                        label: 'Dark mode',
                        trailing: _ToggleOff(),
                        isLast: true,
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  // Section label
                  Padding(
                    padding: const EdgeInsets.only(left: 36, bottom: 8),
                    child: Text('More',
                        style: GoogleFonts.urbanist(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF7A748C))),
                  ),
                  // More group
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: _SettingsGroup(items: [
                      _SettingsItem(
                        iconBg: const Color(0xFFF0DCC8),
                        icon: Icons.language_rounded,
                        label: 'Language',
                        trailing: Text('English',
                            style: GoogleFonts.urbanist(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF7A748C))),
                      ),
                      const _SettingsItem(
                        iconBg: Color(0xFFCFE0EE),
                        icon: Icons.lock_outline_rounded,
                        label: 'Privacy & security',
                        trailing: _ChevronTrailing(),
                      ),
                      _SettingsItem(
                        iconBg: const Color(0xFFE3E0EA),
                        icon: Icons.help_outline_rounded,
                        label: 'Help center',
                        trailing: const _ChevronTrailing(),
                        onTap: () {
                          launchUrl(Uri.parse('mailto:safmu2090@gmail.com'));
                        },
                      ),
                      const _SettingsItem(
                        iconBg: Color(0xFFF0CFCF),
                        icon: Icons.logout_rounded,
                        label: 'Log out',
                        trailing: _ChevronTrailing(),
                        isLast: true,
                        isDestructive: true,
                      ),
                    ]),
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

class _GlassIconButton extends StatelessWidget {
  final Widget? child;
  final IconData? icon;
  const _GlassIconButton({this.child, this.icon});

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
        child: child ?? Icon(icon, color: const Color(0xFF1A1A1A), size: 22),
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

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFCBBFDD), Color(0xFFC4B8D8)],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
      ),
      child: Stack(
        children: [
          // Arc
          Positioned(
            right: -35,
            top: -60,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withOpacity(0.5), width: 1),
              ),
            ),
          ),
          // Avatar
          Positioned(
            left: 16,
            top: 16,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFB9C2C7),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 32),
            ),
          ),
          // Name
          Positioned(
            left: 92,
            top: 18,
            child: Text('Anna',
                style: GoogleFonts.urbanist(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF141414))),
          ),
          // Email
          Positioned(
            left: 92,
            top: 46,
            child: Text('anna@studio.edu',
                style: GoogleFonts.urbanist(
                    fontSize: 13, color: const Color(0xFF5A4E80))),
          ),
          // Plan chip
          Positioned(
            left: 92,
            top: 66,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Student plan',
                  style: GoogleFonts.urbanist(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF3A3350))),
            ),
          ),
          // Edit button
          Positioned(
            right: 16,
            top: 27,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFF0E0E10),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('↗',
                    style: GoogleFonts.urbanist(
                        fontSize: 17, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> items;
  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.62),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.9), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF66598C).withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final String label;
  final Widget trailing;
  final bool isLast;
  final bool isDestructive;
  final VoidCallback? onTap;
  const _SettingsItem({
    required this.iconBg,
    required this.icon,
    required this.label,
    required this.trailing,
    this.isLast = false,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon,
                      color: isDestructive
                          ? const Color(0xFFC0392B)
                          : const Color(0xFF5A5A60),
                      size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label,
                      style: GoogleFonts.urbanist(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDestructive
                            ? const Color(0xFFC0392B)
                            : const Color(0xFF141414),
                      )),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 64),
            child: Container(
              height: 1,
              color: const Color(0xFFD9D4E0).withOpacity(0.8),
            ),
          ),
      ],
    );
  }
}

class _ToggleOn extends StatelessWidget {
  const _ToggleOn();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _ToggleOff extends StatelessWidget {
  const _ToggleOff();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFCFC9DA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          margin: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _ChevronTrailing extends StatelessWidget {
  final String? subtitle;
  const _ChevronTrailing({this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (subtitle != null) ...[
          Text(subtitle!,
              style: GoogleFonts.urbanist(
                  fontSize: 14, color: const Color(0xFF7A748C))),
          const SizedBox(width: 6),
        ],
        const Icon(Icons.chevron_right_rounded,
            color: Color(0xFF7A748C), size: 20),
      ],
    );
  }
}
