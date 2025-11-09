import 'package:bytequeens_adm/config/app_constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final Map<String, String> _users = {
    AppConstants.mockEmail: AppConstants.mockPassword,
  };

  final Map<String, String> _verificationCodes = {};

  String? _currentUserEmail;

  Future<AuthResult> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    if (!_users.containsKey(email.toLowerCase())) {
      return AuthResult(
        success: false,
        message: 'Email not found. Please sign up first.',
      );
    }

    if (_users[email.toLowerCase()] != password) {
      return AuthResult(
        success: false,
        message: 'Incorrect password. Please try again.',
      );
    }

    _currentUserEmail = email.toLowerCase();

    return AuthResult(
      success: true,
      message: AppConstants.loginSuccess,
    );
  }

  /// Sign up với email và password
  Future<AuthResult> signUp(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));

    // Kiểm tra email đã tồn tại chưa
    if (_users.containsKey(email.toLowerCase())) {
      return AuthResult(
        success: false,
        message: 'Email already exists. Please login instead.',
      );
    }

    // Lưu user mới (chưa verified)
    _users[email.toLowerCase()] = password;

    return AuthResult(
      success: true,
      message: 'Account created. Please verify your email.',
      requiresVerification: true,
    );
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

    return AuthResult(
      success: true,
      message: AppConstants.verificationSuccess,
    );
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

    return AuthResult(
      success: true,
      message: 'Password reset successfully!',
    );
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

  /// Logout (clear any session data)
  void logout() {
    // In production, clear tokens, shared preferences, etc.
    _currentUserEmail = null;
    print('User logged out');
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
