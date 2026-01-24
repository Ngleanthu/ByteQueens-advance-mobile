/// Token Usage Model
class TokenUsage {
  final int availableTokens;
  final int totalTokens;
  final bool unlimited;
  final DateTime date;

  TokenUsage({
    required this.availableTokens,
    required this.totalTokens,
    required this.unlimited,
    required this.date,
  });

  factory TokenUsage.fromJson(Map<String, dynamic> json) {
    return TokenUsage(
      availableTokens: json['availableTokens'] ?? 0,
      totalTokens: json['totalTokens'] ?? 0,
      unlimited: json['unlimited'] ?? false,
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'availableTokens': availableTokens,
      'totalTokens': totalTokens,
      'unlimited': unlimited,
      'date': date.toIso8601String(),
    };
  }

  bool get isPro => unlimited;
  
  String get displayTokens {
    if (unlimited) return 'Unlimited';
    return availableTokens.toString();
  }
}

/// Subscription Plan Model
class SubscriptionPlan {
  final String name;
  final int dailyTokens;
  final int monthlyTokens;
  final int annuallyTokens;

  SubscriptionPlan({
    required this.name,
    required this.dailyTokens,
    required this.monthlyTokens,
    required this.annuallyTokens,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      name: json['name'] ?? 'Free',
      dailyTokens: json['dailyTokens'] ?? 0,
      monthlyTokens: json['monthlyTokens'] ?? 0,
      annuallyTokens: json['annuallyTokens'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dailyTokens': dailyTokens,
      'monthlyTokens': monthlyTokens,
      'annuallyTokens': annuallyTokens,
    };
  }

  bool get isPro => name.toLowerCase().contains('pro');
  bool get isFree => name.toLowerCase().contains('free');
}

/// Subscription Response
class SubscriptionResponse {
  final bool success;
  final String message;
  final dynamic data;

  SubscriptionResponse({
    required this.success,
    required this.message,
    this.data,
  });
}
