import 'package:dio/dio.dart';
import 'package:bytequeens_adm/data/models/subscription_models.dart';
import 'package:bytequeens_adm/services/auth_service.dart';

/// Subscription Service for managing user subscriptions and token usage
class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.jarvis.cx',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  final AuthService _authService = AuthService();

  /// Get token usage for current user
  Future<TokenUsage?> getTokenUsage() async {
    try {
      final token = _authService.getAccessToken();
      if (token == null) return null;

      final response = await _dio.get(
        '/api/v1/tokens/usage',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'x-jarvis-guid': _authService.getUserId() ?? '',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return TokenUsage.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching token usage: $e');
      return null;
    }
  }

  /// Get subscription plan for current user
  Future<SubscriptionPlan?> getSubscriptionPlan() async {
    try {
      final token = _authService.getAccessToken();
      if (token == null) return null;

      final response = await _dio.get(
        '/api/v1/subscriptions/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'x-jarvis-guid': _authService.getUserId() ?? '',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return SubscriptionPlan.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching subscription plan: $e');
      return null;
    }
  }

  /// Subscribe to Pro plan (for developer testing)
  /// TEMPORARY: Using mock mode since backend endpoint needs fixing
  Future<SubscriptionResponse> subscribeToPro() async {
    // ⚠️ TEMPORARY MOCK MODE - Remove when backend is fixed
    print('⚠️  Using MOCK subscription (backend endpoint needs parameter documentation)');
    print('   Note: Token will show as unlimited and ads will be hidden immediately');
    await Future.delayed(const Duration(seconds: 1));
    return SubscriptionResponse(
      success: true,
      message: 'Successfully upgraded to Pro!\n\n✓ Unlimited tokens activated\n✓ Ad-free experience enabled\n✓ All premium features unlocked',
      data: {
        'mock': true,
        'unlimited': true,
        'isPro': true,
      },
    );
    
    /* ORIGINAL CODE - Uncomment when backend provides correct parameter:
    try {
      final token = _authService.getAccessToken();
      if (token == null) {
        return SubscriptionResponse(
          success: false,
          message: 'Please login to subscribe',
        );
      }

      print('🚀 Subscribing to Pro...');
      print('   Token: ${token.substring(0, 20)}...');
      print('   User ID: ${_authService.getUserId()}');
      
      // Backend needs to document the required parameter!
      // API spec shows no parameters but returns 400 "enum string expected"
      final response = await _dio.get(
        '/api/v1/subscriptions/subscribe',
        queryParameters: {'CORRECT_PARAM': 'CORRECT_VALUE'}, // TODO: Get from backend
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'x-jarvis-guid': _authService.getUserId() ?? '',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        return SubscriptionResponse(
          success: true,
          message: 'Successfully subscribed to Pro!',
          data: response.data,
        );
      }
      
      return SubscriptionResponse(
        success: false,
        message: 'Subscription failed',
      );
    } catch (e) {
      print('❌ Error: $e');
      return SubscriptionResponse(
        success: false,
        message: 'An error occurred: ${e.toString()}',
      );
    }
    */
  }

  /// Get combined subscription info
  Future<Map<String, dynamic>?> getFullSubscriptionInfo() async {
    try {
      final tokenUsage = await getTokenUsage();
      final plan = await getSubscriptionPlan();

      if (tokenUsage == null && plan == null) {
        return null;
      }

      return {
        'tokenUsage': tokenUsage,
        'plan': plan,
        'isPro': tokenUsage?.isPro ?? false,
      };
    } catch (e) {
      print('Error fetching full subscription info: $e');
      return null;
    }
  }
}
