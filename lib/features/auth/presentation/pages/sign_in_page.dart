import 'package:flutter/material.dart';
import 'package:bytequeens_adm/config/theme.dart';
import 'package:bytequeens_adm/config/app_constants.dart';
import 'package:bytequeens_adm/features/auth/presentation/widgets/jarvis_logo.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // ByteQueens Logo và tên
                  const JarvisLogo(size: 70, fontSize: 40),

                  const SizedBox(height: 24),

                  // Text khuyến mãi
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.lightText.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                      children: const [
                        TextSpan(text: 'Log in to get '),
                        TextSpan(
                          text: '50 free',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(text: ' Credits every day'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Card chứa nút đăng nhập
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.navyBlue.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.mediumBlue.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Nút Log in with Email
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppConstants.emailLoginRoute,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.navyBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: AppTheme.mediumBlue.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.email_outlined, size: 22),
                                SizedBox(width: 12),
                                Text(
                                  AppConstants.loginWithEmail,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Text "Don't have an account?"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppConstants.noAccountText,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.lightText.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppConstants.signUpRoute,
                                );
                              },
                              child: const Text(
                                AppConstants.signUpText,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Terms of Service và Privacy Policy
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.lightText.withValues(alpha: 0.6),
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: AppConstants.termsText + '\n'),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                // Navigate to Terms of Service
                              },
                              child: const Text(
                                AppConstants.termsOfService,
                                style: TextStyle(
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                  color: AppTheme.lightText,
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(text: ' ${AppConstants.andText} '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                // Navigate to Privacy Policy
                              },
                              child: const Text(
                                AppConstants.privacyPolicy,
                                style: TextStyle(
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                  color: AppTheme.lightText,
                                ),
                              ),
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
