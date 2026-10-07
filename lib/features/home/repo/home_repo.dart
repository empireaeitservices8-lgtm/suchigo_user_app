import 'package:flutter/material.dart';
import '../model/home_model.dart';

abstract class HomeRepository {
  Future<HomeDashboardModel> getDashboardData();
}

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<HomeDashboardModel> getDashboardData() async {
    return const HomeDashboardModel(
      userName: 'USER',
      userProgress: 0.65,
      treesSaved: 11235,
      rewardPoints: 300,
      monthlyWasteKg: 50,
      categories: [
        WasteCategoryModel(
          id: 'hazardous',
          title: 'Hazardous',
          bgColor: Color(0xFFFFEB3B),
          iconColor: Color(0xFF1E293B),
          isHazardous: true,
        ),
        WasteCategoryModel(
          id: 'general',
          title: 'General',
          icon: Icons.delete_outline_rounded,
          iconColor: Color(0xFF78909C),
        ),
        WasteCategoryModel(
          id: 'recycle',
          title: 'Recycle',
          icon: Icons.autorenew_rounded,
          iconColor: Color(0xFF0288D1),
        ),
        WasteCategoryModel(
          id: 'food_waste',
          title: 'Food Waste',
          icon: Icons.eco_outlined,
          iconColor: Color(0xFF43A047),
        ),
        WasteCategoryModel(
          id: 'e_waste',
          title: 'E-Waste',
          icon: Icons.devices_other_outlined,
          iconColor: Color(0xFF00ACC1),
        ),
      ],
    );
  }
}
