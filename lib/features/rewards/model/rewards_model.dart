class EcoVoucherModel {
  final String id;
  final String title;
  final String description;
  final int requiredPoints;
  final bool isClaimed;

  const EcoVoucherModel({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredPoints,
    this.isClaimed = false,
  });

  bool isUnlocked(int userPoints) => userPoints >= requiredPoints;
}

class RewardsSummaryModel {
  final int totalPoints;
  final int milestoneTarget;
  final List<EcoVoucherModel> vouchers;
  final int totalPickups;

  const RewardsSummaryModel({
    this.totalPoints = 50,
    this.milestoneTarget = 500,
    this.vouchers = const [],
    this.totalPickups = 0,
  });

  double get progressFraction {
    if (milestoneTarget <= 0) return 0.0;
    return (totalPoints / milestoneTarget).clamp(0.0, 1.0);
  }

  int get remainingPoints =>
      (milestoneTarget - totalPoints).clamp(0, milestoneTarget);
}
