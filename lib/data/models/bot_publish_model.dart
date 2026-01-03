/// Bot Publish Platform Types
enum PublishPlatform { slack, telegram, messenger }

/// Bot Publish Configuration
class BotPublishConfig {
  final PublishPlatform platform;
  final String
  token; // Webhook URL for Slack, Bot Token for Telegram, Page Token for Messenger
  final bool isActive;

  BotPublishConfig({
    required this.platform,
    required this.token,
    this.isActive = true,
  });

  factory BotPublishConfig.fromJson(Map<String, dynamic> json) {
    return BotPublishConfig(
      platform: PublishPlatform.values[json['platform'] as int],
      token: json['token'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'platform': platform.index, 'token': token, 'isActive': isActive};
  }

  String get platformName {
    switch (platform) {
      case PublishPlatform.slack:
        return 'Slack';
      case PublishPlatform.telegram:
        return 'Telegram';
      case PublishPlatform.messenger:
        return 'Messenger';
    }
  }

  String get platformIcon {
    switch (platform) {
      case PublishPlatform.slack:
        return '💬';
      case PublishPlatform.telegram:
        return '✈️';
      case PublishPlatform.messenger:
        return '💬';
    }
  }
}

/// Bot Publish Request (to API)
class BotPublishRequest {
  final String platform; // 'slack', 'telegram', 'messenger'
  final String webhookUrl; // For Slack
  final String? botToken; // For Telegram
  final String? pageAccessToken; // For Messenger

  BotPublishRequest({
    required this.platform,
    required this.webhookUrl,
    this.botToken,
    this.pageAccessToken,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'platform': platform};

    // Add platform-specific fields
    switch (platform) {
      case 'slack':
        json['webhook_url'] = webhookUrl;
        break;
      case 'telegram':
        json['bot_token'] = botToken;
        break;
      case 'messenger':
        json['page_access_token'] = pageAccessToken;
        break;
    }

    return json;
  }
}

/// Bot Publish Response (from API)
class BotPublishResponse {
  final bool success;
  final String message;
  final String? publishedUrl; // URL to access the published bot

  BotPublishResponse({
    required this.success,
    required this.message,
    this.publishedUrl,
  });

  factory BotPublishResponse.fromJson(Map<String, dynamic> json) {
    return BotPublishResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? 'Bot published successfully',
      publishedUrl: json['published_url'] as String?,
    );
  }
}
