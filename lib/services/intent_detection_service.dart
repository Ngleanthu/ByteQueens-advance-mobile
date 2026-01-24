import 'package:flutter/material.dart' show TimeOfDay;

/// Service phát hiện ý định (intent) từ tin nhắn người dùng
/// Đặc biệt xử lý intent đặt lịch hẹn
class IntentDetectionService {
  static final IntentDetectionService _instance =
      IntentDetectionService._internal();
  factory IntentDetectionService() => _instance;
  IntentDetectionService._internal();

  /// Phát hiện intent đặt lịch từ message
  /// Returns CalendarIntent nếu phát hiện được, null nếu không
  CalendarIntent? detectCalendarIntent(String message) {
    final lowerMessage = message.toLowerCase();

    // Từ khóa liên quan đến đặt lịch
    final calendarKeywords = [
      'đặt lịch',
      'lịch hẹn',
      'cuộc hẹn',
      'book',
      'schedule',
      'meeting',
      'appointment',
      'remind',
      'nhắc nhở',
      'event',
      'sự kiện',
    ];

    // Kiểm tra có từ khóa calendar không
    final hasCalendarKeyword =
        calendarKeywords.any((keyword) => lowerMessage.contains(keyword));

    if (!hasCalendarKeyword) {
      return null; // Không phải intent đặt lịch
    }

    print('🔍 Detected calendar intent in message: $message');

    // Extract thông tin từ message
    final title = _extractTitle(message);
    final dateTime = _extractDateTime(message);
    final duration = _extractDuration(message);

    // Nếu không có đủ thông tin, trả về null để AI xử lý bình thường
    if (dateTime == null) {
      print('⚠️ Calendar intent detected but missing date/time info');
      return null;
    }

    return CalendarIntent(
      title: title ?? 'Cuộc hẹn',
      description: message,
      dateTime: dateTime,
      durationMinutes: duration ?? 60,
      originalMessage: message,
    );
  }

  /// Extract title từ message
  String? _extractTitle(String message) {
    // Tìm pattern: "đặt lịch [title]", "schedule [title]", etc.
    final patterns = [
      RegExp(r'đặt lịch\s+(.+?)\s+(?:lúc|vào|ngày|at)', caseSensitive: false),
      RegExp(r'schedule\s+(.+?)\s+(?:at|on|for)', caseSensitive: false),
      RegExp(r'cuộc hẹn\s+(.+?)\s+(?:lúc|vào|ngày)', caseSensitive: false),
      RegExp(r'meeting\s+(?:with\s+)?(.+?)\s+(?:at|on)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null && match.groupCount >= 1) {
        return match.group(1)?.trim();
      }
    }

    // Nếu không tìm thấy pattern cụ thể, lấy phần đầu message
    final words = message.split(' ');
    if (words.length > 2) {
      return words.skip(2).take(3).join(' ');
    }

    return null;
  }

  /// Extract date và time từ message
  DateTime? _extractDateTime(String message) {
    final now = DateTime.now();
    DateTime? extractedDate;
    TimeOfDay? extractedTime;

    // Extract date
    extractedDate = _extractDate(message, now);

    // Extract time
    extractedTime = _extractTime(message);

    // Nếu không có date, return null
    if (extractedDate == null) {
      return null;
    }

    // Nếu không có time, dùng thời gian hiện tại + 1 giờ
    if (extractedTime == null) {
      extractedTime = TimeOfDay(
        hour: (now.hour + 1) % 24,
        minute: 0,
      );
    }

    // Combine date and time
    return DateTime(
      extractedDate.year,
      extractedDate.month,
      extractedDate.day,
      extractedTime.hour,
      extractedTime.minute,
    );
  }

