class AppConstants {
  // App Info
  static const String appName = 'ByteQueens';
  
  // Routes - Splash
  static const String splashRoute = '/';

  // Routes - Auth
  static const String signInRoute = '/signin';
  static const String emailLoginRoute = '/email-login';
  static const String signUpRoute = '/signup';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String verificationRoute = '/verification';
  
  // Auth Messages
  static const String loginPrompt = 'Log in to get started';
  static const String loginWithEmail = 'Log in with Email';
  static const String noAccountText = "Don't have an account?";
  static const String signUpText = 'Sign up for free';
  static const String termsText = 'By continuing, you agree to our';
  static const String termsOfService = 'Terms of Service';
  static const String privacyPolicy = 'Privacy Policy';
  static const String andText = 'and';
  
  // Email Login
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String loginButton = 'Log in';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String signInText = 'Sign in';
  
  // Sign Up
  static const String signUpTitle = 'Sign Up';
  static const String signUpPrompt = 'Create your account to get started';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String signUpButton = 'Sign up';
  
  // Forgot Password
  static const String forgotPasswordTitle = 'Forgot Password';
  static const String forgotPasswordPrompt = 'Enter your email to reset password';
  static const String sendCodeButton = 'Send Verification Code';
  static const String backToLogin = 'Back to Login';
  
  // Verification
  static const String verificationTitle = 'Verify Your Email';
  static const String verificationPrompt = 'We sent a verification code to';
  static const String verificationCodeLabel = 'Verification Code';
  static const String verifyButton = 'Verify';
  static const String resendCode = 'Resend Code';
  static const String didntReceiveCode = "Didn't receive the code?";
  
  // Validation Messages
  static const String emailRequired = 'Please enter your email';
  static const String emailInvalid = 'Please enter a valid email';
  static const String passwordRequired = 'Please enter your password';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordsDontMatch = 'Passwords do not match';
  static const String codeRequired = 'Please enter verification code';
  static const String codeInvalid = 'Code must be 6 digits';
  
  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String signUpSuccess = 'Account created successfully!';
  static const String verificationSent = 'Verification code sent to your email';
  static const String verificationSuccess = 'Email verified successfully!';
  static const String passwordResetSuccess = 'Password reset instructions sent!';
  
  // Mock Data (for demo)
  static const String mockEmail = 'test@bytequeens.com';
  static const String mockPassword = '123456';
  static const String mockVerificationCode = '123456';


  // Routes - Main App
  static const String homeRoute = '/home';
  static const String botsListRoute = '/bots';
  static const String createBotRoute = '/bots/create';
  static const String botDetailRoute = '/bots/detail';
  static const String knowledgeBaseRoute = '/bots/knowledge';
  static const String botPreviewRoute = '/bots/preview';
  static const String botSettingsRoute = '/bots/settings';
  
  // Bot Management
  static const String botsTitle = 'Bots';
  static const String createYourOwnBot = 'Create Your Own Bot';
  static const String noBots = 'No bots found';
  static const String searchBots = 'Search...';
  static const String allBots = 'All Bots';
  static const String favorites = 'Favorites';
  static const String sortByName = 'Sort by Name';
  static const String sortByDate = 'Sort by Date';
  static const String botName = 'Name';
  static const String botNameHint = 'Enter a name for your bot (e.g \'Customer Support Bot\')';
  static const String instructions = 'Instructions';
  static const String instructionsOptional = 'Instructions (Optional)';
  static const String instructionsHint = 'Describe how your bot should behave and respond. Add guidelines or specific rules if needed. (e.g \'Always respond with a pirate accent\')';
  static const String knowledgeBase = 'Knowledge base';
  static const String knowledgeBaseOptional = 'Knowledge base (Optional)';
  static const String knowledgeBaseHint = 'Enhance your bot\'s intelligence by adding relevant knowledge sources.';
  static const String addKnowledgeSource = 'Add knowledge source';
  static const String model = 'Model';
  static const String cancel = 'Cancel';
  static const String create = 'Create';
  static const String save = 'Save';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String chatNow = 'Chat Now';
  static const String noDescription = 'No description available';
}
