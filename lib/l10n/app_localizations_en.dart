// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'E-Team - Department as a Service';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonApply => 'Apply';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileDarkMode => 'Dark Mode';

  @override
  String get profileEditProfile => 'Edit Profile';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileTerms => 'Terms & Conditions';

  @override
  String get profilePrivacy => 'Privacy Policy';

  @override
  String get profileLogout => 'Logout';

  @override
  String get profileUserDataNotAvailable => 'User data not available';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully!';

  @override
  String get logoutDialogTitle => 'Logout';

  @override
  String get logoutDialogMessage => 'Are you sure you want to logout?';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle => 'Choose your preferred language';

  @override
  String get languageInfoBanner => 'The app language will update instantly';

  @override
  String get languageApplyButton => 'Apply Language';

  @override
  String get languageChangeDialogTitle => 'Change Language?';

  @override
  String languageChangeDialogMessage(Object language) {
    return 'The app will switch to $language.';
  }

  @override
  String languageChangedSnack(Object language) {
    return 'Language changed to $language';
  }

  @override
  String get commonPerHourShort => '/hr';

  @override
  String get commonPerMonthShort => '/mo';

  @override
  String get agentMarketplaceWelcomeBack => 'Welcome back';

  @override
  String get agentMarketplaceNoNewNotifications => 'No new notifications';

  @override
  String get agentMarketplaceTitle => 'Agent Marketplace';

  @override
  String agentMarketplaceSwipeToExplore(Object count) {
    return 'Swipe to explore $count AI agents';
  }

  @override
  String get agentMarketplaceHireAgent => 'Hire Agent';

  @override
  String get agentMarketplaceNavMarket => 'Market';

  @override
  String get agentMarketplaceNavAgents => 'Agents';

  @override
  String get agentMarketplaceNavStats => 'Stats';

  @override
  String get agentMarketplaceNavSettings => 'Settings';

  @override
  String get agentMarketplaceStatResponse => 'Response';

  @override
  String get agentMarketplaceStatAccuracy => 'Accuracy';

  @override
  String get agentMarketplaceStatLanguages => 'Languages';

  @override
  String agentMarketplacePriceFrom(Object price) {
    return 'from $price';
  }

  @override
  String get agentRoleHrSpecialist => 'Human Resources Agent';

  @override
  String get agentRoleFinancialExpert => 'Financial Agent';

  @override
  String get agentRoleAdminAssistant => 'Administrative Agent';

  @override
  String get agentRolePlanningManager => 'Planning Agent';

  @override
  String get agentRoleCommunicationPro => 'Communication Agent';

  @override
  String get agentDescAlpha => 'I am Hera, your HR guardian. I manage leave requests, approve or reject based on availability, and keep employee profiles updated automatically. I ensure everyone respects their roles and help new hires onboard smoothly. I also provide managers with clear dashboards of absences, so you always know who\'s present and who’s off.';

  @override
  String get agentDescFinanceWizard => 'I am Kash, the money master. I validate expenses, classify them into categories like transport or materials, and generate monthly financial reports automatically. I alert you if budgets are exceeded, so you stay on top of your finances effortlessly.';

  @override
  String get agentDescAdminPro => 'I am Dexo, your document wizard. I automatically classify and name files, store them in the correct categories, and manage access rights. Need a contract or invoice? I generate it for you. Want to find a document? I’ll locate it instantly.';

  @override
  String get agentDescPlanningBot => 'I am Timo, your scheduling strategist. I prevent calendar conflicts, prioritize urgent tasks, and send reminders before deadlines. I assign tasks automatically, check availability for meetings, and notify you of upcoming deadlines so nothing slips through the cracks.';

  @override
  String get agentDescCommSync => 'I am Echo, your communication assistant. I prioritize important messages, summarize long conversations, and send smart notifications. I filter out spam and keep you focused on what really matters. I can even summarize team discussions so everyone stays aligned.';

  @override
  String get agentDetailsTitle => 'Agent Profile';

  @override
  String agentDetailsShareSnack(Object agent) {
    return 'Share $agent';
  }

  @override
  String agentDetailsHires(Object hires) {
    return '($hires hires)';
  }

  @override
  String get agentDetailsStatResponse => 'RESPONSE';

  @override
  String get agentDetailsStatAccuracy => 'ACCURACY';

  @override
  String get agentDetailsStatLanguages => 'LANGUAGES';

  @override
  String get agentDetailsCoreSkills => 'CORE SKILLS';

  @override
  String get agentDetailsPerformanceEfficiency => 'PERFORMANCE EFFICIENCY';

  @override
  String get agentDetailsPerformanceThisWeek => '+12.4% this week';

  @override
  String get agentDetailsDeploymentPlans => 'DEPLOYMENT PLANS';

  @override
  String get agentDetailsPlanFreeTrial => 'Free Trial';

  @override
  String get agentDetailsPlanHourly => 'Hourly';

  @override
  String get agentDetailsPlanMonthly => 'Monthly';

  @override
  String get agentDetailsBadgeStarter => 'STARTER';

  @override
  String get agentDetailsBadgeBestValue => 'BEST VALUE';

  @override
  String get agentDetailsHireAgent => 'Hire Agent';

  @override
  String get agentDetailsHourlyPlan => 'Hourly Plan';

  @override
  String get agentDetailsMonthlyPlan => 'Monthly Plan';

  @override
  String agentDetailsAgentHiredSnack(Object agent, Object plan) {
    return '$agent hired with $plan!';
  }

  @override
  String pricingRequestsPerMonth(Object count) {
    return '$count requests/month';
  }

  @override
  String get pricingPayAsYouGo => 'Pay as you go';

  @override
  String get pricingUnlimitedHrTasks => 'Unlimited HR tasks';

  @override
  String get pricingFullFinancialSuite => 'Full financial suite';

  @override
  String get pricingCompleteAdminSupport => 'Complete admin support';

  @override
  String get pricingProjectManagementTools => 'Project management tools';

  @override
  String get pricingCommunicationAutomation => 'Communication automation';

  @override
  String get pricingFullFeaturesAccess => 'Full features access';

  @override
  String get pricingOffersTitle => 'Offers & Pricing';

  @override
  String get pricingSectionSubscriptions => 'Subscriptions';

  @override
  String get pricingSectionEnergyTopups => 'Energy top-ups';

  @override
  String get pricingOfferFreeTrial => 'Free Trial';

  @override
  String get pricingOfferBasicPlan => 'Basic Plan';

  @override
  String get pricingOfferPremiumPlan => 'Premium Plan';

  @override
  String get pricingOfferEcoPack => 'Eco Pack';

  @override
  String get pricingOfferBoostPack => 'Boost Pack';

  @override
  String pricingCreditsCount(Object count) {
    return '$count credits';
  }

  @override
  String pricingAgentsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count agents',
      one: '$count agent',
    );
    return '$_temp0';
  }

  @override
  String get pricingFreeTrialAlreadyAvailableSnack => 'Free Trial is already available.';

  @override
  String get paymentCancelledSnack => 'Payment cancelled';

  @override
  String get paymentMissingIntentId => 'Missing paymentIntentId after payment';

  @override
  String get paymentConfirmedTitle => 'Payment confirmed';

  @override
  String paymentConfirmedSubtitle(Object planName) {
    return 'Welcome to the E-Team $planName!';
  }

  @override
  String paymentFailedSnack(Object error) {
    return 'Payment failed: $error';
  }

  @override
  String get authMustBeLoggedIn => 'You must be logged in';

  @override
  String cartUnknownPackForTotal(Object total) {
    return 'Unknown pack for total: $total (expected 10, 35, 59, or 99 EUR)';
  }

  @override
  String get agentVersionAlpha => 'Version 3.2.1 • HR Certified';

  @override
  String get agentVersionFinanceWizard => 'Version 4.0.5 • Financial Expert';

  @override
  String get agentVersionAdminPro => 'Version 2.8.3 • Admin Specialist';

  @override
  String get agentVersionPlanningBot => 'Version 3.1.0 • Planning Pro';

  @override
  String get agentVersionCommSync => 'Version 2.9.2 • Communication Master';

  @override
  String get agentVersionDefault => 'Version 2.4.0 • Enterprise Ready';

  @override
  String get skillRecruitmentOnboarding => 'Recruitment & Onboarding';

  @override
  String get skillEmployeeRecords => 'Employee Records';

  @override
  String get skillPayrollManagement => 'Payroll Management';

  @override
  String get skillLeaveTracking => 'Leave Tracking';

  @override
  String get skillPerformanceReviews => 'Performance Reviews';

  @override
  String get skillInvoiceProcessing => 'Invoice Processing';

  @override
  String get skillExpenseTracking => 'Expense Tracking';

  @override
  String get skillFinancialReports => 'Financial Reports';

  @override
  String get skillBudgetPlanning => 'Budget Planning';

  @override
  String get skillTaxCompliance => 'Tax Compliance';

  @override
  String get skillDocumentManagement => 'Document Management';

  @override
  String get skillFileOrganization => 'File Organization';

  @override
  String get skillDataEntry => 'Data Entry';

  @override
  String get skillMeetingScheduling => 'Meeting Scheduling';

  @override
  String get skillEmailManagement => 'Email Management';

  @override
  String get skillProjectPlanning => 'Project Planning';

  @override
  String get skillTaskManagement => 'Task Management';

  @override
  String get skillResourceAllocation => 'Resource Allocation';

  @override
  String get skillDeadlineTracking => 'Deadline Tracking';

  @override
  String get skillTeamCoordination => 'Team Coordination';

  @override
  String get skillEmailCampaigns => 'Email Campaigns';

  @override
  String get skillTeamCommunications => 'Team Communications';

  @override
  String get skillNotifications => 'Notifications';

  @override
  String get skillAnnouncementDistribution => 'Announcement Distribution';

  @override
  String get skillChatManagement => 'Chat Management';

  @override
  String get skillNaturalLanguage => 'Natural Language';

  @override
  String get skillApiIntegration => 'API Integration';

  @override
  String get skillMultilingualSupport => 'Multi-lingual Support';

  @override
  String get skillDataAnalysis => 'Data Analysis';

  @override
  String get skillAutomation => 'Automation';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingWelcomeTo => 'Welcome to';

  @override
  String get onboardingWelcomeSubtitle => 'Your AI-powered workspace\nfor smarter decisions';

  @override
  String get onboardingSlideToStart => 'Slide to Start';

  @override
  String get onboardingExploreMarketplace => 'Explore Marketplace';

  @override
  String get onboardingChatbotTitle => 'E-Team AI';

  @override
  String onboardingChatbotQuestionLabel(Object number) {
    return 'Question $number';
  }

  @override
  String get onboardingChatbotSelectAtLeastOne => 'Please select at least one option';

  @override
  String get onboardingChatbotContinue => 'Continue';

  @override
  String get onboardingChatbotDiscoverMarketplace => 'Discover Marketplace';

  @override
  String onboardingChatbotPersonalizedRecommendations(Object recommendations) {
    return '✨ Personalized recommendations:\n\n$recommendations';
  }

  @override
  String get chatbotQRole => '👋 Nice to meet you!\n\nWhat\'s your role?';

  @override
  String get chatbotQTeamSize => 'How large is your team?';

  @override
  String get chatbotQChallenges => 'What are your biggest challenges?';

  @override
  String get chatbotQChallengesSubtitle => 'Select all that apply';

  @override
  String get chatbotQPriority => 'What\'s your #1 priority?';

  @override
  String get chatbotRoleCeoFounder => '👔 CEO / Founder';

  @override
  String get chatbotRoleManager => '📊 Manager';

  @override
  String get chatbotRoleDepartmentHead => '💼 Department Head';

  @override
  String get chatbotRoleEmployee => '👨‍💻 Employee';

  @override
  String get chatbotRoleStudent => '🎓 Student';

  @override
  String get chatbotTeamSolo => 'Solo';

  @override
  String get chatbotTeam2To5 => '2-5 people';

  @override
  String get chatbotTeam6To20 => '6-20 people';

  @override
  String get chatbotTeam21To50 => '21-50 people';

  @override
  String get chatbotTeam50Plus => '50+ people';

  @override
  String get chatbotChallengeTimeManagement => '⏰ Time management';

  @override
  String get chatbotChallengeGrowthManagement => '📈 Growth management';

  @override
  String get chatbotChallengeCostOptimization => '💰 Cost optimization';

  @override
  String get chatbotChallengeTeamCoordination => '🤝 Team coordination';

  @override
  String get chatbotChallengeDataAnalysis => '📊 Data analysis';

  @override
  String get chatbotChallengeTaskAutomation => '🔄 Task automation';

  @override
  String get chatbotPriorityProductivity => '🚀 Productivity';

  @override
  String get chatbotPriorityInnovation => '💡 Innovation';

  @override
  String get chatbotPriorityRevenueGrowth => '📈 Revenue growth';

  @override
  String get chatbotPriorityTeamDevelopment => '👥 Team development';

  @override
  String get chatbotPriorityTimeSaving => '⚡ Time saving';

  @override
  String get chatbotRecTaskAutomationAi => '🤖 Task Automation AI';

  @override
  String get chatbotRecTeamSyncAssistant => '👥 Team Sync Assistant';

  @override
  String get chatbotRecDataAnalyticsPro => '📊 Data Analytics Pro';

  @override
  String get chatbotRecSmartAssistant => '🚀 Smart Assistant';

  @override
  String get chatbotRecAnalyticsDashboard => '📊 Analytics Dashboard';

  @override
  String get commonUser => 'User';

  @override
  String get commonEmailPlaceholder => 'email@example.com';

  @override
  String get commonUserInitial => 'U';

  @override
  String get authWelcomeBackTitle => 'Welcome\nback';

  @override
  String get authWelcomeBackSnack => '✅ Welcome back!';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'name@company.com';

  @override
  String get authEmailRequired => 'Enter your email';

  @override
  String get authEmailInvalid => 'Please enter a valid email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => '••••••••';

  @override
  String get authPasswordRequired => 'Enter your password';

  @override
  String get authPasswordMin6Short => 'Min 6 characters';

  @override
  String get authPasswordMin6 => 'Password must be at least 6 characters';

  @override
  String get authRememberMe => 'Remember me';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authOr => 'or';

  @override
  String get authNewHere => 'New here? ';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authGoogleComingSoon => 'Google Sign-In coming soon!';

  @override
  String get authAppleComingSoon => 'Apple Sign-In coming soon!';

  @override
  String get authLoginNoAccount => 'No account found with this email';

  @override
  String get authLoginIncorrectPassword => 'Incorrect password';

  @override
  String get authUnableToConnect => 'Unable to connect to server';

  @override
  String get authLoginFailedTryAgain => 'Login failed. Please try again.';

  @override
  String get authCreateAccountTitle => 'Create Account';

  @override
  String get authSignupSubtitle => 'Join us to transform your business';

  @override
  String get authFullNameLabel => 'Full Name';

  @override
  String get authFullNameHint => 'John Doe';

  @override
  String get authNameRequired => 'Please enter your name';

  @override
  String get authNameMin2 => 'Name must be at least 2 characters';

  @override
  String get authConfirmPasswordLabel => 'Confirm Password';

  @override
  String get authConfirmPasswordRequired => 'Please confirm your password';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get authAcceptTermsError => 'Please accept the Terms & Conditions and Privacy Policy';

  @override
  String get authAgreeToPrefix => 'I agree to the ';

  @override
  String get authTermsAndConditions => 'Terms & Conditions';

  @override
  String get authAnd => ' and ';

  @override
  String get authPrivacyPolicy => 'Privacy Policy';

  @override
  String get authAccountCreatedCheckEmail => '✅ Account created! Check your email for verification.';

  @override
  String get authEmailAlreadyRegistered => 'This email is already registered';

  @override
  String get authConnectionTimeout => 'Connection timeout. Please try again.';

  @override
  String get authAlreadyHaveAccount => 'Already have an account? ';

  @override
  String get authForgotPasswordTitle => 'Forgot\npassword?';

  @override
  String get authForgotPasswordSubtitle => 'No worries. Enter your email and we\'ll send you a reset link.';

  @override
  String get authSendResetLink => 'Send Reset Link';

  @override
  String get authBackToLogin => 'Back to Login';

  @override
  String get authCheckYourEmailTitle => 'Check your\nemail';

  @override
  String authResetLinkSentTo(Object email) {
    return 'We sent a password reset link to\n$email';
  }

  @override
  String get authDidntReceiveResend => 'Didn\'t receive it? Resend';

  @override
  String get authVerifyYourEmailTitle => 'Verify Your Email';

  @override
  String get authWeSentCodeTo => 'We sent a verification code to';

  @override
  String get authYourEmailPlaceholder => 'your email';

  @override
  String get authVerifyEmailButton => 'Verify Email';

  @override
  String get authEnterAll6Digits => 'Please enter all 6 digits';

  @override
  String get authEmailMissing => 'Email is missing';

  @override
  String get authEmailVerifiedSuccess => '✅ Email verified successfully!';

  @override
  String get authInvalidCodeCheckEmail => 'Invalid code. Check your email.';

  @override
  String get authCodeExpiredRequestNew => 'Code expired. Request a new one.';

  @override
  String get authEmailAlreadyVerified => 'Email already verified';

  @override
  String get authNewCodeSent => '✅ New code sent! Check your email.';

  @override
  String get authDidntReceiveCode => 'Didn\'t receive the code? ';

  @override
  String authResendInSeconds(Object seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get authResendCode => 'Resend Code';

  @override
  String authErrorWithDetails(Object error) {
    return '❌ Error: $error';
  }

  @override
  String get authEditProfileTitle => 'Edit Profile';

  @override
  String get authNameLabel => 'Name';

  @override
  String get authEnterYourNameHint => 'Enter your name';

  @override
  String get authEnterYourEmailHint => 'Enter your email';

  @override
  String get authChangePassword => 'Change Password';

  @override
  String get authCurrentPassword => 'Current Password';

  @override
  String get authEnterCurrentPasswordHint => 'Enter current password';

  @override
  String get authCurrentPasswordRequired => 'Please enter current password';

  @override
  String get authNewPassword => 'New Password';

  @override
  String get authEnterNewPasswordHint => 'Enter new password';

  @override
  String get authConfirmNewPassword => 'Confirm New Password';

  @override
  String get authConfirmNewPasswordHint => 'Confirm new password';

  @override
  String get authUpdateProfileButton => 'Update Profile';

  @override
  String get authProfileUpdatedSnack => '✅ Profile updated successfully!';

  @override
  String get helpSupportTitle => 'Help & Support';

  @override
  String get helpSupportSubtitle => 'We\'re here to help';

  @override
  String get helpSupportNeedHelpTitle => 'Need Help?';

  @override
  String get helpSupportNeedHelpDesc => 'Our support team is available 24/7\nto assist you';

  @override
  String get helpSupportFaqSectionTitle => 'Frequently Asked Questions';

  @override
  String get helpSupportContactSectionTitle => 'Contact Us';

  @override
  String get helpSupportFaqHireQuestion => 'How do I hire an AI agent?';

  @override
  String get helpSupportFaqHireAnswer => 'Go to the Agent Marketplace, browse available agents, and tap \"Hire Agent\" on your preferred choice.';

  @override
  String get helpSupportFaqPaymentQuestion => 'What payment methods do you accept?';

  @override
  String get helpSupportFaqPaymentAnswer => 'We accept credit cards (Visa, Mastercard), and bank transfers for enterprise plans.';

  @override
  String get helpSupportFaqCancelQuestion => 'Can I cancel my subscription?';

  @override
  String get helpSupportFaqCancelAnswer => 'Yes, you can cancel anytime from your profile settings. Your access continues until the end of the billing period.';

  @override
  String get helpSupportFaqUpdateProfileQuestion => 'How do I update my profile?';

  @override
  String get helpSupportFaqUpdateProfileAnswer => 'Go to Profile → Edit Profile to update your name, email, or password.';

  @override
  String get helpSupportFaqDataSecureQuestion => 'Is my data secure?';

  @override
  String get helpSupportFaqDataSecureAnswer => 'Yes! We use end-to-end encryption, SSL connections, and comply with GDPR standards.';

  @override
  String get helpSupportEmailSupportTitle => 'Email Support';

  @override
  String get helpSupportEmailSupportDesc => 'We respond within 24 hours';

  @override
  String helpSupportCopiedToClipboard(Object label) {
    return '$label copied to clipboard!';
  }

  @override
  String helpSupportComingSoon(Object label) {
    return '$label - Coming soon!';
  }

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String get privacySubtitle => 'Your data is protected';

  @override
  String get privacyBadge => 'GDPR Compliant • Last updated: Feb 8, 2026';

  @override
  String get privacyIntro => 'We value your privacy and are committed to protecting your personal data.';

  @override
  String get privacySectionDataCollectedTitle => 'Information Collection';

  @override
  String get privacySectionDataCollectedSummary => 'Comprehensive data gathering practices';

  @override
  String get privacySectionDataCollectedContent => 'We collect information to provide better services to all our users. This includes: \n\n1. **Personal Information:** Name, email address, phone number, and profile picture when you create an account.\n2. **Usage Info:** We collect information about how you use our services, such as the types of content you view or engage with, the features you use, the actions you take, and the time, frequency, and duration of your activities.\n3. **Device Information:** We collect device-specific information (such as your hardware model, operating system version, unique device identifiers, and mobile network information).\n4. **Payment Information:** If you purchase our services, we collect billing address and credit card information, which is processed securely by our payment partners.';

  @override
  String get privacySectionDataUsageTitle => 'How We Use Data';

  @override
  String get privacySectionDataUsageSummary => 'Purpose of data processing';

  @override
  String get privacySectionDataUsageContent => 'We use the information we collect from all of our services for the following purposes:\n\n*   **To provide our services:** We use your information to deliver our services, such as processing your terms and authenticating you.\n*   **To maintain & improve our services:** We also use your information to ensure our services are working as intended, such as tracking outages or troubleshooting issues that you report to us.\n*   **To develop new services:** We use the information we collect in existing services to help us develop new ones.\n*   **To provide personalized services:** We use the information we collect to customize our services for you, including providing recommendations and personalized content.\n*   **To measure performance:** We use data for analytics and measurement to understand how our services are used.';

  @override
  String get privacySectionSecurityTitle => 'Data Security';

  @override
  String get privacySectionSecuritySummary => 'Roboust protection measures';

  @override
  String get privacySectionSecurityContent => 'We work hard to protect you and E-Team from unauthorized access, alteration, disclosure, or destruction of information we hold, including:\n\n*   We use encryption to keep your data private while in transit.\n*   We offer security features like 2 Step Verification to help you protect your account.\n*   We review our information collection, storage, and processing practices, including physical security measures, to prevent unauthorized access to our systems.\n*   We restrict access to personal information to E-Team employees, contractors, and agents who need that information in order to process it. Anyone with this access is subject to strict contractual confidentiality obligations and may be disciplined or terminated if they fail to meet these obligations.';

  @override
  String get privacySectionRightsTitle => 'Your Privacy Rights';

  @override
  String get privacySectionRightsSummary => 'Control over your information';

  @override
  String get privacySectionRightsContent => 'You have choices regarding the information we collect and how it\'s used. You can:\n\n*   Access and update your personal information through your account settings.\n*   Delete your account and personal information at any time.\n*   Control what information we collect through your device settings.\n*   Opt-out of promotional communications.\n*   Request a copy of your data in a machine-readable format.\n*   File a complaint with your local data protection authority if you believe your rights have been violated.';

  @override
  String get privacySectionContactDpoTitle => 'Contact Us';

  @override
  String get privacySectionContactDpoSummary => 'Get in touch regarding privacy';

  @override
  String get privacySectionContactDpoContent => 'If you have any questions about this Privacy Policy, you can contact us at:\n\n📧 **Privacy Officer:** privacy@e-team.com\n📧 **Data Protection Officer:** dpo@e-team.com\n📍 **Address:** 123 Tech Park, Innovation Way, Tunis, Tunisia';

  @override
  String get privacyDownloadSnack => 'Privacy Policy downloaded';

  @override
  String get privacyDownloadButton => 'Download Full Policy (PDF)';

  @override
  String get privacyUnderstandButton => 'I Acknowledge';

  @override
  String get termsTitle => 'Terms & Conditions';

  @override
  String get termsSubtitle => 'Please read carefully before using E-Team';

  @override
  String get termsBadge => 'Last updated: Feb 16, 2026';

  @override
  String get termsSectionAcceptanceTitle => '1. Acceptance of Terms';

  @override
  String get termsSectionAcceptanceSummary => 'Binding agreement for using E-Team';

  @override
  String get termsSectionAcceptanceContent => 'By accessing or using the E-Team mobile application (\'Service\'), you agree to be bound by these Terms. If you disagree with any part of the terms, then you may not access the Service. This agreement applies to all visitors, users, and others who access the Service. Your access to and use of the Service is conditioned on your acceptance of and compliance with these Terms.';

  @override
  String get termsSectionAiUsageTitle => '2. AI Services & Disclaimer';

  @override
  String get termsSectionAiUsageSummary => 'Limitations of Artificial Intelligence';

  @override
  String get termsSectionAiUsageContent => 'Our Service utilizes Artificial Intelligence (AI) to provide recommendations, generate content, and automate tasks.\n\n*   **No Guarantee:** While we strive for accuracy, AI-generated content may contain errors, inaccuracies, or biases. You should not rely solely on AI for critical decisions (legal, financial, medical, etc.).\n*   **User Responsibility:** You are responsible for reviewing and verifying all AI-generated outputs before using them. E-Team is not liable for any actions taken based on AI suggestions.\n*   **Data Usage for Training:** Anonymized usage data may be used to improve our AI models, consistent with our Privacy Policy.';

  @override
  String get termsSectionPaymentTitle => '3. Subscriptions & Payments';

  @override
  String get termsSectionPaymentSummary => 'Billing, renewals, and cancellations';

  @override
  String get termsSectionPaymentContent => 'Some parts of the Service are billed on a subscription basis (\'Subscription(s)\'). You will be billed in advance on a recurring and periodic basis (\'Billing Cycle\'). Billing cycles are set either on a monthly or annual basis, depending on the type of subscription plan you select when purchasing a Subscription.\n\n*   **Automatic Renewal:** Your Subscription will automatically renew at the end of each Billing Cycle unless you cancel it or E-Team cancels it.\n*   **Cancellation:** You may cancel your Subscription renewal either through your online account management page or by contacting parts of the e-team customer support team.\n*   **Refunds:** Except when required by law, paid Subscription fees are non-refundable.';

  @override
  String get termsSectionLiabilityTitle => '4. Limitation of Liability';

  @override
  String get termsSectionLiabilitySummary => 'Exclusion of damages to the extent permitted';

  @override
  String get termsSectionLiabilityContent => 'In no event shall E-Team, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from:\n\n*   Your access to or use of or inability to access or use the Service;\n*   Any conduct or content of any third party on the Service;\n*   Any content obtained from the Service;\n*   Unauthorized access, use or alteration of your transmissions or content, whether based on warranty, contract, tort (including negligence) or any other legal theory, whether or not we have been informed of the possibility of such damage.';

  @override
  String get termsSectionContactTitle => '5. Contact Information';

  @override
  String get termsSectionContactSummary => 'How to reach us for legal inquiries';

  @override
  String get termsSectionContactContent => 'If you have any questions about these Terms, please contact us:\n\n📧 **Email:** legal@e-team.com\n🌐 **Website:** www.e-team.com/legal\n📍 **Mailing:** E-Team Legal Dept, 123 Tech Park, Tunis, Tunisia';

  @override
  String get termsAcceptButton => 'I Understand & Accept';

  @override
  String get appInfoTitle => 'About E-Team';

  @override
  String get appInfoSubtitle => 'App Information';

  @override
  String get appInfoTagline => 'AI-Powered Team Management';

  @override
  String appInfoVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get appInfoAboutSectionTitle => 'About';

  @override
  String get appInfoAboutDescription => 'E-Team is an AI-powered platform that helps businesses manage their teams efficiently. With specialized AI agents for HR, Finance, Admin, Planning, and Communication, we automate repetitive tasks and boost productivity.';

  @override
  String get appInfoFeaturesTitle => 'Key Features';

  @override
  String get appInfoFeaturesSubtitle => 'What we offer';

  @override
  String get appInfoFeatureMarketplace => '🦾 AI Agent Marketplace';

  @override
  String get appInfoFeatureHr => '💼 HR Management Automation';

  @override
  String get appInfoFeatureFinancial => '💰 Financial Tools & Reports';

  @override
  String get appInfoFeatureDocs => '📁 Document Management';

  @override
  String get appInfoFeaturePlanning => '📅 Smart Planning & Scheduling';

  @override
  String get appInfoFeatureCommunication => '📧 Communication Assistant';

  @override
  String get appInfoTechTitle => 'Technology Stack';

  @override
  String get appInfoTechSubtitle => 'Built with modern tools';

  @override
  String get appInfoTechFlutter => 'Flutter - Cross-platform UI';

  @override
  String get appInfoTechNode => 'Node.js - Backend API';

  @override
  String get appInfoTechMongo => 'MongoDB - Database';

  @override
  String get appInfoTechProvider => 'Provider - State Management';

  @override
  String get appInfoTechJwt => 'JWT - Authentication';

  @override
  String get appInfoConnectWithUs => 'CONNECT WITH US';

  @override
  String get appInfoEmailLabel => 'Email';

  @override
  String get appInfoLegalTerms => 'Terms & Conditions';

  @override
  String get appInfoLegalPrivacy => 'Privacy Policy';

  @override
  String get appInfoLegalLicenses => 'Licenses';

  @override
  String get appInfoComingSoon => 'Coming soon!';

  @override
  String get appInfoLegalese => '© 2025 E-Team. All rights reserved.';

  @override
  String get appInfoCopyright => '© 2025 E-Team. All rights reserved.';

  @override
  String get appInfoMadeWith => 'Made with ❤️ in Tunisia 🇹🇳';
}
