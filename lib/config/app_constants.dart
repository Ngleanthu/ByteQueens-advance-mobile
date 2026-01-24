class AppConstants {
  // App Info
  static const String appName = 'ByteQueens';

  // API Configuration
  static const String apiBaseUrl = 'https://auth-api.jarvis.cx/api/v1';
  static const String signUpEndpoint = '/auth/password/sign-up';
  static const String signInEndpoint = '/auth/password/sign-in';
  static const String refreshTokenEndpoint = '/auth/sessions/current/refresh';
  static const String logoutEndpoint = '/auth/sessions/current';
  static const String verificationCallbackUrl =
      'https://auth.jarvis.cx/handler/email-verification?after_auth_return_to=%2Fauth%2Fsignin%3Fclient_id%3Djarvis_chat%26redirect%3Dhttps%253A%252F%252Fchat.jarvis.cx%252Fauth%252Foauth%252Fsuccess';

  // AI Chat API Configuration
  static const String aiChatBaseUrl = 'https://api.jarvis.cx/api/v1/ai-chat';
  static const String conversationsEndpoint = '/conversations';
  static const String messagesEndpoint = '/messages';
  static const String conversationMessagesEndpoint =
      '/conversations/{conversationId}/messages';

  // Knowledge Base API Configuration
  static const String kbBaseUrl = 'https://knowledge-api.jarvis.cx/kb-core/v1';
  static const String kbAiAssistantEndpoint = '/ai-assistant';
  static const String kbAiAssistantByIdEndpoint = '/ai-assistant/{assistantId}';
  static const String kbAskBotEndpoint = '/ai-assistant/{assistantId}/ask';
  static const String kbImportKnowledgeEndpoint =
      '/ai-assistant/{assistantId}/knowledges/{knowledgeId}';
  static const String kbPublishBotEndpoint =
      '/ai-assistant/{assistantId}/publish';

  // Default AI Assistant Configuration
  static const String defaultAssistantId = 'gpt-4o-mini';
  static const String defaultAssistantModel = 'dify';
  static const String knowledgeBaseModel = 'knowledge-base';

  // Stack Auth API Keys
  static const String stackPublishableClientKey =
      'pck_7wjweasxxnfspvr20dvmyd9pjj0p9kp755bxxcm4ae1er';
  static const String stackProjectId = '45a1e2fd-77ee-4872-9fb7-987b8c119633';
  static const String stackAccessType = 'client';

  // Routes - Splash
  static const String splashRoute = '/';

  // Routes - Auth
  static const String signInRoute = '/signin';
  static const String emailLoginRoute = '/email-login';
  static const String signUpRoute = '/signup';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String verificationRoute = '/verification';

  // Routes - Main App
  static const String homeRoute = '/home';
  static const String botsListRoute = '/bots';
  static const String createBotRoute = '/bots/create';
  static const String botDetailRoute = '/bots/detail';
  static const String knowledgeBaseRoute = '/bots/knowledge';
  static const String botPreviewRoute = '/bots/preview';
  static const String botSettingsRoute = '/bots/settings';

  // Routes - Groups
  static const String groupsListRoute = '/groups';
  static const String createGroupRoute = '/groups/create';
  static const String groupDetailRoute = '/groups/detail';
  static const String groupChatRoute = '/groups/chat';

  // Routes - Chat
  static const String chatRoute = '/chat';
  static const String chatHistoryRoute = '/chat-history';

  //Routes - Prompts
  static const String promptListRoute = '/prompts';

  //Routes - Create Email
  static const String createEmailRoute = '/emails';
  
  // Routes - Subscription
  static const String pricingRoute = '/pricing';
  

  //Routes - Data
  static const String KnowledgeRoute = '/knowledges';
  // Messages - Auth
  static const String loginPrompt = 'Log in to get 50 free Credits every day';
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
  static const String forgotPasswordPrompt =
      'Enter your email to reset password';
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
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String passwordsDontMatch = 'Passwords do not match';
  static const String codeRequired = 'Please enter verification code';
  static const String codeInvalid = 'Code must be 6 digits';

  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String signUpSuccess = 'Account created successfully!';
  static const String verificationSent = 'Verification code sent to your email';
  static const String verificationSuccess = 'Email verified successfully!';
  static const String passwordResetSuccess =
      'Password reset instructions sent!';

  // Bot API Success Messages
  static const String botCreatedSuccess = 'Bot created successfully!';
  static const String botUpdatedSuccess = 'Bot updated successfully!';
  static const String botDeletedSuccess = 'Bot deleted successfully!';
  static const String knowledgeAddedSuccess = 'Knowledge added to bot!';
  static const String knowledgeRemovedSuccess = 'Knowledge removed from bot!';
  static const String botPublishedSuccess = 'Bot published successfully!';

  // Bot API Error Messages
  static const String botCreateError = 'Failed to create bot';
  static const String botUpdateError = 'Failed to update bot';
  static const String botDeleteError = 'Failed to delete bot';
  static const String botFetchError = 'Failed to fetch bots';
  static const String botNotFoundError = 'Bot not found';
  static const String knowledgeAddError = 'Failed to add knowledge to bot';
  static const String knowledgeRemoveError = 'Failed to remove knowledge';
  static const String botPublishError = 'Failed to publish bot';
  static const String chatError = 'Failed to send message';
  static const String networkError =
      'Network error. Please check your connection';
  static const String unauthorizedError = 'Unauthorized. Please login again';
  static const String serverError = 'Server error. Please try again later';

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
  static const String botNameHint =
      'Enter a name for your bot (e.g \'Customer Support Bot\')';
  static const String instructions = 'Instructions';
  static const String instructionsOptional = 'Instructions (Optional)';
  static const String instructionsHint =
      'Describe how your bot should behave and respond. Add guidelines or specific rules if needed. (e.g \'Always respond with a pirate accent\')';
  static const String knowledgeBase = 'Knowledge base';
  static const String knowledgeBaseOptional = 'Knowledge base (Optional)';
  static const String knowledgeBaseHint =
      'Enhance your bot\'s intelligence by adding relevant knowledge sources.';
  static const String addKnowledgeSource = 'Add knowledge source';
  static const String model = 'Model';
  static const String cancel = 'Cancel';
  static const String create = 'Create';
  static const String save = 'Save';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String chatNow = 'Chat Now';
  static const String noDescription = 'No description available';

  // Knowledge Sources
  static const String knowledgeSources = 'Knowledge Sources';
  static const String localFiles = 'Local files';
  static const String localFilesDesc = 'Upload PDFs, docs, and more';
  static const String website = 'Website';
  static const String websiteDesc = 'Sync any website content instantly';
  static const String googleDrive = 'Google Drive';
  static const String googleDriveDesc = 'Access your Drive files seamlessly';
  static const String slack = 'Slack';
  static const String slackDesc = 'Connect your team conversations';
  static const String confluence = 'Confluence';
  static const String confluenceDesc = 'Import your knowledge base';
  static const String notion = 'Notion';
  static const String notionDesc = 'Sync your Notion workspace';

  // Bot Detail
  static const String knowledge = 'Knowledge';
  static const String preview = 'Preview';
  static const String settings = 'Settings';
  static const String publish = 'Publish';
  static const String shareYourBot = 'Share Your Bot';
  static const String publishYourBot = 'Publish Your Bot';
  static const String publishBotDesc =
      'Make your bot available on messaging platforms';
  static const String selectPlatforms = 'Select Platforms';
  static const String publishToSlack = 'Publish to Slack';
  static const String publishToTelegram = 'Publish to Telegram';
  static const String publishToMessenger = 'Publish to Messenger';
  static const String slackWebhookUrl = 'Slack Webhook URL';
  static const String telegramBotToken = 'Telegram Bot Token';
  static const String messengerPageToken = 'Messenger Page Access Token';
  static const String webhookUrlHint = 'Enter webhook URL';
  static const String botTokenHint = 'Enter bot token';
  static const String pageTokenHint = 'Enter page access token';
  static const String publishButton = 'Publish Bot';
  static const String unpublishButton = 'Unpublish';
  static const String publishedOn = 'Published on';
  static const String searchByGroupOrEmail = 'Search by group name or email';
  static const String owner = 'Owner';
  static const String user = 'User';

  // Preview
  static const String previewTitle = 'Preview';
  static const String previewDesc =
      'Preview the assistant\'s responses in a chat interface.';
  static const String previewMode = 'Preview Mode';
  static const String testYourBot = 'Test Your Bot';
  static const String testYourBotDesc =
      'Ask questions to see how your bot responds.';
  static const String newThread = '+ New Thread';
  static const String askMeAnything =
      'Ask me anything, press \'/\' for prompts...';
  static const String startConversation = 'Start a conversation with your bot';

  // Settings
  static const String settingsTitle = 'Settings';
  static const String settingsDesc = 'Configure the assistant\'s settings.';
  static const String settingsTip =
      'Tip: Be specific about role, tone, and response format. Include what the bot should and shouldn\'t do.';

  // Knowledge Base
  static const String knowledgeBaseTitle = 'Knowledge Base';
  static const String knowledgeBaseDesc =
      'Choose a knowledge base below to add knowledge units.';
  static const String addKnowledgeUnit = '+ Add Knowledge Unit';
  static const String searchKnowledgeUnits = 'Search knowledge units...';
  static const String noKnowledgeUnits = 'No knowledge units found';
  static const String clickToAddKnowledge = 'Click here to add new knowledge';

  // Import Sources
  static const String addFiles = 'Add Files';
  static const String selectOrDrag = 'Select or drag files';
  static const String upTo5Files = 'Up to 5 files, 15MB each';
  static const String supportedFormats =
      'PDF, Word, Excel, images, code files & more';
  static const String schemaGenerationPrompt = 'Schema Generation Prompt';
  static const String schemaPromptHint =
      'Describe what data to extract (e.g., \'names, emails, phone numbers\')';
  static const String schemaPromptHelp =
      'Help the AI understand what information to extract from your files';
  static const String viewDocumentation = 'View documentation';
  static const String addFilesButton = 'Add Files';
  static const String importWebSource = 'Import Web Source';
  static const String webURL = 'Web URL';
  static const String webURLHint = 'https://example.com';
  static const String keepFilesUpdated = 'Keep Files Updated Automatically';
  static const String importType = 'Import Type';
  static const String singlePage = 'Single page';
  static const String wholeSites = 'Whole sites';
  static const String currentLimitation = 'Current Limitation:';
  static const String importGoogleDrive = 'Import Google Drive Source';
  static const String chooseFilesOrFolders = 'Choose Files or Folders';
  static const String selectGoogleDrive =
      'Please select Google Drive files or folders';
  static const String importSlack = 'Import Slack Source';
  static const String slackBotToken = 'Slack Bot Token';
  static const String slackTokenHint = 'Enter your Slack bot token';
  static const String importDiscord = 'Import Discord Source';
  static const String discordBotToken = 'Discord Bot Token';
  static const String discordTokenHint = 'Enter your Discord bot token';
  static const String back = 'Back';
  static const String import = 'Import';

  // Home/Chat
  static const String greeting = 'Hi, good evening!';
  static const String personalAssistant =
      'I\'m Jarvis, your personal assistant.';
  static const String upgradePro =
      'Upgrade to the Pro version for unlimited access with a 1-month free trial!';
  static const String orInviteFriends = 'Or invite friends to get';
  static const String freePremium = 'Free premium subscription';
  static const String startFreeTrial = 'Start Free Trial';
  static const String inviteFriends = '🎁 Invite Friends';
  static const String useOnAllPlatforms = 'Use Jarvis on all platforms';
  static const String downloadDesc =
      'Download Jarvis on your desktop, mobile, and browser.';
  static const String dontKnowPrompt = 'Don\'t know what to say? Use a prompt!';
  static const String viewAll = 'View all';
  static const String myBots = 'My Bots';
  static const String myGroups = 'My Groups';
  static const String profile = 'Profile';
  static const String logout = 'Logout';

  // Groups
  static const String groupsTitle = 'Groups';
  static const String createNewGroup = 'Create New Group';
  static const String noGroups = 'No groups found';
  static const String searchGroups = 'Search groups...';
  static const String groupName = 'Group Name';
  static const String groupNameHint =
      'Enter group name (e.g., \'Product Team\')';
  static const String groupDescription = 'Description';
  static const String groupDescriptionOptional = 'Description (Optional)';
  static const String groupDescriptionHint =
      'Enter a brief description of this group';
  static const String groupMembers = 'Members';
  static const String addMembers = 'Add Members';
  static const String selectMembers = 'Select members to add to this group';
  static const String noMembersSelected = 'No members selected';
  static const String member = 'member';
  static const String members = 'members';
  static const String messages = 'messages';
  static const String viewGroup = 'View Group';
  static const String deleteGroup = 'Delete Group';
  static const String deleteGroupConfirm =
      'Are you sure you want to delete this group?';
  static const String leaveGroup = 'Leave Group';
  static const String groupSettings = 'Group Settings';
  static const String groupChat = 'Chat';
  static const String sendMessage = 'Send a message...';
  static const String noMessages = 'No messages yet';
  static const String startChatting = 'Start a conversation with your group';

  // Profile & Settings
  static const String myProfile = 'My Profile';
  static const String accountSettings = 'Account Settings';
  static const String editProfile = 'Edit Profile';
  static const String changePassword = 'Change Password';
  static const String notifications = 'Notifications';
  static const String language = 'Language';
  static const String about = 'About';
  static const String version = 'Version';
  static const String logoutConfirm = 'Are you sure you want to logout?';
  //Email
  static const String createEmail = "Create Email";

  // Waitlist Banner
  static const String waitlistBannerTitle = "✨ New Version Coming Soon! ✨";
  static const String waitlistBannerDescription =
      "Sign up now to be the first to experience the upgraded version with breakthrough features. Completely free for waitlist members!";
  static const String joinWaitlist = "Join Waitlist Now";
  static const String waitlistSuccess =
      "🎉 Awesome! You've been added to the waitlist. We'll notify you as soon as the new version launches!";
  static const String waitlistError =
      "An error occurred. Please try again later.";

  // Calendar Booking Banner
  static const String calendarBannerTitle = "📅 Schedule Your Event";
  static const String calendarBannerDescription =
      "Book your calendar event with just one click! Select date, time, and we'll add it to your Google Calendar instantly.";
  static const String bookCalendar = "Book Calendar Event";

  // Calendar Booking Dialog
  static const String bookingDialogTitle = "Create Calendar Event";
  static const String eventTitle = "Event Title";
  static const String eventTitleHint = "Enter event title...";
  static const String eventDescription = "Description";
  static const String eventDescriptionHint = "Enter event description...";
  static const String selectDate = "Select Date";
  static const String selectTime = "Select Time";
  static const String duration = "Duration";
  static const String minutes = "minutes";
  static const String createEvent = "Create Event";
  static const String calendarSuccess =
      "🎉 Event added to your Google Calendar successfully!";
  static const String calendarError =
      "An error occurred. Please try again later.";
  static const String pleaseFillAllFields = "Please fill all required fields";

  // Google Drive Upload Banner
  static const String driveUploadBannerTitle = "☁️ Upload to Google Drive";
  static const String driveUploadBannerDescription =
      "Upload your files, PDFs, or documents to Google Drive with just one click. Easy, fast, and secure!";
  static const String uploadToDrive = "Upload to Drive";

  // Drive Upload Dialog
  static const String uploadDialogTitle = "Upload to Google Drive";
  static const String selectFile = "Select File";
  static const String noFileSelected = "No file selected";
  static const String folderName = "Folder Name (Optional)";
  static const String folderNameHint =
      "Enter folder name or leave empty for root...";
  static const String uploadFile = "Upload File";
  static const String uploading = "Uploading...";
  static const String driveUploadSuccess =
      "🎉 File uploaded to Google Drive successfully!";
  static const String driveUploadError =
      "An error occurred. Please try again later.";
  static const String pleaseSelectFile = "Please select a file to upload";
  static const String fileTooLarge = "File is too large. Maximum size is 50MB";
  static const String driveUploadSupportedFormats =
      "Supported: PDF, Images, Documents";

  // Subscription & Pricing
  static const String tokensRemaining = "tokens remaining";
  static const String unlimitedTokens = "Unlimited";
  static const String upgradeForMore = "Upgrade for more";
  static const String pricingTitle = "Choose Your Plan";
  static const String currentPlan = "Current Plan";
  static const String freePlan = "Free";
  static const String proPlan = "Pro";
  static const String monthlyBilling = "Monthly";
  static const String yearlyBilling = "Yearly";
  static const String subscribe = "Subscribe";
  static const String saveMoney = "Save 20%";

  // Mock Data (for demo)
  static const String mockEmail = 'test@jarvis.com';
  static const String mockPassword = '12345678';
  static const String mockVerificationCode = '123456';
}
