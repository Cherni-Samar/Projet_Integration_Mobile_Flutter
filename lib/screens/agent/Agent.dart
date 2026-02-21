import 'package:flutter/material.dart';

// Agent Model
class Agent {
  final String id;
  final String title;
  final String shortTitle;
  final List<String> description;
  final String timesSaved;
  final String price;
  final Color color;
  final String illustration;
  final bool isNew;
  final List<String> detailedFeatures;
  final Map<String, dynamic> stats;
  final List<Benefit> benefits;

  Agent({
    required this.id,
    required this.title,
    required this.shortTitle,
    required this.description,
    required this.timesSaved,
    required this.price,
    required this.color,
    required this.illustration,
    this.isNew = false,
    required this.detailedFeatures,
    required this.stats,
    required this.benefits,
  });
}

// Benefit Model
class Benefit {
  final IconData icon;
  final String title;
  final String description;

  Benefit({
    required this.icon,
    required this.title,
    required this.description,
  });
}

// Activity Model
class Activity {
  final String id;
  final String agentId;
  final String agentName;
  final String icon;
  final Color color;
  final String action;
  final String details;
  final DateTime timestamp;

  Activity({
    required this.id,
    required this.agentId,
    required this.agentName,
    required this.icon,
    required this.color,
    required this.action,
    required this.details,
    required this.timestamp,
  });

  String get timeAgo {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }
}

// Sample Data
class AgentData {
  static final List<Agent> availableAgents = [
    Agent(
      id: 'hr',
      title: 'HR SPECIALIST',
      shortTitle: 'HR',
      description: [
        'Manage employees',
        'Track leaves',
        'Onboarding support',
      ],
      timesSaved: '20h/week',
      price: '29€/month',
      color: const Color(0xFF8B5CF6),
      illustration: '👥',
      isNew: true,
      detailedFeatures: [
        'Employee database management',
        'Leave requests automation',
        'Onboarding workflow',
        'Contract generation',
        'Performance tracking',
      ],
      stats: {
        'timeSaved': '20h/week',
        'costSaved': '800€/mo',
        'efficiency': '85%',
      },
      benefits: [
        Benefit(
          icon: Icons.speed,
          title: 'Lightning Fast',
          description: 'Process requests in seconds',
        ),
        Benefit(
          icon: Icons.security,
          title: 'Secure & Private',
          description: 'Enterprise-grade security',
        ),
        Benefit(
          icon: Icons.refresh,
          title: '24/7 Available',
          description: 'Never takes a break',
        ),
      ],
    ),
    Agent(
      id: 'finance',
      title: 'FINANCIAL EXPERT',
      shortTitle: 'FIN',
      description: [
        'Expense tracking',
        'Invoice management',
        'Financial reports',
      ],
      timesSaved: '15h/week',
      price: '39€/month',
      color: const Color(0xFFF59E0B),
      illustration: '💰',
      detailedFeatures: [
        'Automated expense tracking',
        'Invoice generation and management',
        'Financial reporting and analytics',
        'Budget monitoring',
        'Tax document preparation',
      ],
      stats: {
        'timeSaved': '15h/week',
        'costSaved': '600€/mo',
        'efficiency': '90%',
      },
      benefits: [
        Benefit(
          icon: Icons.auto_graph,
          title: 'Smart Analytics',
          description: 'Real-time financial insights',
        ),
        Benefit(
          icon: Icons.verified_user,
          title: 'Audit Ready',
          description: 'Compliance guaranteed',
        ),
        Benefit(
          icon: Icons.notifications_active,
          title: 'Smart Alerts',
          description: 'Never miss a deadline',
        ),
      ],
    ),
    Agent(
      id: 'admin',
      title: 'ADMIN ASSISTANT',
      shortTitle: 'ADMIN',
      description: [
        'Document management',
        'File classification',
        'Archiving system',
      ],
      timesSaved: '12h/week',
      price: '25€/month',
      color: const Color(0xFF10B981),
      illustration: '📁',
      detailedFeatures: [
        'Intelligent document organization',
        'Automated file classification',
        'Smart archiving system',
        'Document search and retrieval',
        'Version control management',
      ],
      stats: {
        'timeSaved': '12h/week',
        'costSaved': '500€/mo',
        'efficiency': '88%',
      },
      benefits: [
        Benefit(
          icon: Icons.cloud_done,
          title: 'Cloud Storage',
          description: 'Access from anywhere',
        ),
        Benefit(
          icon: Icons.search,
          title: 'Smart Search',
          description: 'Find anything instantly',
        ),
        Benefit(
          icon: Icons.backup,
          title: 'Auto Backup',
          description: 'Never lose a file',
        ),
      ],
    ),
    Agent(
      id: 'planning',
      title: 'PLANNING MANAGER',
      shortTitle: 'PLAN',
      description: [
        'Task management',
        'Meeting scheduling',
        'Deadline tracking',
      ],
      timesSaved: '10h/week',
      price: '19€/month',
      color: const Color(0xFFEC4899),
      illustration: '📅',
      detailedFeatures: [
        'Intelligent task prioritization',
        'Automated meeting scheduling',
        'Deadline reminders and tracking',
        'Calendar synchronization',
        'Team availability management',
      ],
      stats: {
        'timeSaved': '10h/week',
        'costSaved': '400€/mo',
        'efficiency': '82%',
      },
      benefits: [
        Benefit(
          icon: Icons.calendar_today,
          title: 'Smart Scheduling',
          description: 'Auto-find best times',
        ),
        Benefit(
          icon: Icons.sync,
          title: 'Multi-Calendar',
          description: 'Sync all calendars',
        ),
        Benefit(
          icon: Icons.notification_important,
          title: 'Smart Reminders',
          description: 'Never miss a deadline',
        ),
      ],
    ),
    Agent(
      id: 'communication',
      title: 'COMMUNICATION PRO',
      shortTitle: 'COMM',
      description: [
        'Email management',
        'Internal notifications',
        'Conversation summary',
      ],
      timesSaved: '8h/week',
      price: '19€/month',
      color: const Color(0xFF3B82F6),
      illustration: '💬',
      detailedFeatures: [
        'Intelligent email sorting',
        'Automated response suggestions',
        'Team notification management',
        'Conversation summarization',
        'Priority message detection',
      ],
      stats: {
        'timeSaved': '8h/week',
        'costSaved': '350€/mo',
        'efficiency': '80%',
      },
      benefits: [
        Benefit(
          icon: Icons.filter_list,
          title: 'Smart Filtering',
          description: 'Auto-sort messages',
        ),
        Benefit(
          icon: Icons.lightbulb,
          title: 'AI Suggestions',
          description: 'Quick reply options',
        ),
        Benefit(
          icon: Icons.summarize,
          title: 'Auto Summary',
          description: 'Digest long threads',
        ),
      ],
    ),
  ];

