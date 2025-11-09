import 'package:flutter/material.dart';
import 'package:bytequeens_adm/config/app_constants.dart';
import 'package:bytequeens_adm/features/splash/presentation/pages/splash_page.dart';
import 'package:bytequeens_adm/features/auth/presentation/pages/sign_in_page.dart';
import 'package:bytequeens_adm/features/auth/presentation/pages/email_login_page.dart';
import 'package:bytequeens_adm/features/auth/presentation/pages/sign_up_page.dart';
import 'package:bytequeens_adm/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:bytequeens_adm/features/auth/presentation/pages/verification_page.dart';

class AppRoutes {
  static const String initial = AppConstants.splashRoute;

  static Map<String, WidgetBuilder> get routes => {
    AppConstants.splashRoute: (context) => const SplashPage(),
    AppConstants.signInRoute: (context) => const SignInPage(),
    AppConstants.emailLoginRoute: (context) => const EmailLoginPage(),
    AppConstants.signUpRoute: (context) => const SignUpPage(),
    AppConstants.forgotPasswordRoute: (context) => const ForgotPasswordPage(),
    AppConstants.verificationRoute: (context) => const VerificationPage(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Xử lý các route động nếu cần
    switch (settings.name) {
      case AppConstants.splashRoute:
        return MaterialPageRoute(
          builder: (context) => const SplashPage(),
          settings: settings,
        );
      case AppConstants.signInRoute:
        return MaterialPageRoute(
          builder: (context) => const SignInPage(),
          settings: settings,
        );
      case AppConstants.emailLoginRoute:
        return MaterialPageRoute(
          builder: (context) => const EmailLoginPage(),
          settings: settings,
        );
      case AppConstants.signUpRoute:
        return MaterialPageRoute(
          builder: (context) => const SignUpPage(),
          settings: settings,
        );
      case AppConstants.forgotPasswordRoute:
        return MaterialPageRoute(
          builder: (context) => const ForgotPasswordPage(),
          settings: settings,
        );
      case AppConstants.verificationRoute:
        return MaterialPageRoute(
          builder: (context) => const VerificationPage(),
          settings: settings,
        );
      default:
        return null;
    }
  }

  
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Page Not Found'),
        ),
        body: Center(
          child: Text('No route defined for ${settings.name}'),
        ),
      ),
    );
  }
}
