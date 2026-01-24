import 'package:bytequeens_adm/services/intent_detection_service.dart';
import 'package:bytequeens_adm/services/calendar_booking_service.dart';
import 'package:bytequeens_adm/services/auth_service.dart';

/// AI Agent tự động xử lý calendar booking
/// Phát hiện intent và thực hiện action tương ứng
class CalendarAgentService {
  static final CalendarAgentService _instance =
      CalendarAgentService._internal();
  factory CalendarAgentService() => _instance;
  CalendarAgentService._internal();

  final _intentDetector = IntentDetectionService();
  final _calendarService = CalendarBookingService();
  final _authService = AuthService();

  /// Xử lý message và tự động tạo calendar event nếu detect intent
  /// Returns AgentResponse với thông tin về action đã thực hiện
  Future<AgentResponse> processMessage(String message) async {
    print('🤖 Calendar Agent processing message...');

    // Detect calendar intent
    final intent = _intentDetector.detectCalendarIntent(message);

    if (intent == null) {
      print('   ℹ️ No calendar intent detected');
      return AgentResponse(
        hasIntent: false,
        message: message,
      );
    }

    print('   ✅ Calendar intent detected: ${intent.title}');
    print('   📅 DateTime: ${intent.dateTime}');
    print('   ⏱️ Duration: ${intent.durationMinutes} minutes');

    // Get user email
    final userEmail = _authService.getCurrentUserEmail();
    if (userEmail == null) {
      print('   ❌ User not logged in');
      return AgentResponse(
        hasIntent: true,
        success: false,
        message: message,
        errorMessage: 'Vui lòng đăng nhập để tạo sự kiện lịch',
        intent: intent,
      );
    }

    // Create calendar event
    try {
      final response = await _calendarService.createEvent(
        email: userEmail,
        title: intent.title,
        description: intent.description,
        startDateTime: intent.dateTime,
        durationMinutes: intent.durationMinutes,
      );

      if (response.success) {
        print('   ✅ Calendar event created successfully!');
        return AgentResponse(
          hasIntent: true,
          success: true,
          message: message,
          successMessage: _generateSuccessMessage(intent),
          intent: intent,
          eventCreated: true,
        );
      } else {
        print('   ❌ Failed to create calendar event: ${response.message}');
        return AgentResponse(
          hasIntent: true,
          success: false,
          message: message,
          errorMessage:
              'Không thể tạo sự kiện lịch. Vui lòng thử lại sau.',
          intent: intent,
        );
      }
    } catch (e) {
      print('   ❌ Exception creating calendar event: $e');
      return AgentResponse(
        hasIntent: true,
        success: false,
        message: message,
        errorMessage: 'Đã xảy ra lỗi khi tạo sự kiện lịch',
        intent: intent,
      );
    }
  }

  /// Tạo message thông báo thành công
  String _generateSuccessMessage(CalendarIntent intent) {
    final dateFormat = '${intent.dateTime.day}/${intent.dateTime.month}/${intent.dateTime.year}';
    final timeFormat =
        '${intent.dateTime.hour.toString().padLeft(2, '0')}:${intent.dateTime.minute.toString().padLeft(2, '0')}';

    final durationText = intent.durationMinutes >= 60
        ? '${intent.durationMinutes ~/ 60} giờ${intent.durationMinutes % 60 > 0 ? ' ${intent.durationMinutes % 60} phút' : ''}'
        : '${intent.durationMinutes} phút';

    return '✅ Đã tạo lịch hẹn thành công!\n\n'
        '📌 **${intent.title}**\n'
        '📅 Ngày: $dateFormat\n'
        '⏰ Giờ: $timeFormat\n'
        '⏱️ Thời lượng: $durationText\n\n'
        'Sự kiện đã được thêm vào Google Calendar của bạn! 🎉';
  }
}

/// Response từ Calendar Agent
class AgentResponse {
  /// Có detect được intent không
  final bool hasIntent;

  /// Action có thành công không (chỉ áp dụng khi hasIntent = true)
  final bool success;

  /// Message gốc từ user
  final String message;

  /// Message thông báo thành công (để hiển thị trong chat)
  final String? successMessage;

  /// Message thông báo lỗi
  final String? errorMessage;

  /// Calendar intent đã detect được
  final CalendarIntent? intent;

  /// Event đã được tạo thành công
  final bool eventCreated;

  AgentResponse({
    required this.hasIntent,
    this.success = false,
    required this.message,
    this.successMessage,
    this.errorMessage,
    this.intent,
    this.eventCreated = false,
  });

  /// Có cần hiển thị response từ agent không (thay vì AI chat)
  bool get shouldShowAgentResponse => hasIntent && success && eventCreated;

  /// Có lỗi cần hiển thị không
  bool get hasError => hasIntent && !success && errorMessage != null;
}
