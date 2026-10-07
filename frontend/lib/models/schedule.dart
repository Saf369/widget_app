class TimetableEntry {
  final String day;
  final String startTime;
  final String endTime;
  final String subject;
  final String room;
  final String instructor;

  TimetableEntry({
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.subject,
    this.room = '',
    this.instructor = '',
  });

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      day: json['day'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      subject: json['subject'] ?? '',
      room: json['room'] ?? '',
      instructor: json['instructor'] ?? '',
    );
  }
}

// Global variable for simplicity in this project scope
List<TimetableEntry> globalTimetable = [
  // MONDAY
  TimetableEntry(day: 'MON', startTime: '8:30', endTime: '9:30', subject: 'MATH'),
  TimetableEntry(day: 'MON', startTime: '9:30', endTime: '10:30', subject: 'PDHPE'),
  TimetableEntry(day: 'MON', startTime: '10:30', endTime: '11:30', subject: 'ENGLISH'),
  TimetableEntry(day: 'MON', startTime: '11:30', endTime: '12:30', subject: 'VISUAL ART'),
  TimetableEntry(day: 'MON', startTime: '1:30', endTime: '2:30', subject: 'HISTORY'),
  TimetableEntry(day: 'MON', startTime: '2:30', endTime: '3:30', subject: 'DRAMA'),

  // TUESDAY
  TimetableEntry(day: 'TUE', startTime: '8:30', endTime: '9:30', subject: 'LOTE'),
  TimetableEntry(day: 'TUE', startTime: '9:30', endTime: '10:30', subject: 'PDHPE'),
  TimetableEntry(day: 'TUE', startTime: '10:30', endTime: '11:30', subject: 'GEOGRAPHY'),
  TimetableEntry(day: 'TUE', startTime: '11:30', endTime: '12:30', subject: 'MUSIC'),
  TimetableEntry(day: 'TUE', startTime: '1:30', endTime: '2:30', subject: 'MATH'),
  TimetableEntry(day: 'TUE', startTime: '2:30', endTime: '3:30', subject: 'SCIENCE'),

  // WEDNESDAY
  TimetableEntry(day: 'WED', startTime: '8:30', endTime: '9:30', subject: 'SCIENCE'),
  TimetableEntry(day: 'WED', startTime: '9:30', endTime: '10:30', subject: 'LOTE'),
  TimetableEntry(day: 'WED', startTime: '10:30', endTime: '11:30', subject: 'ENGLISH'),
  TimetableEntry(day: 'WED', startTime: '11:30', endTime: '12:30', subject: 'DRAMA'),
  TimetableEntry(day: 'WED', startTime: '1:30', endTime: '2:30', subject: 'MATH'),
  TimetableEntry(day: 'WED', startTime: '2:30', endTime: '3:30', subject: 'GEOGRAPHY'),

  // THURSDAY
  TimetableEntry(day: 'THUR', startTime: '8:30', endTime: '9:30', subject: 'HISTORY'),
  TimetableEntry(day: 'THUR', startTime: '9:30', endTime: '10:30', subject: 'SCIENCE'),
  TimetableEntry(day: 'THUR', startTime: '10:30', endTime: '11:30', subject: 'MUSIC'),
  TimetableEntry(day: 'THUR', startTime: '11:30', endTime: '12:30', subject: 'GEOGRAPHY'),
  TimetableEntry(day: 'THUR', startTime: '1:30', endTime: '2:30', subject: 'ENGLISH'),
  TimetableEntry(day: 'THUR', startTime: '2:30', endTime: '3:30', subject: 'LOTE'),

  // FRIDAY
  TimetableEntry(day: 'FRI', startTime: '8:30', endTime: '9:30', subject: 'VISUAL ART'),
  TimetableEntry(day: 'FRI', startTime: '9:30', endTime: '10:30', subject: 'SCIENCE'),
  TimetableEntry(day: 'FRI', startTime: '10:30', endTime: '11:30', subject: 'MATH'),
  TimetableEntry(day: 'FRI', startTime: '11:30', endTime: '12:30', subject: 'DRAMA'),
  TimetableEntry(day: 'FRI', startTime: '1:30', endTime: '2:30', subject: 'ENGLISH'),
  TimetableEntry(day: 'FRI', startTime: '2:30', endTime: '3:30', subject: 'LOTE'),
];
