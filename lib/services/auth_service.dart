import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bytequeens_adm/config/app_constants.dart';
import 'package:bytequeens_adm/data/models/auth_models.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final Map<String, String> _users = {
    AppConstants.mockEmail: AppConstants.mockPassword,
  };

  final Map<String, String> _verificationCodes = {};

  String? _currentUserEmail;
  String? _accessToken;
  String? _refreshToken;
  String? _userId;

  /// Sign in với API thực
  Future<AuthResult> login(String email, String password) async {
    try {
      // Tạo request body
      final signInRequest = SignInRequest(email: email, password: password);

      // Gọi API
      final url = Uri.parse(
        '${AppConstants.apiBaseUrl}${AppConstants.signInEndpoint}',
      );
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Stack-Access-Type': AppConstants.stackAccessType,
          'X-Stack-Project-Id': AppConstants.stackProjectId,
          'X-Stack-Publishable-Client-Key':
              AppConstants.stackPublishableClientKey,
        },
        body: jsonEncode(signInRequest.toJson()),
      );

      // Parse response
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      final signInResponse = SignInResponse.fromJson(responseData);

      // Xử lý response
      if (response.statusCode == 200) {
        if (signInResponse.isSuccess) {
          // Lưu tokens và user info
          _accessToken = signInResponse.accessToken;
          _refreshToken = signInResponse.refreshToken;
          _userId = signInResponse.userId;
          _currentUserEmail = email.toLowerCase();

          return AuthResult(
            success: true,
            message: AppConstants.loginSuccess,
            data: {
              'access_token': _accessToken,
              'refresh_token': _refreshToken,
              'user_id': _userId,
            },
          );
        }
      }

      // Handle error responses
      if (signInResponse.hasError) {
        String errorMessage = signInResponse.errorMessage ?? 'Sign in failed';

        // Custom messages for specific error codes
        if (signInResponse.errorCode == 'INVALID_CREDENTIALS') {
          errorMessage = 'Invalid email or password. Please try again.';
        } else if (signInResponse.errorCode == 'USER_NOT_FOUND') {
          errorMessage = 'Email not found. Please sign up first.';
        }

        return AuthResult(success: false, message: errorMessage);
      }

      return AuthResult(
        success: false,
        message: 'Sign in failed. Please try again.',
      );
    } catch (e) {
      // Handle network or parsing errors
      return AuthResult(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Sign up với API thực
  Future<AuthResult> signUp(String email, String password) async {
    try {
      // Tạo request body
      final signUpRequest = SignUpRequest(
        email: email,
        password: password,
        verificationCallbackUrl: AppConstants.verificationCallbackUrl,
      );

      // Gọi API
      final url = Uri.parse(
        '${AppConstants.apiBaseUrl}${AppConstants.signUpEndpoint}',
      );
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Stack-Access-Type': AppConstants.stackAccessType,
          'X-Stack-Project-Id': AppConstants.stackProjectId,
          'X-Stack-Publishable-Client-Key':
              AppConstants.stackPublishableClientKey,
        },
        body: jsonEncode(signUpRequest.toJson()),
      );

      // Parse response
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      final signUpResponse = SignUpResponse.fromJson(responseData);

      // Xử lý response
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (signUpResponse.isSuccess) {
          // Lưu tokens và user info
          _accessToken = signUpResponse.accessToken;
          _refreshToken = signUpResponse.refreshToken;
          _userId = signUpResponse.userId;
          _currentUserEmail = email.toLowerCase();

          return AuthResult(
            success: true,
            message: 'Account created successfully! Login to continue.',
            requiresVerification: true,
            data: {
              'access_token': _accessToken,
              'refresh_token': _refreshToken,
              'user_id': _userId,
            },
          );
        }
      }

      // Handle error responses
      if (signUpResponse.hasError) {
        String errorMessage = signUpResponse.errorMessage ?? 'Sign up failed';

        // Custom messages for specific error codes
        if (signUpResponse.errorCode == 'USER_EMAIL_ALREADY_EXISTS') {
          errorMessage = 'Email already exists. Please login instead.';
        }

        return AuthResult(success: false, message: errorMessage);
      }

      return AuthResult(
        success: false,
        message: 'Sign up failed. Please try again.',
      );
    } catch (e) {
      // Handle network or parsing errors
      return AuthResult(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Gửi mã xác thực
  Future<AuthResult> sendVerificationCode(String email) async {
    await Future.delayed(const Duration(seconds: 2));

    // Generate random 6-digit code (mock)
    final code = '123456'; // In production, generate random code
    _verificationCodes[email.toLowerCase()] = code;

    // Mock: Print code to console (in production, send via email)
    print('📧 Verification code for $email: $code');

    return AuthResult(
      success: true,
      message: AppConstants.verificationSent,
      data: {'code': code}, // Only for demo
    );
  }

  /// Verify code
  Future<AuthResult> verifyCode(String email, String code) async {
    await Future.delayed(const Duration(seconds: 1));

    final storedCode = _verificationCodes[email.toLowerCase()];

    if (storedCode == null) {
      return AuthResult(
        success: false,
        message: 'No verification code found. Please request a new one.',
      );
    }

    if (storedCode != code) {
      return AuthResult(
        success: false,
        message: 'Invalid verification code. Please try again.',
      );
    }

    // Remove used code
    _verificationCodes.remove(email.toLowerCase());

    return AuthResult(success: true, message: AppConstants.verificationSuccess);
  }

  /// Forgot password - send reset code
  Future<AuthResult> forgotPassword(String email) async {
    await Future.delayed(const Duration(seconds: 2));

    // Kiểm tra email có tồn tại
    if (!_users.containsKey(email.toLowerCase())) {
      return AuthResult(
        success: false,
        message: 'Email not found. Please check and try again.',
      );
    }

    // Gửi code
    return await sendVerificationCode(email);
  }

  /// Reset password với code
  Future<AuthResult> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    final verifyResult = await verifyCode(email, code);
    if (!verifyResult.success) {
      return verifyResult;
    }

    // Update password
    _users[email.toLowerCase()] = newPassword;

    return AuthResult(success: true, message: 'Password reset successfully!');
  }

  /// Check if email exists
  bool isEmailRegistered(String email) {
    return _users.containsKey(email.toLowerCase());
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    // In production, check token validity, shared preferences, etc.
    await Future.delayed(const Duration(milliseconds: 500));
    return _currentUserEmail != null;
  }

  /// Get current user email
  String? getCurrentUserEmail() {
    return _currentUserEmail;
  }

  /// Get access token
  String? getAccessToken() {
    return _accessToken;
  }

  /// Get refresh token
  String? getRefreshToken() {
    return _refreshToken;
  }

  /// Get user ID
  String? getUserId() {
    return _userId;
  }

  /// Refresh Access Token - Gọi API để lấy access token mới
  Future<AuthResult> refreshAccessToken() async {
    try {
      // Kiểm tra xem có refresh token không
      if (_refreshToken == null || _refreshToken!.isEmpty) {
        return AuthResult(
          success: false,
          message: 'No refresh token available. Please login again.',
        );
      }

      // Gọi API
      final url = Uri.parse(
        '${AppConstants.apiBaseUrl}${AppConstants.refreshTokenEndpoint}',
      );
      final response = await http.post(
        url,
        headers: {
          'X-Stack-Access-Type': AppConstants.stackAccessType,
          'X-Stack-Project-Id': AppConstants.stackProjectId,
          'X-Stack-Publishable-Client-Key':
              AppConstants.stackPublishableClientKey,
          'X-Stack-Refresh-Token': _refreshToken!,
        },
      );

      // Parse response
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      final refreshResponse = RefreshTokenResponse.fromJson(responseData);

      // Xử lý response
      if (response.statusCode == 200) {
        if (refreshResponse.isSuccess) {
          // Cập nhật access token mới
          _accessToken = refreshResponse.accessToken;

          return AuthResult(
            success: true,
            message: 'Token refreshed successfully',
            data: {
              'access_token': _accessToken,
              'refresh_token': _refreshToken,
              'user_id': _userId,
            },
          );
        }
      }

      // Handle error responses
      if (refreshResponse.hasError) {
        String errorMessage =
            refreshResponse.errorMessage ?? 'Failed to refresh token';

        // Nếu refresh token hết hạn hoặc không hợp lệ, xóa session
        if (refreshResponse.errorCode == 'INVALID_REFRESH_TOKEN' ||
            refreshResponse.errorCode == 'REFRESH_TOKEN_EXPIRED') {
          await logout();
          errorMessage = 'Session expired. Please login again.';
        }

        return AuthResult(success: false, message: errorMessage);
      }

      return AuthResult(
        success: false,
        message: 'Failed to refresh token. Please login again.',
      );
    } catch (e) {
      // Handle network or parsing errors
      return AuthResult(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Logout - Gọi API để xóa session trên server và clear local data
  Future<AuthResult> logout() async {
    try {
      // Nếu không có token, chỉ clear local data
      if (_accessToken == null || _refreshToken == null) {
        _clearLocalData();
        return AuthResult(success: true, message: 'Logged out successfully');
      }

      // Gọi API DELETE để xóa session trên server
      final url = Uri.parse(
        '${AppConstants.apiBaseUrl}${AppConstants.logoutEndpoint}',
      );
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
          'X-Stack-Access-Type': AppConstants.stackAccessType,
          'X-Stack-Project-Id': AppConstants.stackProjectId,
          'X-Stack-Publishable-Client-Key':
              AppConstants.stackPublishableClientKey,
          'X-Stack-Refresh-Token': _refreshToken!,
        },
        body: jsonEncode({}),
      );

      // Dù API có thành công hay không, vẫn clear local data
      _clearLocalData();

      if (response.statusCode == 200) {
        return AuthResult(success: true, message: 'Logged out successfully');
      } else {
        // Vẫn trả về success vì đã clear local data
        return AuthResult(
          success: true,
          message: 'Logged out (local session cleared)',
        );
      }
    } catch (e) {
      // Nếu có lỗi network, vẫn clear local data
      _clearLocalData();
      return AuthResult(
        success: true,
        message: 'Logged out (local session cleared)',
      );
    }
  }

  /// Clear all local authentication data
  void _clearLocalData() {
    _currentUserEmail = null;
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    print('User logged out - all tokens cleared');
  }
}

/// Result model cho authentication operations
class AuthResult {
  final bool success;
  final String message;
  final bool requiresVerification;
  final Map<String, dynamic>? data;

  AuthResult({
    required this.success,
    required this.message,
    this.requiresVerification = false,
    this.data,
  });
}
