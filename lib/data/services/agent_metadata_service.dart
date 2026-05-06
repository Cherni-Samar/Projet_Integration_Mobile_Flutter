import 'package:e_team/domain/models/agent_metadata_model.dart';
import 'package:e_team/l10n/app_localizations.dart';

class AgentMetadataService {
  static const List<AgentMetadata> _agentMetadata = [
    AgentMetadata(
      id: 'hera',
      name: 'Hera',
      roleKey: 'agentRoleHrRecruitmentAI', // Updated: HR & Recruitment AI
      descriptionKey:
          'agentDescHrRecruitmentAI', // Updated: HR analysis, candidate scoring, employee management
      iconPath: 'assets/images/hera.png',
      colorValue: 0xFF8B5CF6,
      stats: AgentStats(
        response: '< 1.2s',
        accuracy: '99.4%',
        languages: '42+',
      ),
      rating: 4.9,
      hires: '1.2k',
      priceLabel:
          '1–5 ⚡ per task', // Backend reality: dynamic energy based on task type
      versionKey: 'agentVersionAlpha',
      skillKeys: [
        'skillCandidateScoring', // Updated: Backend reality - candidate analysis
        'skillEmployeeManagement', // Updated: Backend reality - employee records/management
        'skillLeaveRequests', // Updated: Backend reality - leave request processing
        'skillOnboardingOffboarding', // Updated: Backend reality - employee onboarding/offboarding
        'skillStaffingAnalysis', // Updated: Backend reality - staffing checks and analysis
      ],
      energyTasks: [
        AgentEnergyTask(
          task: 'Candidate scoring',
          cost: 1,
        ), // Backend reality: candidate analysis
        AgentEnergyTask(
          task: 'Employee analysis',
          cost: 4,
        ), // Backend reality: HR analysis
        AgentEnergyTask(
          task: 'Leave processing',
          cost: 5,
        ), // Backend reality: leave request analysis
      ],
      multiScenarios: [
        AgentMultiScenario(
          scenario: 'Leave + schedule update',
          agents: 'Hera + Timo',
          cost: 6, // Realistic: 2-4 energy per agent
        ),
      ],
      energyPacks: [
        AgentEnergyPack(
          title: 'Starter',
          energy: 1000,
          price: 10.0,
          color: 0xFF10B981,
        ),
        AgentEnergyPack(
          title: 'Pro',
          energy: 6000,
          price: 45.0,
          color: 0xFF8B5CF6,
        ),
        AgentEnergyPack(
          title: 'Business',
          energy: 15000,
          price: 100.0,
          color: 0xFFF59E0B,
        ),
      ],
      defaultEnergy: 170,
    ),
    AgentMetadata(
      id: 'kash',
      name: 'Kash',
      roleKey: 'agentRoleFinanceBudgetAI', // Updated: Finance & Budget AI
      descriptionKey:
          'agentDescFinanceBudgetAI', // Updated: expense tracking, budget monitoring, financial analysis
      iconPath: 'assets/images/kash.png',
      colorValue: 0xFFF59E0B,
      stats: AgentStats(
        response: '< 0.8s',
        accuracy: '98.9%',
        languages: '35+',
      ),
      rating: 4.8,
      hires: '980',
      priceLabel:
          '1–5 ⚡ per task', // Backend reality: dynamic energy based on task type
      versionKey: 'agentVersionFinanceWizard',
      skillKeys: [
        'skillExpenseTracking', // Updated: Backend reality - expense management
        'skillBudgetMonitoring', // Updated: Backend reality - budget tracking
        'skillReceiptAnalysis', // Updated: Backend reality - receipt/invoice processing
        'skillInvoiceProcessing', // Updated: Backend reality - invoice analysis
        'skillFinancialReports', // Updated: Backend reality - financial reporting
      ],
      energyTasks: [
        AgentEnergyTask(
          task: 'Expense tracking',
          cost: 2,
        ), // Backend reality: expense management
        AgentEnergyTask(
          task: 'Budget analysis',
          cost: 3,
        ), // Backend reality: budget tracking
        AgentEnergyTask(
          task: 'Financial reports',
          cost: 5,
        ), // Backend reality: financial reporting
      ],
      multiScenarios: [
        AgentMultiScenario(
          scenario: 'Invoice + storage + analysis',
          agents: 'Kash + Dexo',
          cost: 8, // Realistic: 3-5 energy per agent
        ),
      ],
      energyPacks: [
        AgentEnergyPack(
          title: 'Starter',
          energy: 1000,
          price: 15.0,
          color: 0xFF10B981,
        ),
        AgentEnergyPack(
          title: 'Pro',
          energy: 6000,
          price: 55.0,
          color: 0xFF8B5CF6,
        ),
        AgentEnergyPack(
          title: 'Business',
          energy: 15000,
          price: 120.0,
          color: 0xFFF59E0B,
        ),
      ],
      defaultEnergy: 170,
    ),
    AgentMetadata(
      id: 'dexo',
      name: 'Dexo',
      roleKey:
          'agentRoleDocumentIntelligenceAI', // Updated: Document Intelligence AI
      descriptionKey:
          'agentDescDocumentIntelligenceAI', // Updated: document classification, search, security, duplicates
      iconPath: 'assets/images/dexo.png',
      colorValue: 0xFF10B981,
      stats: AgentStats(
        response: '< 1.5s',
        accuracy: '97.8%',
        languages: '28+',
      ),
      rating: 5.0,
      hires: '2.1k',
      priceLabel:
          '1–5 ⚡ per task', // Backend reality: dynamic energy based on task type
      versionKey: 'agentVersionAdminPro',
      skillKeys: [
        'skillDocumentClassification', // Updated: Backend reality - AI document classification
        'skillSmartSearch', // Updated: Backend reality - intelligent document search
        'skillSecurityMonitoring', // Updated: Backend reality - security/confidentiality monitoring
        'skillDuplicateDetection', // Updated: Backend reality - duplicate detection
        'skillVersionTracking', // Updated: Backend reality - document versioning/audit
      ],
      energyTasks: [
        AgentEnergyTask(
          task: 'Document classification',
          cost: 2,
        ), // Backend reality: AI classification
        AgentEnergyTask(
          task: 'Security analysis',
          cost: 3,
        ), // Backend reality: security monitoring
        AgentEnergyTask(
          task: 'Duplicate detection',
          cost: 4,
        ), // Backend reality: advanced duplicate analysis
      ],
      multiScenarios: [
        AgentMultiScenario(
          scenario: 'Invoice + storage + analysis',
          agents: 'Kash + Dexo',
          cost: 8, // Realistic: 3-5 energy per agent
        ),
      ],
      energyPacks: [
        AgentEnergyPack(
          title: 'Starter',
          energy: 1000,
          price: 8.0,
          color: 0xFF10B981,
        ),
        AgentEnergyPack(
          title: 'Pro',
          energy: 6000,
          price: 35.0,
          color: 0xFF8B5CF6,
        ),
        AgentEnergyPack(
          title: 'Business',
          energy: 15000,
          price: 80.0,
          color: 0xFFF59E0B,
        ),
      ],
      defaultEnergy: 170,
    ),
    AgentMetadata(
      id: 'timo',
      name: 'Timo',
      roleKey: 'agentRoleSchedulingTimeAI', // Updated: Scheduling & Time AI
      descriptionKey:
          'agentDescSchedulingTimeAI', // Updated: calendar management, reminders, meeting planning
      iconPath: 'assets/images/krono.png',
      colorValue: 0xFFEC4899,
      stats: AgentStats(
        response: '< 1.0s',
        accuracy: '96.5%',
        languages: '30+',
      ),
      rating: 4.7,
      hires: '850',
      priceLabel:
          '1–5 ⚡ per task', // Backend reality: dynamic energy based on task type
      versionKey: 'agentVersionPlanningBot',
      skillKeys: [
        'skillCalendarPlanning', // Updated: Backend reality - calendar management
        'skillReminders', // Updated: Backend reality - reminder creation
        'skillMeetingScheduling', // Updated: Backend reality - meeting planning
        'skillTaskPrioritization', // Updated: Backend reality - task prioritization
        'skillTimeManagement', // Updated: Backend reality - time management
      ],
      energyTasks: [
        AgentEnergyTask(
          task: 'Reminders',
          cost: 1,
        ), // Backend reality: reminder creation
        AgentEnergyTask(
          task: 'Calendar sync',
          cost: 2,
        ), // Backend reality: calendar management
        AgentEnergyTask(
          task: 'Meeting planning',
          cost: 4,
        ), // Backend reality: schedule optimization
      ],
      multiScenarios: [
        AgentMultiScenario(
          scenario: 'Leave + schedule update',
          agents: 'Hera + Timo',
          cost: 6, // Realistic: 2-4 energy per agent
        ),
        AgentMultiScenario(
          scenario: 'Meeting + summary + tasks',
          agents: 'Timo + Echo',
          cost: 7, // Realistic: 3-4 energy per agent
        ),
      ],
      energyPacks: [
        AgentEnergyPack(
          title: 'Starter',
          energy: 1000,
          price: 12.0,
          color: 0xFF10B981,
        ),
        AgentEnergyPack(
          title: 'Pro',
          energy: 6000,
          price: 50.0,
          color: 0xFF8B5CF6,
        ),
        AgentEnergyPack(
          title: 'Business',
          energy: 15000,
          price: 110.0,
          color: 0xFFF59E0B,
        ),
      ],
      defaultEnergy: 170,
    ),
    AgentMetadata(
      id: 'echo',
      name: 'Echo',
      roleKey:
          'agentRoleCommunicationMarketingAI', // Updated: Communication & Marketing AI
      descriptionKey:
          'agentDescCommunicationMarketingAI', // Updated: email intelligence, smart replies, social media automation
      iconPath: 'assets/images/voxi.png',
      colorValue: 0xFFA855F7,
      stats: AgentStats(
        response: '< 0.9s',
        accuracy: '98.2%',
        languages: '45+',
      ),
      rating: 4.9,
      hires: '1.5k',
      priceLabel:
          '1–5 ⚡ per task', // Backend reality: dynamic energy based on task type
      versionKey: 'agentVersionCommSync',
      skillKeys: [
        'skillEmailAnalysis', // Updated: Backend reality - email/message processing
        'skillSmartReplies', // Updated: Backend reality - smart reply generation
        'skillContentGeneration', // Updated: Backend reality - content generation
        'skillSocialMediaAutomation', // Updated: Backend reality - social media posting
        'skillLinkedInCampaigns', // Updated: Backend reality - LinkedIn campaign automation
      ],
      energyTasks: [
        AgentEnergyTask(
          task: 'Email processing',
          cost: 1,
        ), // Backend reality: email analysis
        AgentEnergyTask(
          task: 'Social posts',
          cost: 3,
        ), // Backend reality: social media posting
        AgentEnergyTask(
          task: 'Content generation',
          cost: 4,
        ), // Backend reality: content creation
      ],
      multiScenarios: [
        AgentMultiScenario(
          scenario: 'Meeting + summary + tasks',
          agents: 'Timo + Echo',
          cost: 7, // Realistic: 3-4 energy per agent
        ),
      ],
      energyPacks: [
        AgentEnergyPack(
          title: 'Starter',
          energy: 1000,
          price: 5.0,
          color: 0xFF10B981,
        ),
        AgentEnergyPack(
          title: 'Pro',
          energy: 6000,
          price: 25.0,
          color: 0xFF8B5CF6,
        ),
        AgentEnergyPack(
          title: 'Business',
          energy: 15000,
          price: 60.0,
          color: 0xFFF59E0B,
        ),
      ],
      defaultEnergy: 170,
    ),
  ];

