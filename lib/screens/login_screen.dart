import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8F4),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFECE8F4),
          borderRadius: BorderRadius.all(Radius.circular(48)),
        ),
      child: Stack(
        children: [
          // Background blobs simulating the organic iOS-like gradients
          Positioned(
            right: -80,
            top: -40,
            child: _Blob(color: const Color(0xFFFDF8F4).withOpacity(0.8), size: 300),
          ),
          Positioned(
            left: -100,
            top: 150,
            child: _Blob(color: const Color(0xFFEDE6EE).withOpacity(0.8), size: 300),
          ),
          Positioned(
            right: -40,
            bottom: 200,
            child: _Blob(color: const Color(0xFFFAE2E5).withOpacity(0.8), size: 250),
          ),
          Positioned(
            left: -50,
            bottom: -50,
            child: _Blob(color: const Color(0xFFCFC5DD).withOpacity(0.9), size: 350),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: const SizedBox(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Scrollable main content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Sparkle icon
                            Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                color: Color(0xFF111113),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                              ),
                            ),
                            // Help icon
                            ClipRRect(
                              borderRadius: BorderRadius.circular(26),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text('?',
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 20, color: const Color(0xFF111113))),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Welcome headers
                        Text(
                          'Welcome back',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            color: const Color(0xFF6C6B75),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Log in',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 44,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -1,
                            color: const Color(0xFF111113),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Email Input
                        _InputField(
                          label: 'Email',
                          value: 'anna@studio.edu',
                          trailing: Container(
                            width: 22,
                            height: 22,
                            decoration: const BoxDecoration(
                              color: Color(0xFF111113),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Password Input
                        _InputField(
                          label: 'Password',
                          value: 'supersecretpass',
                          isPassword: true,
                          trailing: Text(
                            'Show',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF534E73),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Forgot password?',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              color: const Color(0xFF534E73),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Log In Button
                        GestureDetector(
                          onTap: onLogin,
                          child: Container(
                            height: 62,
                            padding: const EdgeInsets.only(left: 28, right: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111113),
                              borderRadius: BorderRadius.circular(31),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Log in',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Color(0xFF111113),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Divider
                        Row(
                          children: [
                            Expanded(child: Container(height: 1, color: Colors.black.withOpacity(0.1))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'or continue with',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: const Color(0xFF6C6B75),
                                ),
                              ),
                            ),
                            Expanded(child: Container(height: 1, color: Colors.black.withOpacity(0.1))),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Social Logins
                        Row(
                          children: [
                            const Expanded(child: _SocialButton(initial: 'G', label: 'Google')),
                            const SizedBox(width: 12),
                            const Expanded(child: _SocialButton(initial: 'C', label: 'Campus SSO')),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                // Bottom Card pinned at the bottom
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC5B8D8).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'New here?',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: const Color(0xFF6C6B75),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Create an account',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF111113),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFF111113),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
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

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 100,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String value;
  final bool isPassword;
  final Widget trailing;

  const _InputField({
    required this.label,
    required this.value,
    this.isPassword = false,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6C6B75),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPassword ? '•••••••••••••••' : value,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: isPassword ? 2 : 0,
                        color: const Color(0xFF111113),
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String initial;
  final String label;

  const _SocialButton({required this.initial, required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(27),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 12), // Reduced padding slightly
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(27),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center contents
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111113),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8), // Reduced gap slightly
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF111113),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
