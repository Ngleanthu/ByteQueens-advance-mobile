import 'package:flutter/material.dart';
import 'package:bytequeens_adm/config/app_constants.dart';
import 'package:bytequeens_adm/features/splash/presentation/pages/splash_page.dart';
import 'package:bytequeens_adm/features/auth/presentation/pages/sign_in_page.dart';
import 'package:bytequeens_adm/features/auth/presentation/pages/email_login_page.dart';
import 'package:bytequeens_adm/features/auth/presentation/pages/sign_up_page.dart';
import 'package:bytequeens_adm/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:bytequeens_adm/features/auth/presentation/pages/verification_page.dart';
import 'package:bytequeens_adm/features/bot/presentation/pages/home_page.dart';
import 'package:bytequeens_adm/features/bot/presentation/pages/bots_list_page.dart';
import 'package:bytequeens_adm/features/bot/presentation/pages/create_bot_page.dart';
import 'package:bytequeens_adm/features/bot/presentation/pages/bot_detail_page.dart';
import 'package:bytequeens_adm/features/bot/presentation/pages/bot_preview_page.dart';

class AppRoutes {
  static const String initial = AppConstants.splashRoute;

  static Map<String, WidgetBuilder> get routes => {
    AppConstants.splashRoute: (context) => const SplashPage(),
    AppConstants.signInRoute: (context) => const SignInPage(),
    AppConstants.emailLoginRoute: (context) => const EmailLoginPage(),
    AppConstants.signUpRoute: (context) => const SignUpPage(),
    AppConstants.forgotPasswordRoute: (context) => const ForgotPasswordPage(),
    AppConstants.verificationRoute: (context) => const VerificationPage(),
    AppConstants.homeRoute: (context) => const HomePage(),
    AppConstants.botsListRoute: (context) => const BotsListPage(),
    AppConstants.createBotRoute: (context) => const CreateBotPage(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
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
      case AppConstants.homeRoute:
        return MaterialPageRoute(
          builder: (context) => const HomePage(),
          settings: settings,
        );
      case AppConstants.botsListRoute:
        return MaterialPageRoute(
          builder: (context) => const BotsListPage(),
          settings: settings,
        );
      case AppConstants.createBotRoute:
        return MaterialPageRoute(
          builder: (context) => const CreateBotPage(),
          settings: settings,
        );
      case AppConstants.botDetailRoute:
        final botId = settings.arguments as String?;
        if (botId == null) {
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(child: Text('Bot ID required')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (context) => BotDetailPage(botId: botId),
          settings: settings,
        );
      case AppConstants.botPreviewRoute:
        final botId = settings.arguments as String?;
        if (botId == null) {
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(child: Text('Bot ID required')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (context) => BotPreviewPage(botId: botId),
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
