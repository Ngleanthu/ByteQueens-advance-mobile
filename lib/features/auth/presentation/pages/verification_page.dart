import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bytequeens_adm/config/theme.dart';
import 'package:bytequeens_adm/config/app_constants.dart';
import 'package:bytequeens_adm/features/auth/presentation/widgets/jarvis_logo.dart';
import 'package:bytequeens_adm/services/auth_service.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _canResend = false;
  int _countdown = 30;
  Timer? _timer;
  
  String? _email;
  bool _fromSignUp = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get arguments from navigation
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _email = args['email'] as String?;
      _fromSignUp = args['fromSignUp'] as bool? ?? false;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 30;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _handleVerify() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _authService.verifyCode(
          _email ?? '',
          _codeController.text.trim(),
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (result.success) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate based on where they came from
            if (_fromSignUp) {
              // After sign up verification, go to login
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppConstants.emailLoginRoute,
                (route) => false,
              );
            } else {
              // After forgot password verification, allow them to log in
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppConstants.emailLoginRoute,
                (route) => false,
              );
            }
          } else {
            // Show error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleResendCode() async {
    if (_email == null || _email!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email not found. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.sendVerificationCode(_email!);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
            ),
          );
          _startCountdown();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
        title: const Text(
          AppConstants.verificationTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  
                  // Logo
                  const Center(
                    child: JarvisLogo(
                      size: 50,
                      fontSize: 28,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Email icon
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.email_outlined,
                        color: AppTheme.primaryBlue,
                        size: 40,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Subtitle
                  Text(
                    AppConstants.verificationPrompt,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.lightText.withValues(alpha: 0.8),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Email display
                  Text(
                    _email ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.navyBlue.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.mediumBlue.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Countdown timer
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                color: _countdown > 0 
                                    ? AppTheme.primaryBlue 
                                    : AppTheme.lightText.withValues(alpha: 0.5),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _countdown > 0 
                                    ? 'Code expires in $_countdown seconds'
                                    : 'Code expired',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _countdown > 0 
                                      ? AppTheme.primaryBlue 
                                      : AppTheme.lightText.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Code Field
                        Text(
                          AppConstants.verificationCodeLabel,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.lightText.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            letterSpacing: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: '000000',
                            counterText: '',
                            prefixIcon: Icon(
                              Icons.verified_user_outlined,
                              color: AppTheme.lightText.withValues(alpha: 0.5),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppConstants.codeRequired;
                            }
                            if (value.length != 6) {
                              return AppConstants.codeInvalid;
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Hint text
                        Text(
                          'Demo code: ${AppConstants.mockVerificationCode}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryBlue.withValues(alpha: 0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Verify Button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleVerify,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              disabledBackgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.5),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    AppConstants.verifyButton,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Resend code
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppConstants.didntReceiveCode,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.lightText.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: _canResend && !_isLoading ? _handleResendCode : null,
                              child: Text(
                                AppConstants.resendCode,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _canResend 
                                      ? AppTheme.primaryBlue 
                                      : AppTheme.lightText.withValues(alpha: 0.3),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Info box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.navyBlue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.mediumBlue.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Check your email inbox and spam folder for the verification code.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.lightText.withValues(alpha: 0.7),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
