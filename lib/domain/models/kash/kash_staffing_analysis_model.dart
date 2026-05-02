class KashStaffingAnalysis {
  final String department;
  final int currentCount;
  final int targetCount;
  final int missing;
  final double estimatedMonthlyCost;
  final bool canAfford;
  final String recommendation;

  KashStaffingAnalysis({
    required this.department,
    required this.currentCount,
    required this.targetCount,
    required this.missing,
    required this.estimatedMonthlyCost,
    required this.canAfford,
    required this.recommendation,
  });
}