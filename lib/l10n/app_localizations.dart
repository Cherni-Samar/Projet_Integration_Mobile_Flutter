import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'E-Team - Department as a Service'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @profileDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get profileDarkMode;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditProfile;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get profileTerms;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profilePrivacy;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @profileUserDataNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'User data not available'**
  String get profileUserDataNotAvailable;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @logoutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutDialogTitle;

  /// No description provided for @logoutDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutDialogMessage;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get languageSubtitle;

  /// No description provided for @languageInfoBanner.
  ///
  /// In en, this message translates to:
  /// **'The app language will update instantly'**
  String get languageInfoBanner;

  /// No description provided for @languageApplyButton.
  ///
  /// In en, this message translates to:
  /// **'Apply Language'**
  String get languageApplyButton;

  /// No description provided for @languageChangeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Language?'**
  String get languageChangeDialogTitle;

  /// No description provided for @languageChangeDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'The app will switch to {language}.'**
  String languageChangeDialogMessage(Object language);

  /// No description provided for @languageChangedSnack.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChangedSnack(Object language);

  /// No description provided for @commonPerHourShort.
  ///
  /// In en, this message translates to:
  /// **'/hr'**
  String get commonPerHourShort;

  /// No description provided for @commonPerMonthShort.
  ///
  /// In en, this message translates to:
  /// **'/mo'**
  String get commonPerMonthShort;

  /// No description provided for @agentMarketplaceWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get agentMarketplaceWelcomeBack;

  /// No description provided for @agentMarketplaceNoNewNotifications.
  ///
  /// In en, this message translates to:
  /// **'No new notifications'**
  String get agentMarketplaceNoNewNotifications;

  /// No description provided for @agentMarketplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Agent Marketplace'**
  String get agentMarketplaceTitle;

  /// No description provided for @agentMarketplaceSwipeToExplore.
  ///
  /// In en, this message translates to:
  /// **'Swipe to explore {count} AI agents'**
  String agentMarketplaceSwipeToExplore(Object count);

  /// No description provided for @agentMarketplaceHireAgent.
  ///
  /// In en, this message translates to:
  /// **'Hire Agent'**
  String get agentMarketplaceHireAgent;

  /// No description provided for @agentMarketplaceNavMarket.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get agentMarketplaceNavMarket;

  /// No description provided for @agentMarketplaceNavAgents.
  ///
  /// In en, this message translates to:
  /// **'Agents'**
  String get agentMarketplaceNavAgents;

  /// No description provided for @agentMarketplaceNavStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get agentMarketplaceNavStats;

  /// No description provided for @agentMarketplaceNavSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get agentMarketplaceNavSettings;

  /// No description provided for @agentMarketplaceStatResponse.
  ///
  /// In en, this message translates to:
  /// **'Response'**
  String get agentMarketplaceStatResponse;

  /// No description provided for @agentMarketplaceStatAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get agentMarketplaceStatAccuracy;

  /// No description provided for @agentMarketplaceStatLanguages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get agentMarketplaceStatLanguages;

  /// No description provided for @agentMarketplacePriceFrom.
  ///
  /// In en, this message translates to:
  /// **'from {price}'**
  String agentMarketplacePriceFrom(Object price);

  /// No description provided for @agentRoleHrSpecialist.
  ///
  /// In en, this message translates to:
  /// **'HR SPECIALIST'**
  String get agentRoleHrSpecialist;

  /// No description provided for @agentRoleFinancialExpert.
  ///
  /// In en, this message translates to:
  /// **'FINANCIAL EXPERT'**
  String get agentRoleFinancialExpert;

  /// No description provided for @agentRoleAdminAssistant.
  ///
  /// In en, this message translates to:
  /// **'ADMIN ASSISTANT'**
  String get agentRoleAdminAssistant;

  /// No description provided for @agentRolePlanningManager.
  ///
  /// In en, this message translates to:
  /// **'PLANNING MANAGER'**
  String get agentRolePlanningManager;

  /// No description provided for @agentRoleCommunicationPro.
  ///
  /// In en, this message translates to:
  /// **'COMMUNICATION PRO'**
  String get agentRoleCommunicationPro;

  /// No description provided for @agentDescAlpha.
  ///
  /// In en, this message translates to:
  /// **'Manage employees, track leaves, and onboarding support'**
  String get agentDescAlpha;

  /// No description provided for @agentDescFinanceWizard.
  ///
  /// In en, this message translates to:
  /// **'Expense tracking, invoice management, financial reports'**
  String get agentDescFinanceWizard;

  /// No description provided for @agentDescAdminPro.
  ///
  /// In en, this message translates to:
  /// **'Document management, classification, archiving'**
  String get agentDescAdminPro;

  /// No description provided for @agentDescPlanningBot.
  ///
  /// In en, this message translates to:
  /// **'Task management, meeting scheduling, deadlines'**
  String get agentDescPlanningBot;

  /// No description provided for @agentDescCommSync.
  ///
  /// In en, this message translates to:
  /// **'Email management, notifications, summaries'**
  String get agentDescCommSync;

  /// No description provided for @agentDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Agent Profile'**
  String get agentDetailsTitle;

  /// No description provided for @agentDetailsShareSnack.
  ///
  /// In en, this message translates to:
  /// **'Share {agent}'**
  String agentDetailsShareSnack(Object agent);

  /// No description provided for @agentDetailsHires.
  ///
  /// In en, this message translates to:
  /// **'({hires} hires)'**
  String agentDetailsHires(Object hires);

  /// No description provided for @agentDetailsStatResponse.
  ///
  /// In en, this message translates to:
  /// **'RESPONSE'**
  String get agentDetailsStatResponse;

  /// No description provided for @agentDetailsStatAccuracy.
  ///
  /// In en, this message translates to:
  /// **'ACCURACY'**
  String get agentDetailsStatAccuracy;

  /// No description provided for @agentDetailsStatLanguages.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGES'**
  String get agentDetailsStatLanguages;

  /// No description provided for @agentDetailsCoreSkills.
  ///
  /// In en, this message translates to:
  /// **'CORE SKILLS'**
  String get agentDetailsCoreSkills;

  /// No description provided for @agentDetailsPerformanceEfficiency.
  ///
  /// In en, this message translates to:
  /// **'PERFORMANCE EFFICIENCY'**
  String get agentDetailsPerformanceEfficiency;

  /// No description provided for @agentDetailsPerformanceThisWeek.
  ///
  /// In en, this message translates to:
  /// **'+12.4% this week'**
  String get agentDetailsPerformanceThisWeek;

  /// No description provided for @agentDetailsDeploymentPlans.
  ///
  /// In en, this message translates to:
  /// **'DEPLOYMENT PLANS'**
  String get agentDetailsDeploymentPlans;

  /// No description provided for @agentDetailsPlanFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Free Trial'**
  String get agentDetailsPlanFreeTrial;

  /// No description provided for @agentDetailsPlanHourly.
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get agentDetailsPlanHourly;

  /// No description provided for @agentDetailsPlanMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get agentDetailsPlanMonthly;

  /// No description provided for @agentDetailsBadgeStarter.
  ///
  /// In en, this message translates to:
  /// **'STARTER'**
  String get agentDetailsBadgeStarter;

  /// No description provided for @agentDetailsBadgeBestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get agentDetailsBadgeBestValue;

  /// No description provided for @agentDetailsHireAgent.
  ///
  /// In en, this message translates to:
  /// **'Hire Agent'**
  String get agentDetailsHireAgent;

  /// No description provided for @agentDetailsHourlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Hourly Plan'**
  String get agentDetailsHourlyPlan;

  /// No description provided for @agentDetailsMonthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly Plan'**
  String get agentDetailsMonthlyPlan;

  /// No description provided for @agentDetailsAgentHiredSnack.
  ///
  /// In en, this message translates to:
  /// **'{agent} hired with {plan}!'**
  String agentDetailsAgentHiredSnack(Object agent, Object plan);

  /// No description provided for @pricingRequestsPerMonth.
  ///
  /// In en, this message translates to:
  /// **'{count} requests/month'**
  String pricingRequestsPerMonth(Object count);

  /// No description provided for @pricingPayAsYouGo.
  ///
  /// In en, this message translates to:
  /// **'Pay as you go'**
  String get pricingPayAsYouGo;

  /// No description provided for @pricingUnlimitedHrTasks.
  ///
  /// In en, this message translates to:
  /// **'Unlimited HR tasks'**
  String get pricingUnlimitedHrTasks;

  /// No description provided for @pricingFullFinancialSuite.
  ///
  /// In en, this message translates to:
  /// **'Full financial suite'**
  String get pricingFullFinancialSuite;

  /// No description provided for @pricingCompleteAdminSupport.
  ///
  /// In en, this message translates to:
  /// **'Complete admin support'**
  String get pricingCompleteAdminSupport;

  /// No description provided for @pricingProjectManagementTools.
  ///
  /// In en, this message translates to:
  /// **'Project management tools'**
  String get pricingProjectManagementTools;

  /// No description provided for @pricingCommunicationAutomation.
  ///
  /// In en, this message translates to:
  /// **'Communication automation'**
  String get pricingCommunicationAutomation;

  /// No description provided for @pricingFullFeaturesAccess.
  ///
  /// In en, this message translates to:
  /// **'Full features access'**
  String get pricingFullFeaturesAccess;

  /// No description provided for @agentVersionAlpha.
  ///
  /// In en, this message translates to:
  /// **'Version 3.2.1 • HR Certified'**
  String get agentVersionAlpha;

  /// No description provided for @agentVersionFinanceWizard.
  ///
  /// In en, this message translates to:
  /// **'Version 4.0.5 • Financial Expert'**
  String get agentVersionFinanceWizard;

  /// No description provided for @agentVersionAdminPro.
  ///
  /// In en, this message translates to:
  /// **'Version 2.8.3 • Admin Specialist'**
  String get agentVersionAdminPro;

  /// No description provided for @agentVersionPlanningBot.
  ///
  /// In en, this message translates to:
  /// **'Version 3.1.0 • Planning Pro'**
  String get agentVersionPlanningBot;

  /// No description provided for @agentVersionCommSync.
  ///
  /// In en, this message translates to:
  /// **'Version 2.9.2 • Communication Master'**
  String get agentVersionCommSync;

  /// No description provided for @agentVersionDefault.
  ///
  /// In en, this message translates to:
  /// **'Version 2.4.0 • Enterprise Ready'**
  String get agentVersionDefault;

  /// No description provided for @skillRecruitmentOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Recruitment & Onboarding'**
  String get skillRecruitmentOnboarding;

  /// No description provided for @skillEmployeeRecords.
  ///
  /// In en, this message translates to:
  /// **'Employee Records'**
  String get skillEmployeeRecords;

  /// No description provided for @skillPayrollManagement.
  ///
  /// In en, this message translates to:
  /// **'Payroll Management'**
  String get skillPayrollManagement;

  /// No description provided for @skillLeaveTracking.
  ///
  /// In en, this message translates to:
  /// **'Leave Tracking'**
  String get skillLeaveTracking;

  /// No description provided for @skillPerformanceReviews.
  ///
  /// In en, this message translates to:
  /// **'Performance Reviews'**
  String get skillPerformanceReviews;

  /// No description provided for @skillInvoiceProcessing.
  ///
  /// In en, this message translates to:
  /// **'Invoice Processing'**
  String get skillInvoiceProcessing;

  /// No description provided for @skillExpenseTracking.
  ///
  /// In en, this message translates to:
  /// **'Expense Tracking'**
  String get skillExpenseTracking;

  /// No description provided for @skillFinancialReports.
  ///
  /// In en, this message translates to:
  /// **'Financial Reports'**
  String get skillFinancialReports;

  /// No description provided for @skillBudgetPlanning.
  ///
  /// In en, this message translates to:
  /// **'Budget Planning'**
  String get skillBudgetPlanning;

  /// No description provided for @skillTaxCompliance.
  ///
  /// In en, this message translates to:
  /// **'Tax Compliance'**
  String get skillTaxCompliance;

  /// No description provided for @skillDocumentManagement.
  ///
  /// In en, this message translates to:
  /// **'Document Management'**
  String get skillDocumentManagement;

  /// No description provided for @skillFileOrganization.
  ///
  /// In en, this message translates to:
  /// **'File Organization'**
  String get skillFileOrganization;

  /// No description provided for @skillDataEntry.
  ///
  /// In en, this message translates to:
  /// **'Data Entry'**
  String get skillDataEntry;

  /// No description provided for @skillMeetingScheduling.
  ///
  /// In en, this message translates to:
  /// **'Meeting Scheduling'**
  String get skillMeetingScheduling;

  /// No description provided for @skillEmailManagement.
  ///
  /// In en, this message translates to:
  /// **'Email Management'**
  String get skillEmailManagement;

  /// No description provided for @skillProjectPlanning.
  ///
  /// In en, this message translates to:
  /// **'Project Planning'**
  String get skillProjectPlanning;

  /// No description provided for @skillTaskManagement.
  ///
  /// In en, this message translates to:
  /// **'Task Management'**
  String get skillTaskManagement;

  /// No description provided for @skillResourceAllocation.
  ///
  /// In en, this message translates to:
  /// **'Resource Allocation'**
  String get skillResourceAllocation;

  /// No description provided for @skillDeadlineTracking.
  ///
  /// In en, this message translates to:
  /// **'Deadline Tracking'**
  String get skillDeadlineTracking;

  /// No description provided for @skillTeamCoordination.
  ///
  /// In en, this message translates to:
  /// **'Team Coordination'**
  String get skillTeamCoordination;

  /// No description provided for @skillEmailCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Email Campaigns'**
  String get skillEmailCampaigns;

  /// No description provided for @skillTeamCommunications.
  ///
  /// In en, this message translates to:
  /// **'Team Communications'**
  String get skillTeamCommunications;

  /// No description provided for @skillNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get skillNotifications;

  /// No description provided for @skillAnnouncementDistribution.
  ///
  /// In en, this message translates to:
  /// **'Announcement Distribution'**
  String get skillAnnouncementDistribution;

  /// No description provided for @skillChatManagement.
  ///
  /// In en, this message translates to:
  /// **'Chat Management'**
  String get skillChatManagement;

  /// No description provided for @skillNaturalLanguage.
  ///
  /// In en, this message translates to:
  /// **'Natural Language'**
  String get skillNaturalLanguage;

  /// No description provided for @skillApiIntegration.
  ///
  /// In en, this message translates to:
  /// **'API Integration'**
  String get skillApiIntegration;

  /// No description provided for @skillMultilingualSupport.
  ///
  /// In en, this message translates to:
  /// **'Multi-lingual Support'**
  String get skillMultilingualSupport;

  /// No description provided for @skillDataAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Data Analysis'**
  String get skillDataAnalysis;

  /// No description provided for @skillAutomation.
  ///
  /// In en, this message translates to:
  /// **'Automation'**
  String get skillAutomation;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingWelcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get onboardingWelcomeTo;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your AI-powered workspace\nfor smarter decisions'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingSlideToStart.
  ///
  /// In en, this message translates to:
  /// **'Slide to Start'**
  String get onboardingSlideToStart;

  /// No description provided for @onboardingExploreMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Explore Marketplace'**
  String get onboardingExploreMarketplace;

  /// No description provided for @onboardingChatbotTitle.
  ///
  /// In en, this message translates to:
  /// **'E-Team AI'**
  String get onboardingChatbotTitle;

  /// No description provided for @onboardingChatbotQuestionLabel.
  ///
  /// In en, this message translates to:
  /// **'Question {number}'**
  String onboardingChatbotQuestionLabel(Object number);

  /// No description provided for @onboardingChatbotSelectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one option'**
  String get onboardingChatbotSelectAtLeastOne;

  /// No description provided for @onboardingChatbotContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingChatbotContinue;

  /// No description provided for @onboardingChatbotDiscoverMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Discover Marketplace'**
  String get onboardingChatbotDiscoverMarketplace;

  /// No description provided for @onboardingChatbotPersonalizedRecommendations.
  ///
  /// In en, this message translates to:
  /// **'✨ Personalized recommendations:\n\n{recommendations}'**
  String onboardingChatbotPersonalizedRecommendations(Object recommendations);

  /// No description provided for @chatbotQRole.
  ///
  /// In en, this message translates to:
  /// **'👋 Nice to meet you!\n\nWhat\'s your role?'**
  String get chatbotQRole;

  /// No description provided for @chatbotQTeamSize.
  ///
  /// In en, this message translates to:
  /// **'How large is your team?'**
  String get chatbotQTeamSize;

  /// No description provided for @chatbotQChallenges.
  ///
  /// In en, this message translates to:
  /// **'What are your biggest challenges?'**
  String get chatbotQChallenges;

  /// No description provided for @chatbotQChallengesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply'**
  String get chatbotQChallengesSubtitle;

  /// No description provided for @chatbotQPriority.
  ///
  /// In en, this message translates to:
  /// **'What\'s your #1 priority?'**
  String get chatbotQPriority;

  /// No description provided for @chatbotRoleCeoFounder.
  ///
  /// In en, this message translates to:
  /// **'👔 CEO / Founder'**
  String get chatbotRoleCeoFounder;

  /// No description provided for @chatbotRoleManager.
  ///
  /// In en, this message translates to:
  /// **'📊 Manager'**
  String get chatbotRoleManager;

  /// No description provided for @chatbotRoleDepartmentHead.
  ///
  /// In en, this message translates to:
  /// **'💼 Department Head'**
  String get chatbotRoleDepartmentHead;

  /// No description provided for @chatbotRoleEmployee.
  ///
  /// In en, this message translates to:
  /// **'👨‍💻 Employee'**
  String get chatbotRoleEmployee;

  /// No description provided for @chatbotRoleStudent.
  ///
  /// In en, this message translates to:
  /// **'🎓 Student'**
  String get chatbotRoleStudent;

  /// No description provided for @chatbotTeamSolo.
  ///
  /// In en, this message translates to:
  /// **'Solo'**
  String get chatbotTeamSolo;

  /// No description provided for @chatbotTeam2To5.
  ///
  /// In en, this message translates to:
  /// **'2-5 people'**
  String get chatbotTeam2To5;

  /// No description provided for @chatbotTeam6To20.
  ///
  /// In en, this message translates to:
  /// **'6-20 people'**
  String get chatbotTeam6To20;

  /// No description provided for @chatbotTeam21To50.
  ///
  /// In en, this message translates to:
  /// **'21-50 people'**
  String get chatbotTeam21To50;

  /// No description provided for @chatbotTeam50Plus.
  ///
  /// In en, this message translates to:
  /// **'50+ people'**
  String get chatbotTeam50Plus;

  /// No description provided for @chatbotChallengeTimeManagement.
  ///
  /// In en, this message translates to:
  /// **'⏰ Time management'**
  String get chatbotChallengeTimeManagement;

  /// No description provided for @chatbotChallengeGrowthManagement.
  ///
  /// In en, this message translates to:
  /// **'📈 Growth management'**
  String get chatbotChallengeGrowthManagement;

  /// No description provided for @chatbotChallengeCostOptimization.
  ///
  /// In en, this message translates to:
  /// **'💰 Cost optimization'**
  String get chatbotChallengeCostOptimization;

  /// No description provided for @chatbotChallengeTeamCoordination.
  ///
  /// In en, this message translates to:
  /// **'🤝 Team coordination'**
  String get chatbotChallengeTeamCoordination;

  /// No description provided for @chatbotChallengeDataAnalysis.
  ///
  /// In en, this message translates to:
  /// **'📊 Data analysis'**
  String get chatbotChallengeDataAnalysis;

  /// No description provided for @chatbotChallengeTaskAutomation.
  ///
  /// In en, this message translates to:
  /// **'🔄 Task automation'**
  String get chatbotChallengeTaskAutomation;

  /// No description provided for @chatbotPriorityProductivity.
  ///
  /// In en, this message translates to:
  /// **'🚀 Productivity'**
  String get chatbotPriorityProductivity;

  /// No description provided for @chatbotPriorityInnovation.
  ///
  /// In en, this message translates to:
  /// **'💡 Innovation'**
  String get chatbotPriorityInnovation;

  /// No description provided for @chatbotPriorityRevenueGrowth.
  ///
  /// In en, this message translates to:
  /// **'📈 Revenue growth'**
  String get chatbotPriorityRevenueGrowth;

  /// No description provided for @chatbotPriorityTeamDevelopment.
  ///
  /// In en, this message translates to:
  /// **'👥 Team development'**
  String get chatbotPriorityTeamDevelopment;

  /// No description provided for @chatbotPriorityTimeSaving.
  ///
  /// In en, this message translates to:
  /// **'⚡ Time saving'**
  String get chatbotPriorityTimeSaving;

  /// No description provided for @chatbotRecTaskAutomationAi.
  ///
  /// In en, this message translates to:
  /// **'🤖 Task Automation AI'**
  String get chatbotRecTaskAutomationAi;

  /// No description provided for @chatbotRecTeamSyncAssistant.
  ///
  /// In en, this message translates to:
  /// **'👥 Team Sync Assistant'**
  String get chatbotRecTeamSyncAssistant;

  /// No description provided for @chatbotRecDataAnalyticsPro.
  ///
  /// In en, this message translates to:
  /// **'📊 Data Analytics Pro'**
  String get chatbotRecDataAnalyticsPro;

  /// No description provided for @chatbotRecSmartAssistant.
  ///
  /// In en, this message translates to:
  /// **'🚀 Smart Assistant'**
  String get chatbotRecSmartAssistant;

  /// No description provided for @chatbotRecAnalyticsDashboard.
  ///
  /// In en, this message translates to:
  /// **'📊 Analytics Dashboard'**
  String get chatbotRecAnalyticsDashboard;

  /// No description provided for @commonUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get commonUser;

  /// No description provided for @commonEmailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'email@example.com'**
  String get commonEmailPlaceholder;

  /// No description provided for @commonUserInitial.
  ///
  /// In en, this message translates to:
  /// **'U'**
  String get commonUserInitial;

  /// No description provided for @authWelcomeBackTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome\nback'**
  String get authWelcomeBackTitle;

  /// No description provided for @authWelcomeBackSnack.
  ///
  /// In en, this message translates to:
  /// **'✅ Welcome back!'**
  String get authWelcomeBackSnack;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'name@company.com'**
  String get authEmailHint;

  /// No description provided for @authEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get authPasswordHint;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordMin6Short.
  ///
  /// In en, this message translates to:
  /// **'Min 6 characters'**
  String get authPasswordMin6Short;

  /// No description provided for @authPasswordMin6.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get authPasswordMin6;

  /// No description provided for @authRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get authRememberMe;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOr;

  /// No description provided for @authNewHere.
  ///
  /// In en, this message translates to:
  /// **'New here? '**
  String get authNewHere;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authGoogleComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In coming soon!'**
  String get authGoogleComingSoon;

  /// No description provided for @authAppleComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Apple Sign-In coming soon!'**
  String get authAppleComingSoon;

  /// No description provided for @authLoginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email'**
  String get authLoginNoAccount;

  /// No description provided for @authLoginIncorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get authLoginIncorrectPassword;

  /// No description provided for @authUnableToConnect.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to server'**
  String get authUnableToConnect;

  /// No description provided for @authLoginFailedTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get authLoginFailedTryAgain;

  /// No description provided for @authCreateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccountTitle;

  /// No description provided for @authSignupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join us to transform your business'**
  String get authSignupSubtitle;

  /// No description provided for @authFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get authFullNameLabel;

  /// No description provided for @authFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get authFullNameHint;

  /// No description provided for @authNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get authNameRequired;

  /// No description provided for @authNameMin2.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get authNameMin2;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get authConfirmPasswordRequired;

  /// No description provided for @authPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authPasswordsDoNotMatch;

  /// No description provided for @authAcceptTermsError.
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms & Conditions and Privacy Policy'**
  String get authAcceptTermsError;

  /// No description provided for @authAgreeToPrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get authAgreeToPrefix;

  /// No description provided for @authTermsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get authTermsAndConditions;

  /// No description provided for @authAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get authAnd;

  /// No description provided for @authPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get authPrivacyPolicy;

  /// No description provided for @authAccountCreatedCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'✅ Account created! Check your email for verification.'**
  String get authAccountCreatedCheckEmail;

  /// No description provided for @authEmailAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get authEmailAlreadyRegistered;

  /// No description provided for @authConnectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timeout. Please try again.'**
  String get authConnectionTimeout;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get authAlreadyHaveAccount;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot\npassword?'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No worries. Enter your email and we\'ll send you a reset link.'**
  String get authForgotPasswordSubtitle;

  /// No description provided for @authSendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get authSendResetLink;

  /// No description provided for @authBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get authBackToLogin;

  /// No description provided for @authCheckYourEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your\nemail'**
  String get authCheckYourEmailTitle;

  /// No description provided for @authResetLinkSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a password reset link to\n{email}'**
  String authResetLinkSentTo(Object email);

  /// No description provided for @authDidntReceiveResend.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive it? Resend'**
  String get authDidntReceiveResend;

  /// No description provided for @authVerifyYourEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get authVerifyYourEmailTitle;

  /// No description provided for @authWeSentCodeTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to'**
  String get authWeSentCodeTo;

  /// No description provided for @authYourEmailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'your email'**
  String get authYourEmailPlaceholder;

  /// No description provided for @authVerifyEmailButton.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get authVerifyEmailButton;

  /// No description provided for @authEnterAll6Digits.
  ///
  /// In en, this message translates to:
  /// **'Please enter all 6 digits'**
  String get authEnterAll6Digits;

  /// No description provided for @authEmailMissing.
  ///
  /// In en, this message translates to:
  /// **'Email is missing'**
  String get authEmailMissing;

  /// No description provided for @authEmailVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'✅ Email verified successfully!'**
  String get authEmailVerifiedSuccess;

  /// No description provided for @authInvalidCodeCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid code. Check your email.'**
  String get authInvalidCodeCheckEmail;

  /// No description provided for @authCodeExpiredRequestNew.
  ///
  /// In en, this message translates to:
  /// **'Code expired. Request a new one.'**
  String get authCodeExpiredRequestNew;

  /// No description provided for @authEmailAlreadyVerified.
  ///
  /// In en, this message translates to:
  /// **'Email already verified'**
  String get authEmailAlreadyVerified;

  /// No description provided for @authNewCodeSent.
  ///
  /// In en, this message translates to:
  /// **'✅ New code sent! Check your email.'**
  String get authNewCodeSent;

  /// No description provided for @authDidntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code? '**
  String get authDidntReceiveCode;

  /// No description provided for @authResendInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String authResendInSeconds(Object seconds);

  /// No description provided for @authResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get authResendCode;

  /// No description provided for @authErrorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'❌ Error: {error}'**
  String authErrorWithDetails(Object error);

  /// No description provided for @authEditProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get authEditProfileTitle;

  /// No description provided for @authNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get authNameLabel;

  /// No description provided for @authEnterYourNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get authEnterYourNameHint;

  /// No description provided for @authEnterYourEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get authEnterYourEmailHint;

  /// No description provided for @authChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get authChangePassword;

  /// No description provided for @authCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get authCurrentPassword;

  /// No description provided for @authEnterCurrentPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get authEnterCurrentPasswordHint;

  /// No description provided for @authCurrentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter current password'**
  String get authCurrentPasswordRequired;

  /// No description provided for @authNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get authNewPassword;

  /// No description provided for @authEnterNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get authEnterNewPasswordHint;

  /// No description provided for @authConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get authConfirmNewPassword;

  /// No description provided for @authConfirmNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get authConfirmNewPasswordHint;

  /// No description provided for @authUpdateProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get authUpdateProfileButton;

  /// No description provided for @authProfileUpdatedSnack.
  ///
  /// In en, this message translates to:
  /// **'✅ Profile updated successfully!'**
  String get authProfileUpdatedSnack;

  /// No description provided for @helpSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupportTitle;

  /// No description provided for @helpSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help'**
  String get helpSupportSubtitle;

  /// No description provided for @helpSupportNeedHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get helpSupportNeedHelpTitle;

  /// No description provided for @helpSupportNeedHelpDesc.
  ///
  /// In en, this message translates to:
  /// **'Our support team is available 24/7\nto assist you'**
  String get helpSupportNeedHelpDesc;

  /// No description provided for @helpSupportFaqSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get helpSupportFaqSectionTitle;

  /// No description provided for @helpSupportContactSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get helpSupportContactSectionTitle;

  /// No description provided for @helpSupportFaqHireQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do I hire an AI agent?'**
  String get helpSupportFaqHireQuestion;

  /// No description provided for @helpSupportFaqHireAnswer.
  ///
  /// In en, this message translates to:
  /// **'Go to the Agent Marketplace, browse available agents, and tap \"Hire Agent\" on your preferred choice.'**
  String get helpSupportFaqHireAnswer;

  /// No description provided for @helpSupportFaqPaymentQuestion.
  ///
  /// In en, this message translates to:
  /// **'What payment methods do you accept?'**
  String get helpSupportFaqPaymentQuestion;

  /// No description provided for @helpSupportFaqPaymentAnswer.
  ///
  /// In en, this message translates to:
  /// **'We accept credit cards (Visa, Mastercard), and bank transfers for enterprise plans.'**
  String get helpSupportFaqPaymentAnswer;

  /// No description provided for @helpSupportFaqCancelQuestion.
  ///
  /// In en, this message translates to:
  /// **'Can I cancel my subscription?'**
  String get helpSupportFaqCancelQuestion;

  /// No description provided for @helpSupportFaqCancelAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, you can cancel anytime from your profile settings. Your access continues until the end of the billing period.'**
  String get helpSupportFaqCancelAnswer;

  /// No description provided for @helpSupportFaqUpdateProfileQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do I update my profile?'**
  String get helpSupportFaqUpdateProfileQuestion;

  /// No description provided for @helpSupportFaqUpdateProfileAnswer.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile → Edit Profile to update your name, email, or password.'**
  String get helpSupportFaqUpdateProfileAnswer;

  /// No description provided for @helpSupportFaqDataSecureQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is my data secure?'**
  String get helpSupportFaqDataSecureQuestion;

  /// No description provided for @helpSupportFaqDataSecureAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes! We use end-to-end encryption, SSL connections, and comply with GDPR standards.'**
  String get helpSupportFaqDataSecureAnswer;

  /// No description provided for @helpSupportEmailSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get helpSupportEmailSupportTitle;

  /// No description provided for @helpSupportEmailSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'We respond within 24 hours'**
  String get helpSupportEmailSupportDesc;

  /// No description provided for @helpSupportCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'{label} copied to clipboard!'**
  String helpSupportCopiedToClipboard(Object label);

  /// No description provided for @helpSupportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{label} - Coming soon!'**
  String helpSupportComingSoon(Object label);

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// No description provided for @privacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your data is protected'**
  String get privacySubtitle;

  /// No description provided for @privacyBadge.
  ///
  /// In en, this message translates to:
  /// **'GDPR Compliant • Last updated: Feb 8, 2026'**
  String get privacyBadge;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'We value your privacy and are committed to protecting your personal data.'**
  String get privacyIntro;

  /// No description provided for @privacySectionDataCollectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Collected'**
  String get privacySectionDataCollectedTitle;

  /// No description provided for @privacySectionDataCollectedSummary.
  ///
  /// In en, this message translates to:
  /// **'What we gather'**
  String get privacySectionDataCollectedSummary;

  /// No description provided for @privacySectionDataCollectedContent.
  ///
  /// In en, this message translates to:
  /// **'We collect: Account info (name, email), usage data, device info, and payment details.'**
  String get privacySectionDataCollectedContent;

  /// No description provided for @privacySectionDataUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Usage'**
  String get privacySectionDataUsageTitle;

  /// No description provided for @privacySectionDataUsageSummary.
  ///
  /// In en, this message translates to:
  /// **'How we use it'**
  String get privacySectionDataUsageSummary;

  /// No description provided for @privacySectionDataUsageContent.
  ///
  /// In en, this message translates to:
  /// **'We use data to provide services, personalize experience, process payments, and ensure security.'**
  String get privacySectionDataUsageContent;

  /// No description provided for @privacySectionSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get privacySectionSecurityTitle;

  /// No description provided for @privacySectionSecuritySummary.
  ///
  /// In en, this message translates to:
  /// **'Data protection'**
  String get privacySectionSecuritySummary;

  /// No description provided for @privacySectionSecurityContent.
  ///
  /// In en, this message translates to:
  /// **'End-to-end encryption, secure SSL, regular audits, and encrypted storage.'**
  String get privacySectionSecurityContent;

  /// No description provided for @privacySectionRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get privacySectionRightsTitle;

  /// No description provided for @privacySectionRightsSummary.
  ///
  /// In en, this message translates to:
  /// **'GDPR compliance'**
  String get privacySectionRightsSummary;

  /// No description provided for @privacySectionRightsContent.
  ///
  /// In en, this message translates to:
  /// **'You can access, correct, delete, and export your data at any time.'**
  String get privacySectionRightsContent;

  /// No description provided for @privacySectionContactDpoTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact DPO'**
  String get privacySectionContactDpoTitle;

  /// No description provided for @privacySectionContactDpoSummary.
  ///
  /// In en, this message translates to:
  /// **'Privacy inquiries'**
  String get privacySectionContactDpoSummary;

  /// No description provided for @privacySectionContactDpoContent.
  ///
  /// In en, this message translates to:
  /// **'📧 privacy@e-team.com\n📧 dpo@e-team.com'**
  String get privacySectionContactDpoContent;

  /// No description provided for @privacyDownloadSnack.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy downloaded'**
  String get privacyDownloadSnack;

  /// No description provided for @privacyDownloadButton.
  ///
  /// In en, this message translates to:
  /// **'Download Privacy Policy'**
  String get privacyDownloadButton;

  /// No description provided for @privacyUnderstandButton.
  ///
  /// In en, this message translates to:
  /// **'I Understand'**
  String get privacyUnderstandButton;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsTitle;

  /// No description provided for @termsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap sections to expand'**
  String get termsSubtitle;

  /// No description provided for @termsBadge.
  ///
  /// In en, this message translates to:
  /// **'Last updated: Feb 8, 2026'**
  String get termsBadge;

  /// No description provided for @termsSectionAcceptanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Acceptance'**
  String get termsSectionAcceptanceTitle;

  /// No description provided for @termsSectionAcceptanceSummary.
  ///
  /// In en, this message translates to:
  /// **'By using E-Team, you agree to these terms'**
  String get termsSectionAcceptanceSummary;

  /// No description provided for @termsSectionAcceptanceContent.
  ///
  /// In en, this message translates to:
  /// **'By accessing E-Team, you accept these terms. If you disagree, do not use the service.'**
  String get termsSectionAcceptanceContent;

  /// No description provided for @termsSectionAiUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Usage'**
  String get termsSectionAiUsageTitle;

  /// No description provided for @termsSectionAiUsageSummary.
  ///
  /// In en, this message translates to:
  /// **'AI tools assist, not replace judgment'**
  String get termsSectionAiUsageSummary;

  /// No description provided for @termsSectionAiUsageContent.
  ///
  /// In en, this message translates to:
  /// **'AI agents assist with tasks. Results are not guaranteed. You must validate outputs and handle data securely.'**
  String get termsSectionAiUsageContent;

  /// No description provided for @termsSectionPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get termsSectionPaymentTitle;

  /// No description provided for @termsSectionPaymentSummary.
  ///
  /// In en, this message translates to:
  /// **'Subscription & pay-as-you-go pricing'**
  String get termsSectionPaymentSummary;

  /// No description provided for @termsSectionPaymentContent.
  ///
  /// In en, this message translates to:
  /// **'Some features require payment. Subscriptions are billed monthly/yearly. Non-refundable unless required by law.'**
  String get termsSectionPaymentContent;

  /// No description provided for @termsSectionLiabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Liability'**
  String get termsSectionLiabilityTitle;

  /// No description provided for @termsSectionLiabilitySummary.
  ///
  /// In en, this message translates to:
  /// **'Limited legal responsibility'**
  String get termsSectionLiabilitySummary;

  /// No description provided for @termsSectionLiabilityContent.
  ///
  /// In en, this message translates to:
  /// **'E-Team is not liable for indirect damages, loss of profits, or data loss.'**
  String get termsSectionLiabilityContent;

  /// No description provided for @termsSectionContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get termsSectionContactTitle;

  /// No description provided for @termsSectionContactSummary.
  ///
  /// In en, this message translates to:
  /// **'Get in touch'**
  String get termsSectionContactSummary;

  /// No description provided for @termsSectionContactContent.
  ///
  /// In en, this message translates to:
  /// **'📧 support@e-team.com\n🌐 www.e-team.com'**
  String get termsSectionContactContent;

  /// No description provided for @termsAcceptButton.
  ///
  /// In en, this message translates to:
  /// **'I Understand & Accept'**
  String get termsAcceptButton;

  /// No description provided for @appInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'About E-Team'**
  String get appInfoTitle;

  /// No description provided for @appInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App Information'**
  String get appInfoSubtitle;

  /// No description provided for @appInfoTagline.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Team Management'**
  String get appInfoTagline;

  /// No description provided for @appInfoVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appInfoVersion(Object version);

  /// No description provided for @appInfoAboutSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get appInfoAboutSectionTitle;

  /// No description provided for @appInfoAboutDescription.
  ///
  /// In en, this message translates to:
  /// **'E-Team is an AI-powered platform that helps businesses manage their teams efficiently. With specialized AI agents for HR, Finance, Admin, Planning, and Communication, we automate repetitive tasks and boost productivity.'**
  String get appInfoAboutDescription;

  /// No description provided for @appInfoFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Key Features'**
  String get appInfoFeaturesTitle;

  /// No description provided for @appInfoFeaturesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What we offer'**
  String get appInfoFeaturesSubtitle;

  /// No description provided for @appInfoFeatureMarketplace.
  ///
  /// In en, this message translates to:
  /// **'🦾 AI Agent Marketplace'**
  String get appInfoFeatureMarketplace;

  /// No description provided for @appInfoFeatureHr.
  ///
  /// In en, this message translates to:
  /// **'💼 HR Management Automation'**
  String get appInfoFeatureHr;

  /// No description provided for @appInfoFeatureFinancial.
  ///
  /// In en, this message translates to:
  /// **'💰 Financial Tools & Reports'**
  String get appInfoFeatureFinancial;

  /// No description provided for @appInfoFeatureDocs.
  ///
  /// In en, this message translates to:
  /// **'📁 Document Management'**
  String get appInfoFeatureDocs;

  /// No description provided for @appInfoFeaturePlanning.
  ///
  /// In en, this message translates to:
  /// **'📅 Smart Planning & Scheduling'**
  String get appInfoFeaturePlanning;

  /// No description provided for @appInfoFeatureCommunication.
  ///
  /// In en, this message translates to:
  /// **'📧 Communication Assistant'**
  String get appInfoFeatureCommunication;

  /// No description provided for @appInfoTechTitle.
  ///
  /// In en, this message translates to:
  /// **'Technology Stack'**
  String get appInfoTechTitle;

  /// No description provided for @appInfoTechSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Built with modern tools'**
  String get appInfoTechSubtitle;

  /// No description provided for @appInfoTechFlutter.
  ///
  /// In en, this message translates to:
  /// **'Flutter - Cross-platform UI'**
  String get appInfoTechFlutter;

  /// No description provided for @appInfoTechNode.
  ///
  /// In en, this message translates to:
  /// **'Node.js - Backend API'**
  String get appInfoTechNode;

  /// No description provided for @appInfoTechMongo.
  ///
  /// In en, this message translates to:
  /// **'MongoDB - Database'**
  String get appInfoTechMongo;

  /// No description provided for @appInfoTechProvider.
  ///
  /// In en, this message translates to:
  /// **'Provider - State Management'**
  String get appInfoTechProvider;

  /// No description provided for @appInfoTechJwt.
  ///
  /// In en, this message translates to:
  /// **'JWT - Authentication'**
  String get appInfoTechJwt;

  /// No description provided for @appInfoConnectWithUs.
  ///
  /// In en, this message translates to:
  /// **'CONNECT WITH US'**
  String get appInfoConnectWithUs;

  /// No description provided for @appInfoEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get appInfoEmailLabel;

  /// No description provided for @appInfoLegalTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get appInfoLegalTerms;

  /// No description provided for @appInfoLegalPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get appInfoLegalPrivacy;

  /// No description provided for @appInfoLegalLicenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get appInfoLegalLicenses;

  /// No description provided for @appInfoComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon!'**
  String get appInfoComingSoon;

  /// No description provided for @appInfoLegalese.
  ///
  /// In en, this message translates to:
  /// **'© 2025 E-Team. All rights reserved.'**
  String get appInfoLegalese;

  /// No description provided for @appInfoCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2025 E-Team. All rights reserved.'**
  String get appInfoCopyright;

  /// No description provided for @appInfoMadeWith.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ in Tunisia 🇹🇳'**
  String get appInfoMadeWith;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
