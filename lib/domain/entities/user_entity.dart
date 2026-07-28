class UserEntity {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final double? monthlyBudget;
  final double? remainingBudget;
  final String? lastBudgetMonth;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isProfileCompleted;
  final DateTime? budgetStartDate;
  final String? financialGoal;
  final bool? allowFinancialAccess;

  UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.monthlyBudget,
    this.remainingBudget,
    this.lastBudgetMonth,
    this.createdAt,
    this.updatedAt,
    required this.isProfileCompleted,
    this.budgetStartDate,
    this.financialGoal,
    this.allowFinancialAccess,
    this.profileImageUrl,
  });
}
