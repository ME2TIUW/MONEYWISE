import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_wise/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.uid,
    required super.name,
    required super.email,
    super.phone,
    super.monthlyBudget,
    super.remainingBudget,
    super.lastBudgetMonth,
    super.profileImageUrl,
    super.createdAt,
    super.updatedAt,
    required super.isProfileCompleted,
    super.budgetStartDate,
    super.financialGoal,
    super.allowFinancialAccess,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'monthly_budget': monthlyBudget,
      'remaining_budget': remainingBudget,
      'last_budget_month': lastBudgetMonth,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updated_at': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
      'is_profile_completed': isProfileCompleted,
      'budget_start_date': budgetStartDate != null
          ? Timestamp.fromDate(budgetStartDate!)
          : null,
      'financial_goal': financialGoal,
      'allow_financial_access': allowFinancialAccess,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      monthlyBudget: map['monthly_budget'] != null
          ? (map['monthly_budget'] as num).toDouble()
          : null,
      remainingBudget: map['remaining_budget'] != null
          ? (map['remaining_budget'] as num).toDouble()
          : 0.0,
      lastBudgetMonth: map['last_budget_month'] as String?,
      profileImageUrl: map['profile_image_url'] as String?,
      createdAt: (map['created_at'] as Timestamp?)?.toDate(),
      updatedAt: (map['updated_at'] as Timestamp?)?.toDate(),
      isProfileCompleted: map['is_profile_completed'] ?? false,
      budgetStartDate: (map['budget_start_date'] as Timestamp?)?.toDate(),
      financialGoal: map['financial_goal'],
      allowFinancialAccess: map['allow_financial_access'],
    );
  }
}
