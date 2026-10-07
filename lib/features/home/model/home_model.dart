import 'package:flutter/material.dart';

class WasteCategoryModel {
  final String id;
  final String title;
  final IconData? icon;
  final Color iconColor;
  final Color bgColor;
  final bool isHazardous;

  const WasteCategoryModel({
    required this.id,
    required this.title,
    this.icon,
    this.iconColor = const Color(0xFF166534),
    this.bgColor = Colors.white,
    this.isHazardous = false,
  });
}

class HomeDashboardModel {
  final String userName;
  final double userProgress;
  final int treesSaved;
  final int rewardPoints;
  final int monthlyWasteKg;
  final List<WasteCategoryModel> categories;

  const HomeDashboardModel({
    this.userName = 'USER',
    this.userProgress = 0.65,
    this.treesSaved = 11235,
    this.rewardPoints = 300,
    this.monthlyWasteKg = 50,
    this.categories = const [],
  });
}
