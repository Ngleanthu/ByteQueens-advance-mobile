/// Models for authentication API requests and responses

/// Sign Up Request Model
class SignUpRequest {
  final String email;
  final String password;
  final String verificationCallbackUrl;

  SignUpRequest({
    required this.email,
    required this.password,
    required this.verificationCallbackUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'verification_callback_url': verificationCallbackUrl,
    };
  }
}

/// Sign Up Response Model
class SignUpResponse {
  final String? accessToken;
  final String? refreshToken;
  final String? userId;
  final String? errorCode;
  final String? errorMessage;

  SignUpResponse({
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.errorCode,
    this.errorMessage,
  });

  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    // Check if response contains error
    if (json.containsKey('code') && json.containsKey('error')) {
      return SignUpResponse(
        errorCode: json['code'] as String?,
        errorMessage: json['error'] as String?,
      );
    }

    // Success response
    return SignUpResponse(
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      userId: json['user_id'] as String?,
    );
  }

  bool get isSuccess =>
      accessToken != null && refreshToken != null && userId != null;
  bool get hasError => errorCode != null || errorMessage != null;
}

/// Sign In Request Model
class SignInRequest {
  final String email;
  final String password;

  SignInRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

/// Sign In Response Model
class SignInResponse {
  final String? accessToken;
  final String? refreshToken;
  final String? userId;
  final String? errorCode;
  final String? errorMessage;

  SignInResponse({
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.errorCode,
    this.errorMessage,
  });

  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    // Check if response contains error
    if (json.containsKey('code') && json.containsKey('error')) {
      return SignInResponse(
        errorCode: json['code'] as String?,
        errorMessage: json['error'] as String?,
      );
    }

    // Success response
    return SignInResponse(
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      userId: json['user_id'] as String?,
    );
  }

  bool get isSuccess =>
      accessToken != null && refreshToken != null && userId != null;
  bool get hasError => errorCode != null || errorMessage != null;
}

/// Refresh Token Response Model
class RefreshTokenResponse {
  final String? accessToken;
  final String? errorCode;
  final String? errorMessage;

  RefreshTokenResponse({this.accessToken, this.errorCode, this.errorMessage});

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    // Check if response contains error
    if (json.containsKey('code') && json.containsKey('error')) {
      return RefreshTokenResponse(
        errorCode: json['code'] as String?,
        errorMessage: json['error'] as String?,
      );
    }

    // Success response
    return RefreshTokenResponse(accessToken: json['access_token'] as String?);
  }

  bool get isSuccess => accessToken != null;
  bool get hasError => errorCode != null || errorMessage != null;
}
