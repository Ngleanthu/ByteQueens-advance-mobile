import 'package:bytequeens_adm/features/email/pages/create_email_page.dart';
import 'package:flutter/material.dart';
import 'package:bytequeens_adm/config/app_constants.dart';
import 'package:bytequeens_adm/features/splash/presentation/pages/splash_page.dart';
import 'package:bytequeens_adm/features/auth/presentation/pages/sign_in_page.dart';
import 'package:bytequeens_adm/features/auth/presentation/pages/email_login_page.dart';
import 'package:bytequeens_adm/features/auth/presentation/pages/sign_up_page.dart';
import 'package:bytequeens_adm/features/bot/presentation/pages/home_page.dart';
import 'package:bytequeens_adm/features/bot/presentation/pages/bots_list_page.dart';
import 'package:bytequeens_adm/features/bot/presentation/pages/create_bot_page.dart';
import 'package:bytequeens_adm/features/bot/presentation/pages/bot_detail_page.dart';
import 'package:bytequeens_adm/features/bot/presentation/pages/bot_preview_page.dart';
import 'package:bytequeens_adm/features/bot/presentation/pages/chat_page.dart';
import 'package:bytequeens_adm/features/group/presentation/pages/groups_list_page.dart';
import 'package:bytequeens_adm/features/group/presentation/pages/create_group_page.dart';
import 'package:bytequeens_adm/features/prompt/presentation/pages/prompt_list_page.dart';
import 'package:bytequeens_adm/features/subscription/presentation/pages/pricing_page.dart';

class AppRoutes {
  static const String initial = AppConstants.splashRoute;

  static Map<String, WidgetBuilder> get routes => {
    AppConstants.splashRoute: (context) => const SplashPage(),
    AppConstants.signInRoute: (context) => const SignInPage(),
    AppConstants.emailLoginRoute: (context) => const EmailLoginPage(),
    AppConstants.signUpRoute: (context) => const SignUpPage(),
    AppConstants.homeRoute: (context) => const HomePage(),
    AppConstants.botsListRoute: (context) => const BotsListPage(),
    AppConstants.createBotRoute: (context) => const CreateBotPage(),
    AppConstants.groupsListRoute: (context) => const GroupsListPage(),
    AppConstants.createGroupRoute: (context) => const CreateGroupPage(),
    AppConstants.promptListRoute: (context) => const PromptListPage(),
    AppConstants.createEmailRoute: (context) => const CreateEmailPage(),
    AppConstants.pricingRoute: (context) => const PricingPage(),
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
            builder: (context) =>
                const Scaffold(body: Center(child: Text('Bot ID required'))),
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
            builder: (context) =>
                const Scaffold(body: Center(child: Text('Bot ID required'))),
          );
        }
        return MaterialPageRoute(
          builder: (context) => BotPreviewPage(botId: botId),
          settings: settings,
        );
      case AppConstants.chatRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null ||
            args['modelId'] == null ||
            args['modelName'] == null) {
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(child: Text('Model information required')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (context) => ChatPage(
            initialMessage: '',
            modelId: args['modelId'] as String,
            modelName: args['modelName'] as String,
          ),
          settings: settings,
        );
      case AppConstants.createEmailRoute:
        return MaterialPageRoute(
          builder: (context) => const SignUpPage(),
          settings: settings,
        );
      default:
        return null;
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(child: Text('No route defined for ${settings.name}')),
      ),
    );
  }
}