  /// Extract date từ message
  DateTime? _extractDate(String message, DateTime now) {
    final lowerMessage = message.toLowerCase();

    // Relative date patterns
    if (lowerMessage.contains('hôm nay') || lowerMessage.contains('today')) {
      return now;
    }
    if (lowerMessage.contains('ngày mai') || lowerMessage.contains('tomorrow')) {
      return now.add(const Duration(days: 1));
    }
    if (lowerMessage.contains('ngày kia') ||
        lowerMessage.contains('day after tomorrow')) {
      return now.add(const Duration(days: 2));
    }
    if (lowerMessage.contains('tuần sau') || lowerMessage.contains('next week')) {
      return now.add(const Duration(days: 7));
    }

    // Specific weekday patterns (Vietnamese)
    final weekdayPatterns = {
      'thứ hai': 1,
      'thứ ba': 2,
      'thứ tư': 3,
      'thứ năm': 4,
      'thứ sáu': 5,
      'thứ bảy': 6,
      'chủ nhật': 7,
      'monday': 1,
      'tuesday': 2,
      'wednesday': 3,
      'thursday': 4,
      'friday': 5,
      'saturday': 6,
      'sunday': 7,
    };

    for (final entry in weekdayPatterns.entries) {
      if (lowerMessage.contains(entry.key)) {
        final targetWeekday = entry.value;
        final currentWeekday = now.weekday;
        int daysToAdd = targetWeekday - currentWeekday;
        if (daysToAdd <= 0) {
          daysToAdd += 7; // Next week
        }
        return now.add(Duration(days: daysToAdd));
      }
    }

    // Specific date patterns: "ngày 25/1", "25/1/2024", "1/25", "January 25"
    // Pattern: dd/MM or dd/MM/yyyy
    final datePattern1 = RegExp(r'(\d{1,2})[/\-](\d{1,2})(?:[/\-](\d{2,4}))?');
    final match1 = datePattern1.firstMatch(message);
    if (match1 != null) {
      final day = int.tryParse(match1.group(1) ?? '');
      final month = int.tryParse(match1.group(2) ?? '');
      final yearStr = match1.group(3);
      int? year;

      if (yearStr != null) {
        year = int.tryParse(yearStr);
        if (year != null && year < 100) {
          year += 2000; // Convert 24 -> 2024
        }
      } else {
        year = now.year;
        // Nếu tháng/ngày đã qua trong năm nay, dùng năm sau
        if (month != null && day != null) {
          final targetDate = DateTime(year, month, day);
          if (targetDate.isBefore(now)) {
            year += 1;
          }
        }
      }

      if (day != null && month != null && year != null) {
        try {
          return DateTime(year, month, day);
        } catch (e) {
          print('❌ Invalid date: $day/$month/$year');
        }
      }
    }

    // Pattern: "ngày 25", "day 25"
    final dayPattern = RegExp(r'(?:ngày|day)\s+(\d{1,2})');
    final dayMatch = dayPattern.firstMatch(lowerMessage);
    if (dayMatch != null) {
      final day = int.tryParse(dayMatch.group(1) ?? '');
      if (day != null && day >= 1 && day <= 31) {
        // Assume current month
        int month = now.month;
        int year = now.year;

        // If day has passed this month, use next month
        if (day < now.day) {
          month += 1;
          if (month > 12) {
            month = 1;
            year += 1;
          }
        }

        try {
          return DateTime(year, month, day);
        } catch (e) {
          print('❌ Invalid date: $day/$month/$year');
        }
      }
    }

    return null; // Không tìm thấy date
  }

  /// Extract time từ message
  TimeOfDay? _extractTime(String message) {
    final lowerMessage = message.toLowerCase();

    // Pattern: "lúc 14:30", "at 2:30 PM", "14h30", "2h30"
    final timePatterns = [
      RegExp(r'(?:lúc|at)\s+(\d{1,2})[:\.]?(\d{2})?\s*(am|pm|sáng|chiều|tối)?',
          caseSensitive: false),
      RegExp(r'(\d{1,2})h(\d{2})?\s*(am|pm|sáng|chiều|tối)?',
          caseSensitive: false),
      RegExp(r'(\d{1,2}):(\d{2})\s*(am|pm|sáng|chiều|tối)?',
          caseSensitive: false),
    ];

    for (final pattern in timePatterns) {
      final match = pattern.firstMatch(lowerMessage);
      if (match != null) {
        final hourStr = match.group(1);
        final minuteStr = match.group(2);
        final period = match.group(3)?.toLowerCase();

        if (hourStr != null) {
          int hour = int.parse(hourStr);
          final minute = minuteStr != null ? int.parse(minuteStr) : 0;

          // Handle AM/PM
          if (period != null) {
            if ((period == 'pm' || period == 'chiều' || period == 'tối') &&
                hour < 12) {
              hour += 12;
            } else if ((period == 'am' || period == 'sáng') && hour == 12) {
              hour = 0;
            }
          }

          if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
            return TimeOfDay(hour: hour, minute: minute);
          }
        }
      }
    }

    return null;
  }

  /// Extract duration từ message (in minutes)
  int? _extractDuration(String message) {
    final lowerMessage = message.toLowerCase();

    // Pattern: "kéo dài 2 giờ", "duration 90 minutes", "trong 1 tiếng"
    final durationPatterns = [
      RegExp(r'(?:kéo dài|duration|trong)\s+(\d+)\s*(?:giờ|hour|h)',
          caseSensitive: false),
      RegExp(r'(?:kéo dài|duration|trong)\s+(\d+)\s*(?:phút|minute|min|m)',
          caseSensitive: false),
    ];

    // Hours
    final hourMatch = durationPatterns[0].firstMatch(lowerMessage);
    if (hourMatch != null) {
      final hours = int.tryParse(hourMatch.group(1) ?? '');
      if (hours != null) {
        return hours * 60;
      }
    }

    // Minutes
    final minuteMatch = durationPatterns[1].firstMatch(lowerMessage);
    if (minuteMatch != null) {
      final minutes = int.tryParse(minuteMatch.group(1) ?? '');
      if (minutes != null) {
        return minutes;
      }
    }

    return null; // Default: 60 minutes will be used
  }
}

/// Đại diện cho một calendar intent đã được detect
class CalendarIntent {
  final String title;
  final String description;
  final DateTime dateTime;
  final int durationMinutes;
  final String originalMessage;

  CalendarIntent({
    required this.title,
    required this.description,
    required this.dateTime,
    required this.durationMinutes,
    required this.originalMessage,
  });

  @override
  String toString() {
    return 'CalendarIntent(title: $title, dateTime: $dateTime, duration: $durationMinutes min)';
  }
}