  /// Get all agents as Map list for backward compatibility
  static List<Map<String, dynamic>> getAllAgentsAsMap(AppLocalizations l10n) {
    return _agentMetadata.map((agent) {
      return agent.toLocalizedMap(
        role: _getLocalizedString(l10n, agent.roleKey),
        description: _getLocalizedString(l10n, agent.descriptionKey),
      );
    }).toList();
  }

  /// Get agent metadata by ID
  static AgentMetadata? getAgentById(String id) {
    final normalizedId = id.trim().toLowerCase();
    try {
      return _agentMetadata.firstWhere((agent) => agent.id == normalizedId);
    } catch (e) {
      return null;
    }
  }

  /// Get agent metadata by name
  static AgentMetadata? getAgentByName(String name) {
    final normalizedName = name.trim().toLowerCase();
    try {
      return _agentMetadata.firstWhere(
        (agent) => agent.name.toLowerCase() == normalizedName,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get all agent metadata
  static List<AgentMetadata> getAllAgents() {
    return List.unmodifiable(_agentMetadata);
  }

  /// Get skills for agent (localized)
  static List<String> getSkillsForAgent(
    AppLocalizations l10n,
    String agentName,
  ) {
    final agent = getAgentByName(agentName);
    if (agent == null) {
      return [
        _getLocalizedString(l10n, 'skillNaturalLanguage'),
        _getLocalizedString(l10n, 'skillApiIntegration'),
        _getLocalizedString(l10n, 'skillMultilingualSupport'),
        _getLocalizedString(l10n, 'skillDataAnalysis'),
        _getLocalizedString(l10n, 'skillAutomation'),
      ];
    }
    return agent.skillKeys
        .map((key) => _getLocalizedString(l10n, key))
        .toList();
  }

  /// Get energy costs for agent
  static List<Map<String, dynamic>> getEnergyCostsForAgent(String agentName) {
    final agent = getAgentByName(agentName);
    if (agent == null) {
      return [
        {'task': 'Basic task', 'cost': 10},
      ];
    }
    return agent.energyTasks.map((task) => task.toMap()).toList();
  }

  /// Get multi-agent scenarios
  static List<Map<String, dynamic>> getMultiAgentScenarios(String agentName) {
    final agent = getAgentByName(agentName);
    if (agent == null) return [];
    return agent.multiScenarios.map((scenario) => scenario.toMap()).toList();
  }

  /// Get energy packs for agent
  static List<Map<String, dynamic>> getEnergyPacksForAgent(String agentName) {
    final agent = getAgentByName(agentName);
    if (agent == null) {
      return [
        {
          'title': 'Starter',
          'energy': 1000,
          'price': 10.0,
          'color': 0xFF10B981,
        },
        {'title': 'Pro', 'energy': 6000, 'price': 45.0, 'color': 0xFF8B5CF6},
        {
          'title': 'Business',
          'energy': 15000,
          'price': 100.0,
          'color': 0xFFF59E0B,
        },
      ];
    }
    return agent.energyPacks.map((pack) => pack.toMap()).toList();
  }

  /// Get version for agent (localized)
  static String getVersionForAgent(AppLocalizations l10n, String agentName) {
    final agent = getAgentByName(agentName);
    if (agent == null) {
      return _getLocalizedString(l10n, 'agentVersionDefault');
    }
    return _getLocalizedString(l10n, agent.versionKey);
  }

  /// Get rating for agent
  static Map<String, dynamic> getRatingForAgent(String agentName) {
    final agent = getAgentByName(agentName);
    if (agent == null) {
      return {'stars': 4.8, 'hires': '1.2k'};
    }
    return {'stars': agent.rating, 'hires': agent.hires};
  }

  /// Get default energy for agent
  static int getDefaultEnergyForAgent(String agentName) {
    final agent = getAgentByName(agentName);
    return agent?.defaultEnergy ?? 170;
  }

  /// Get realistic energy range display for agent
  static String getEnergyRangeForAgent(String agentName) {
    final agent = getAgentByName(agentName);
    if (agent == null) {
      return '1–5 ⚡ per task'; // Default backend range
    }
    return agent.getEnergyRangeDisplay();
  }

  /// Get agent defaults for owned_agents_provider compatibility
  static Map<String, dynamic> getAgentDefaults(String agentId) {
    final agent = getAgentById(agentId);
    if (agent == null) {
      final capitalizedName = agentId.isEmpty
          ? 'Agent'
          : '${agentId[0].toUpperCase()}${agentId.substring(1)}';
      return {
        'displayName': capitalizedName,
        'illustration': 'assets/images/hera.png',
        'colorValue': 0xFF8B5CF6,
        'defaultEnergy': 170,
      };
    }
    return {
      'displayName': agent.name,
      'illustration': agent.iconPath,
      'colorValue': agent.colorValue,
      'defaultEnergy': agent.defaultEnergy,
    };
  }

  /// Helper to get localized string safely
  static String _getLocalizedString(AppLocalizations l10n, String key) {
    try {
      switch (key) {
        // Roles
        case 'agentRoleHrSpecialist':
          return l10n.agentRoleHrSpecialist;
        case 'agentRoleHrRecruitmentAI': // Updated: HR & Recruitment AI
          return 'HR & Recruitment AI';
        case 'agentRoleFinancialExpert':
          return l10n.agentRoleFinancialExpert;
        case 'agentRoleFinanceBudgetAI': // Updated: Finance & Budget AI
          return 'Finance & Budget AI';
        case 'agentRoleAdminAssistant':
          return l10n.agentRoleAdminAssistant;
        case 'agentRoleDocumentIntelligenceAI': // Updated: Document Intelligence AI
          return 'Document Intelligence AI';
        case 'agentRolePlanningManager':
          return l10n.agentRolePlanningManager;
        case 'agentRoleSchedulingTimeAI': // Updated: Scheduling & Time AI
          return 'Scheduling & Time AI';
        case 'agentRoleCommunicationPro':
          return l10n.agentRoleCommunicationPro;
        case 'agentRoleCommunicationMarketingAI': // Updated: Communication & Marketing AI
          return 'Communication & Marketing AI';

        // Descriptions
        case 'agentDescAlpha':
          return l10n.agentDescAlpha;
        case 'agentDescHrRecruitmentAI': // Updated: HR & Recruitment AI description
          return 'Advanced HR analysis, candidate scoring, employee management, leave requests, and onboarding automation';
        case 'agentDescFinanceWizard':
          return l10n.agentDescFinanceWizard;
        case 'agentDescFinanceBudgetAI': // Updated: Finance & Budget AI description
          return 'Intelligent expense tracking, budget monitoring, receipt analysis, invoice processing, and financial reporting';
        case 'agentDescAdminPro':
          return l10n.agentDescAdminPro;
        case 'agentDescDocumentIntelligenceAI': // Updated: Document Intelligence AI description
          return 'AI-powered document classification, intelligent search, security monitoring, duplicate detection, and version control';
        case 'agentDescPlanningBot':
          return l10n.agentDescPlanningBot;
        case 'agentDescSchedulingTimeAI': // Updated: Scheduling & Time AI description
          return 'Smart calendar management, automated reminders, meeting planning, task prioritization, and time optimization';
        case 'agentDescCommSync':
          return l10n.agentDescCommSync;
        case 'agentDescCommunicationMarketingAI': // Updated: Communication & Marketing AI description
          return 'Email intelligence, smart replies, content generation, social media automation, and LinkedIn campaign management';

        // Versions
        case 'agentVersionAlpha':
          return l10n.agentVersionAlpha;
        case 'agentVersionFinanceWizard':
          return l10n.agentVersionFinanceWizard;
        case 'agentVersionAdminPro':
          return l10n.agentVersionAdminPro;
        case 'agentVersionPlanningBot':
          return l10n.agentVersionPlanningBot;
        case 'agentVersionCommSync':
          return l10n.agentVersionCommSync;
        case 'agentVersionDefault':
          return l10n.agentVersionDefault;

        // Skills
        case 'skillRecruitmentOnboarding':
          return l10n.skillRecruitmentOnboarding;
        case 'skillCandidateScoring': // Updated: Backend reality - candidate analysis
          return 'Candidate Scoring';
        case 'skillEmployeeRecords':
          return l10n.skillEmployeeRecords;
        case 'skillEmployeeManagement': // Updated: Backend reality - employee management
          return 'Employee Management';
        case 'skillPayrollManagement':
          return l10n.skillPayrollManagement;
        case 'skillLeaveTracking':
          return l10n.skillLeaveTracking;
        case 'skillLeaveRequests': // Updated: Backend reality - leave request processing
          return 'Leave Requests';
        case 'skillPerformanceReviews':
          return l10n.skillPerformanceReviews;
        case 'skillOnboardingOffboarding': // Updated: Backend reality - onboarding/offboarding
          return 'Onboarding & Offboarding';
        case 'skillStaffingAnalysis': // Updated: Backend reality - staffing analysis
          return 'Staffing Analysis';
        case 'skillInvoiceProcessing':
          return l10n.skillInvoiceProcessing;
        case 'skillExpenseTracking':
          return l10n.skillExpenseTracking;
        case 'skillBudgetMonitoring': // Updated: Backend reality - budget monitoring
          return 'Budget Monitoring';
        case 'skillReceiptAnalysis': // Updated: Backend reality - receipt analysis
          return 'Receipt Analysis';
        case 'skillFinancialReports':
          return l10n.skillFinancialReports;
        case 'skillBudgetPlanning':
          return l10n.skillBudgetPlanning;
        case 'skillTaxCompliance':
          return l10n.skillTaxCompliance;
        case 'skillDocumentManagement':
          return l10n.skillDocumentManagement;
        case 'skillDocumentClassification': // Updated: Backend reality - AI document classification
          return 'Document Classification';
        case 'skillFileOrganization':
          return l10n.skillFileOrganization;
        case 'skillSmartSearch': // Updated: Backend reality - intelligent search
          return 'Smart Search';
        case 'skillDataEntry':
          return l10n.skillDataEntry;
        case 'skillSecurityMonitoring': // Updated: Backend reality - security monitoring
          return 'Security Monitoring';
        case 'skillMeetingScheduling':
          return l10n.skillMeetingScheduling;
        case 'skillDuplicateDetection': // Updated: Backend reality - duplicate detection
          return 'Duplicate Detection';
        case 'skillEmailManagement':
          return l10n.skillEmailManagement;
        case 'skillVersionTracking': // Updated: Backend reality - version tracking
          return 'Version Tracking';
        case 'skillProjectPlanning':
          return l10n.skillProjectPlanning;
        case 'skillCalendarPlanning': // Updated: Backend reality - calendar planning
          return 'Calendar Planning';
        case 'skillTaskManagement':
          return l10n.skillTaskManagement;
        case 'skillReminders': // Updated: Backend reality - reminders
          return 'Reminders';
        case 'skillResourceAllocation':
          return l10n.skillResourceAllocation;
        case 'skillTaskPrioritization': // Updated: Backend reality - task prioritization
          return 'Task Prioritization';
        case 'skillDeadlineTracking':
          return l10n.skillDeadlineTracking;
        case 'skillTimeManagement': // Updated: Backend reality - time management
          return 'Time Management';
        case 'skillTeamCoordination':
          return l10n.skillTeamCoordination;
        case 'skillEmailCampaigns':
          return l10n.skillEmailCampaigns;
        case 'skillEmailAnalysis': // Updated: Backend reality - email analysis
          return 'Email Analysis';
        case 'skillTeamCommunications':
          return l10n.skillTeamCommunications;
        case 'skillSmartReplies': // Updated: Backend reality - smart replies
          return 'Smart Replies';
        case 'skillNotifications':
          return l10n.skillNotifications;
        case 'skillContentGeneration': // Updated: Backend reality - content generation
          return 'Content Generation';
        case 'skillAnnouncementDistribution':
          return l10n.skillAnnouncementDistribution;
        case 'skillSocialMediaAutomation': // Updated: Backend reality - social media automation
          return 'Social Media Automation';
        case 'skillChatManagement':
          return l10n.skillChatManagement;
        case 'skillLinkedInCampaigns': // Updated: Backend reality - LinkedIn campaigns
          return 'LinkedIn Campaigns';
        case 'skillNaturalLanguage':
          return l10n.skillNaturalLanguage;
        case 'skillApiIntegration':
          return l10n.skillApiIntegration;
        case 'skillMultilingualSupport':
          return l10n.skillMultilingualSupport;
        case 'skillDataAnalysis':
          return l10n.skillDataAnalysis;
        case 'skillAutomation':
          return l10n.skillAutomation;

        default:
          return key; // Fallback to key if not found
      }
    } catch (e) {
      return key; // Fallback to key if error
    }
  }
}
