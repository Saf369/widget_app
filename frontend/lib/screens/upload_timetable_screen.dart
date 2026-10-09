import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../models/schedule.dart';

class UploadTimetableScreen extends StatefulWidget {
  final VoidCallback onUpload;
  final VoidCallback onSkip;

  const UploadTimetableScreen({
    super.key,
    required this.onUpload,
    required this.onSkip,
  });

  @override
  State<UploadTimetableScreen> createState() => _UploadTimetableScreenState();
}

class _UploadTimetableScreenState extends State<UploadTimetableScreen> {
  PlatformFile? _selectedFile;
  bool _isUploading = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'xlsx', 'xls'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _handleUpload() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file first.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Use 10.0.2.2 for Android emulator, 127.0.0.1 for iOS simulator/desktop
      var uri = Uri.parse('http://127.0.0.1:8000/analyze-timetable/');
      var request = http.MultipartRequest('POST', uri);
      
      // Handle Flutter Web uploading
      if (_selectedFile!.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'file', 
          _selectedFile!.bytes!,
          filename: _selectedFile!.name,
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'file', 
          _selectedFile!.path!,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        bool isTimetable = data['is_timetable'];
        
        if (isTimetable) {
          // Parse entries and save to global state
          List<dynamic> entriesData = data['entries'];
          globalTimetable = entriesData.map((e) => TimetableEntry.fromJson(e)).toList();
          
          widget.onUpload(); // Proceed to next screen
        } else {
          String reason = data['reasoning'];
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Not a timetable: $reason")),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Server error: ${response.statusCode}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Network error: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE5DEEE), // Soft purple top left
              Color(0xFFF9F5F1), // Soft beige middle
              Color(0xFFE4DCE7), // Soft purple bottom right
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                // Top Navigation Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          widget.onSkip();
                        }
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF141414)),
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onSkip,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF141414)),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Headers
                Text(
                  'One last step',
                  style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w400, color: const Color(0xFF6E5A62)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload your\ntimetable',
                  style: GoogleFonts.urbanist(fontSize: 48, fontWeight: FontWeight.w400, color: const Color(0xFF141414), height: 1.1),
                ),
                const SizedBox(height: 16),
                Text(
                  'Add a PDF, photo or spreadsheet and we\'ll build\nyour schedule for you.',
                  style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w400, color: const Color(0xFF6E5A62), height: 1.4),
                ),
                
                const SizedBox(height: 20),
                
                // Dashed Upload Area
                GestureDetector(
                  onTap: _isUploading ? null : _pickFile,
                  child: CustomPaint(
                    painter: _DashedRectPainter(color: const Color(0xFFAAA3B0)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      decoration: BoxDecoration(
                        color: _selectedFile != null ? Colors.white.withOpacity(0.3) : Colors.transparent,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: Color(0xFFC7B9DD), // Pastel purple circle
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_upward_rounded, color: Color(0xFF141414), size: 28),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFile != null ? 'File Selected!' : 'Tap to upload',
                            style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w500, color: const Color(0xFF141414)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedFile != null ? _selectedFile!.name : 'or drag a file here',
                            style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF6E5A62)),
                          ),
                          const SizedBox(height: 24),
                          // File format tags
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _FormatTag('PDF'),
                              SizedBox(width: 8),
                              _FormatTag('PNG'),
                              SizedBox(width: 8),
                              _FormatTag('JPG'),
                              SizedBox(width: 8),
                              _FormatTag('XLSX'),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Secondary Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _isUploading ? null : _pickFile,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24, height: 24,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt_outlined, size: 14, color: Color(0xFF141414)),
                              ),
                              const SizedBox(width: 12),
                              Text('Take a photo', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF141414))),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: _isUploading ? null : _pickFile,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24, height: 24,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.insert_drive_file_outlined, size: 14, color: Color(0xFF141414)),
                              ),
                              const SizedBox(width: 12),
                              Text('Choose file', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF141414))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Primary Action Button
                GestureDetector(
                  onTap: _isUploading ? null : _handleUpload,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: _selectedFile != null 
                          ? [BoxShadow(color: const Color(0xFFC7B9DD).withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 8))]
                          : [],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 24),
                        Text(
                          _isUploading ? 'Uploading...' : 'Upload timetable',
                          style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                        const Spacer(),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: _isUploading
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: CircularProgressIndicator(color: Color(0xFF141414), strokeWidth: 2),
                                )
                              : const Icon(Icons.arrow_forward_rounded, color: Color(0xFF141414)),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Footer Text
                Center(
                  child: Text(
                    'You can always add it later in Settings',
                    style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF867880)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
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

class _FormatTag extends StatelessWidget {
  final String text;
  const _FormatTag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF141414)),
      ),
    );
  }
}

// Custom Painter for dashed rounded rectangle border
class _DashedRectPainter extends CustomPainter {
  final Color color;
  static const double strokeWidth = 1.5;
  static const double gap = 5.0;
  static const double dashWidth = 6.0;
  static const double radius = 24.0;

  _DashedRectPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(radius),
    );

    Path path = Path()..addRRect(rrect);
    Path dashPath = Path();

    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < pathMetric.length) {
        final double length = draw ? dashWidth : gap;
        if (draw) {
          dashPath.addPath(
            pathMetric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
