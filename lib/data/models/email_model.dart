class EmailMetadata {
  final String subject;
  final String sender;
  final String receiver;
  final EmailStyle style;
  final String language;
  final List<dynamic> context;

  EmailMetadata({
    required this.subject,
    required this.sender,
    required this.receiver,
    required this.style,
    required this.language,
    this.context = const [],
  });

  Map<String, dynamic> toJson() => {
    'subject': subject,
    'sender': sender,
    'receiver': receiver,
    'style': style.toJson(),
    'language': language,
    'context': context,
  };
}

class EmailStyle {
  final String length;
  final String formality;
  final String tone;

  EmailStyle({
    required this.length,
    required this.formality,
    required this.tone,
  });

  Map<String, dynamic> toJson() => {
    'length': length,
    'formality': formality,
    'tone': tone,
  };
}

class EmailResponse {
  final String subject;
  final String sender;
  final String receiver;
  final String content;
  final bool success;
  final String? error;

  EmailResponse({
    required this.subject,
    required this.sender,
    required this.receiver,
    required this.content,
    this.success = true,
    this.error,
  });

  factory EmailResponse.fromJson(Map<String, dynamic> json) {
    // Handle different response structures
    // Case 1: Direct response
    if (json['email'] != null && json['email'] is String) {
      return EmailResponse(
        subject: json['subject'] ?? '',
        sender: json['sender'] ?? '',
        receiver: json['receiver'] ?? '',
        content: json['email'] as String,
        success: true,
      );
    }

    // Case 2: Nested data
    if (json['data'] != null) {
      final data = json['data'];
      return EmailResponse(
        subject: data['subject'] ?? '',
        sender: data['sender'] ?? '',
        receiver: data['receiver'] ?? '',
        content: data['email'] ?? data['content'] ?? '',
        success: json['success'] ?? true,
      );
    }

    // Case 3: Direct content field
    return EmailResponse(
      subject: json['subject'] ?? '',
      sender: json['sender'] ?? '',
      receiver: json['receiver'] ?? '',
      content: json['content'] ?? json['email'] ?? '',
      success: json['success'] ?? true,
      error: json['error'],
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
