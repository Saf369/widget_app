import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback onLogin;
  const LoginScreen({super.key, required this.onLogin});

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
          // Background glows
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
            left: -110,
            bottom: 0,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFCBBFDD).withOpacity(0.4),
              ),
            ),
          ),
          Positioned(
            right: 100,
            bottom: 150,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD9A9B4).withOpacity(0.35),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                    child: Row(
                      children: [
                        // Logo
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0E0E10),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.6), width: 1),
                          ),
                          child: Center(
                            child: Text('S',
                                style: GoogleFonts.urbanist(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white)),
                          ),
                        ),
                        const Spacer(),
                        // Help
                        _GlassButton(
                          child: Text('?',
                              style: GoogleFonts.urbanist(
                                  fontSize: 20, color: const Color(0xFF141414))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                  // Welcome back
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Text('Welcome back',
                        style: GoogleFonts.urbanist(
                            fontSize: 18, color: const Color(0xFF5B5B60))),
                  ),
                  const SizedBox(height: 4),
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: Text('Log in to your\nSyllabus',
                        style: GoogleFonts.urbanist(
                          fontSize: 48,
                          fontWeight: FontWeight.w400,
                          height: 50 / 48,
                          color: const Color(0xFF141414),
                        )),
                  ),
                  const SizedBox(height: 32),
                  // Credentials Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.62),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.9), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4D4073).withOpacity(0.12),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Email field
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 11, 16, 11),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8CACF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text('@',
                                        style: GoogleFonts.urbanist(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white)),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Email',
                                        style: GoogleFonts.urbanist(
                                            fontSize: 12,
                                            color: const Color(0xFF5A4E80))),
                                    Text('anna@studio.edu',
                                        style: GoogleFonts.urbanist(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF141414))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Separator
                          Padding(
                            padding: const EdgeInsets.only(left: 66),
                            child: Container(
                                height: 1,
                                color: const Color(0xFFD9D7D3).withOpacity(0.8)),
                          ),
                          // Password field
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 11, 16, 11),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8CACF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.lock_outline_rounded,
                                      color: Colors.white, size: 18),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Password',
                                        style: GoogleFonts.urbanist(
                                            fontSize: 12,
                                            color: const Color(0xFF5A4E80))),
                                    Text('••••••••••',
                                        style: GoogleFonts.urbanist(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF141414))),
                                  ],
                                ),
                                const Spacer(),
                                Text('Show',
                                    style: GoogleFonts.urbanist(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF5A4E80))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Forgot password
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 22, 0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('Forgot password?',
                          style: GoogleFonts.urbanist(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF5A4E80))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Log in button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: GestureDetector(
                      onTap: onLogin,
                      child: Container(
                        height: 58,
                        padding: const EdgeInsets.fromLTRB(30, 8, 8, 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E0E10),
                          borderRadius: BorderRadius.circular(29),
                        ),
                        child: Row(
                          children: [
                            Text('Log in',
                                style: GoogleFonts.urbanist(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white)),
                            const Spacer(),
                            Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text('→',
                                    style: GoogleFonts.urbanist(
                                        fontSize: 18,
                                        color: const Color(0xFF0E0E10))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                                height: 1,
                                color: const Color(0xFFD9D7D3).withOpacity(0.9))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or continue with',
                              style: GoogleFonts.urbanist(
                                  fontSize: 13, color: const Color(0xFF5B5B60))),
                        ),
                        Expanded(
                            child: Container(
                                height: 1,
                                color: const Color(0xFFD9D7D3).withOpacity(0.9))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Social row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      children: [
                        Expanded(child: _SocialButton(label: 'Google')),
                        const SizedBox(width: 9),
                        Expanded(child: _SocialButton(label: 'Apple')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Sign up row
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('New to Custom Syllabus?',
                            style: GoogleFonts.urbanist(
                                fontSize: 14, color: const Color(0xFF5B5B60))),
                        const SizedBox(width: 5),
                        Text('Sign up',
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF141414),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
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
        color: Colors.white.withOpacity(0.55),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
      ),
      child: Center(child: child),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  const _SocialButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                  color: const Color(0xFFD9D7D3).withOpacity(0.9), width: 1),
            ),
            child: Center(
              child: Text(
                label[0],
                style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF141414)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(label,
              style: GoogleFonts.urbanist(
                  fontSize: 15,
                  color: const Color(0xFF141414))),
        ],
      ),
    );
  }
}