  static List<Activity> getRecentActivities() {
    return [
      Activity(
        id: '1',
        agentId: 'hr',
        agentName: 'HR Agent',
        icon: '👥',
        color: const Color(0xFF8B5CF6),
        action: 'Processed 3 leave requests',
        details: '• Approved: Sarah M.\n• Pending: John D.\n• Rejected: Mike R. (insufficient balance)',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      Activity(
        id: '2',
        agentId: 'admin',
        agentName: 'Admin Agent',
        icon: '📁',
        color: const Color(0xFF10B981),
        action: 'Archived 12 documents',
        details: 'Organized files into Q4 2025 folder\nCategories: Invoices (5), Contracts (7)',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      Activity(
        id: '3',
        agentId: 'planning',
        agentName: 'Planning Agent',
        icon: '📅',
        color: const Color(0xFFEC4899),
        action: 'Scheduled 2 meetings',
        details: '• Team Sync - Tomorrow 10:00 AM\n• Client Review - Friday 2:00 PM',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Activity(
        id: '4',
        agentId: 'hr',
        agentName: 'HR Agent',
        icon: '👥',
        color: const Color(0xFF8B5CF6),
        action: 'Updated employee database',
        details: 'Added 2 new employees\nUpdated 5 contact information',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }

  static Agent? getAgentById(String id) {
    try {
      return availableAgents.firstWhere((agent) => agent.id == id);
    } catch (e) {
      return null;
    }
  }
}