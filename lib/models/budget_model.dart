import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  final String? id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime createdAt;
  final DateTime? targetDate;
  final String savingFrequency; // daily, weekly, monthly

  BudgetModel({
    this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.createdAt,
    this.targetDate,
    required this.savingFrequency,
  });

  factory BudgetModel.fromMap(Map<String, dynamic> map, String id) {
    return BudgetModel(
      id: id,
      title: map['title'] ?? '',
      targetAmount: map['targetAmount']?.toDouble() ?? 0.0,
      currentAmount: map['currentAmount']?.toDouble() ?? 0.0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      targetDate: map['targetDate'] != null ? (map['targetDate'] as Timestamp).toDate() : null,
      savingFrequency: map['savingFrequency'] ?? 'monthly',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'createdAt': createdAt,
      'targetDate': targetDate,
      'savingFrequency': savingFrequency,
    };
  }

  double get progressPercentage => (currentAmount / targetAmount) * 100;

  int calculateDaysToTarget() {
    if (targetDate == null) return 0;
    
    final daysLeft = targetDate!.difference(DateTime.now()).inDays;
    return daysLeft > 0 ? daysLeft : 0;
  }

  double calculateRequiredSavingRate() {
    if (targetDate == null) return 0;
    
    final daysLeft = calculateDaysToTarget();
    if (daysLeft <= 0) return 0;
    
    final amountLeft = targetAmount - currentAmount;
    
    switch (savingFrequency) {
      case 'daily':
        return amountLeft / daysLeft;
      case 'weekly':
        return amountLeft / (daysLeft / 7);
      case 'monthly':
        return amountLeft / (daysLeft / 30);
      default:
        return amountLeft / daysLeft;
    }
  }
}