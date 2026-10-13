import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'upload_timetable_screen.dart';
import '../widgets/help_dialog.dart';
import '../services/auth_service.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  bool _studyRemindersEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs.getBool('settings_notifications') ?? false;
        _studyRemindersEnabled = prefs.getBool('settings_study_reminders') ?? false;
      });
    }
  }

  Future<void> _setNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_notifications', value);
  }

  Future<void> _setStudyReminders(bool value) async {
    setState(() => _studyRemindersEnabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_study_reminders', value);
  }

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
                        // Back to Home button
                        GestureDetector(
                          onTap: () => AppShell.of(context)?.goToTab(0),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.arrow_back_rounded, color: Color(0xFF141414), size: 22),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Builder(
                          builder: (btnContext) {
                            return _GlassIconButton(
                              child: const _ThreeDots(color: Color(0xFF1A1A1A)),
                              onTap: () async {
                                final renderBox = btnContext.findRenderObject() as RenderBox?;
                                final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
                                if (renderBox == null || overlay == null) return;

                                final buttonTopLeft = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
                                final buttonBottomRight = renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero), ancestor: overlay);

                                final position = RelativeRect.fromRect(
                                  Rect.fromLTRB(
                                    buttonTopLeft.dx,
                                    buttonBottomRight.dy + 14,
                                    buttonBottomRight.dx,
                                    buttonBottomRight.dy + 14,
                                  ),
                                  Offset.zero & overlay.size,
                                );

                                final selected = await showMenu<String>(
                                  context: context,
                                  position: position,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  color: Colors.white,
                                  elevation: 8,
                                  items: [
                                    PopupMenuItem<String>(
                                      value: 'help',
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFE8E1F0),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.help_outline_rounded,
                                              color: Color(0xFF5A4E80),
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Help',
                                            style: GoogleFonts.urbanist(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF141414),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'upload',
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFE4F0EC),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.upload_file_rounded,
                                              color: Color(0xFF2C6B3D),
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Re-upload',
                                            style: GoogleFonts.urbanist(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF141414),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );

                                if (!context.mounted) return;
                                if (selected == 'help') {
                                  showAppHelpDialog(context);
                                } else if (selected == 'upload') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UploadTimetableScreen(
                                        onUpload: () => Navigator.pop(context),
                                        onSkip: () => Navigator.pop(context),
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
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
                  // Profile card (live data)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: StreamBuilder<User?>(
                      stream: AuthService().authStateChanges,
                      builder: (context, snapshot) {
                        final user = snapshot.data;
                        return _ProfileCard(
                          displayName: user?.displayName ?? user?.email?.split('@').first ?? 'User',
                          email: user?.email ?? '',
                          photoUrl: user?.photoURL,
                        );
                      },
                    ),
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
                      _SettingsItem(
                        iconBg: const Color(0xFFE8CACF),
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        trailing: _ToggleSwitch(
                          value: _notificationsEnabled,
                          onChanged: _setNotifications,
                        ),
                      ),
                      _SettingsItem(
                        iconBg: const Color(0xFFCDE6E2),
                        icon: Icons.alarm_rounded,
                        label: 'Study reminders',
                        trailing: _ToggleSwitch(
                          value: _studyRemindersEnabled,
                          onChanged: _setStudyReminders,
                        ),
                      ),
                      const Opacity(
                        opacity: 0.6,
                        child: _SettingsItem(
                          iconBg: Color(0xFFD6CBE6),
                          icon: Icons.smart_toy_outlined,
                          label: 'AI Tutor',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ComingSoonBadge(),
                              SizedBox(width: 12),
                              _ToggleOff(),
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
                  // Timetable Section
                  Padding(
                    padding: const EdgeInsets.only(left: 36, bottom: 8),
                    child: Text('Timetable & Syllabus',
                        style: GoogleFonts.urbanist(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF7A748C))),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: _SettingsGroup(items: [
                      _SettingsItem(
                        iconBg: const Color(0xFFDBD3EE),
                        icon: Icons.upload_file_rounded,
                        label: 'Upload new timetable (PDF / Image)',
                        trailing: const _ChevronTrailing(),
                        isLast: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UploadTimetableScreen(
                                onUpload: () => Navigator.pop(context),
                                onSkip: () => Navigator.pop(context),
                              ),
                            ),
                          );
                        },
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
                      _SettingsItem(
                        iconBg: const Color(0xFFF0CFCF),
                        icon: Icons.logout_rounded,
                        label: 'Log out',
                        trailing: const _ChevronTrailing(),
                        isLast: true,
                        isDestructive: true,
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Log out'),
                              content: const Text('Are you sure you want to log out?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Log out',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            await AuthService().signOut();
                            // StreamBuilder in main.dart will automatically redirect to LoginScreen
                          }
                        },
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
  final Widget child;
  final VoidCallback? onTap;
  const _GlassIconButton({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.55),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
        ),
        child: Center(
          child: child,
        ),
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
  final String displayName;
  final String email;
  final String? photoUrl;

  const _ProfileCard({
    required this.displayName,
    required this.email,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFCBBFDD), Color(0xFFC4B8D8)],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Decorative arc
          Positioned(
            right: -35, top: -60,
            child: Container(
              width: 150, height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
              ),
            ),
          ),
          // Content row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // Avatar
                photoUrl != null && photoUrl!.isNotEmpty
                    ? CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(photoUrl!),
                      )
                    : Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB9C2C7),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                            style: GoogleFonts.urbanist(
                              fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(width: 14),
                // Name + email + chip
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.urbanist(
                          fontSize: 18, fontWeight: FontWeight.w600,
                          color: const Color(0xFF141414),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.urbanist(
                          fontSize: 12.5, color: const Color(0xFF5A4E80),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('Student plan',
                            style: GoogleFonts.urbanist(
                              fontSize: 11, fontWeight: FontWeight.w500,
                              color: const Color(0xFF3A3350),
                            )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Edit button
                Container(
                  width: 42, height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0E0E10), shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('↗',
                        style: GoogleFonts.urbanist(fontSize: 17, color: Colors.white)),
                  ),
                ),
              ],
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

class _ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _ToggleSwitch({
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 48,
        height: 28,
        decoration: BoxDecoration(
          color: value ? const Color(0xFF0E0E10) : const Color(0xFFCFC9DA),
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
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
      ),
    );
  }
}

class _ComingSoonBadge extends StatelessWidget {
  const _ComingSoonBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
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
  const _ChevronTrailing();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.chevron_right_rounded,
      color: Color(0xFF7A748C),
      size: 20,
    );
  }
}
