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
  String get agentRoleHrSpecialist => 'HR SPECIALIST';

  @override
  String get agentRoleFinancialExpert => 'FINANCIAL EXPERT';

  @override
  String get agentRoleAdminAssistant => 'ADMIN ASSISTANT';

  @override
  String get agentRolePlanningManager => 'PLANNING MANAGER';

  @override
  String get agentRoleCommunicationPro => 'COMMUNICATION PRO';

  @override
  String get agentDescAlpha => 'Manage employees, track leaves, and onboarding support';

  @override
  String get agentDescFinanceWizard => 'Expense tracking, invoice management, financial reports';

  @override
  String get agentDescAdminPro => 'Document management, classification, archiving';

  @override
  String get agentDescPlanningBot => 'Task management, meeting scheduling, deadlines';

  @override
  String get agentDescCommSync => 'Email management, notifications, summaries';

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
  String get privacySectionDataCollectedTitle => 'Data Collected';

  @override
  String get privacySectionDataCollectedSummary => 'What we gather';

  @override
  String get privacySectionDataCollectedContent => 'We collect: Account info (name, email), usage data, device info, and payment details.';

  @override
  String get privacySectionDataUsageTitle => 'Data Usage';

  @override
  String get privacySectionDataUsageSummary => 'How we use it';

  @override
  String get privacySectionDataUsageContent => 'We use data to provide services, personalize experience, process payments, and ensure security.';

  @override
  String get privacySectionSecurityTitle => 'Security';

  @override
  String get privacySectionSecuritySummary => 'Data protection';

  @override
  String get privacySectionSecurityContent => 'End-to-end encryption, secure SSL, regular audits, and encrypted storage.';

  @override
  String get privacySectionRightsTitle => 'Your Rights';

  @override
  String get privacySectionRightsSummary => 'GDPR compliance';

  @override
  String get privacySectionRightsContent => 'You can access, correct, delete, and export your data at any time.';

  @override
  String get privacySectionContactDpoTitle => 'Contact DPO';

  @override
  String get privacySectionContactDpoSummary => 'Privacy inquiries';

  @override
  String get privacySectionContactDpoContent => '📧 privacy@e-team.com\n📧 dpo@e-team.com';

  @override
  String get privacyDownloadSnack => 'Privacy Policy downloaded';

  @override
  String get privacyDownloadButton => 'Download Privacy Policy';

  @override
  String get privacyUnderstandButton => 'I Understand';

  @override
  String get termsTitle => 'Terms & Conditions';

  @override
  String get termsSubtitle => 'Tap sections to expand';

  @override
  String get termsBadge => 'Last updated: Feb 8, 2026';

  @override
  String get termsSectionAcceptanceTitle => 'Acceptance';

  @override
  String get termsSectionAcceptanceSummary => 'By using E-Team, you agree to these terms';

  @override
  String get termsSectionAcceptanceContent => 'By accessing E-Team, you accept these terms. If you disagree, do not use the service.';

  @override
  String get termsSectionAiUsageTitle => 'AI Usage';

  @override
  String get termsSectionAiUsageSummary => 'AI tools assist, not replace judgment';

  @override
  String get termsSectionAiUsageContent => 'AI agents assist with tasks. Results are not guaranteed. You must validate outputs and handle data securely.';

  @override
  String get termsSectionPaymentTitle => 'Payment';

  @override
  String get termsSectionPaymentSummary => 'Subscription & pay-as-you-go pricing';

  @override
  String get termsSectionPaymentContent => 'Some features require payment. Subscriptions are billed monthly/yearly. Non-refundable unless required by law.';

  @override
  String get termsSectionLiabilityTitle => 'Liability';

  @override
  String get termsSectionLiabilitySummary => 'Limited legal responsibility';

  @override
  String get termsSectionLiabilityContent => 'E-Team is not liable for indirect damages, loss of profits, or data loss.';

  @override
  String get termsSectionContactTitle => 'Contact';

  @override
  String get termsSectionContactSummary => 'Get in touch';

  @override
  String get termsSectionContactContent => '📧 support@e-team.com\n🌐 www.e-team.com';

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
