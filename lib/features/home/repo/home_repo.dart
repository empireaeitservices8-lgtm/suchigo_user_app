import 'package:flutter/material.dart';
import 'package:suchigo_user_app/features/profile/model/profile_model.dart';
import 'package:suchigo_user_app/helpers/sp_helper.dart';
import 'package:suchigo_user_app/services/web_api_services.dart';
import 'package:suchigo_user_app/utils/urls.dart';
import '../model/home_model.dart';

abstract class HomeRepository {
  Future<HomeDashboardModel> getDashboardData();
}

class HomeRepositoryImpl implements HomeRepository {
  final WebAPIService _apiService;

  HomeRepositoryImpl({WebAPIService? apiService})
      : _apiService = apiService ?? WebAPIService();

  @override
  Future<HomeDashboardModel> getDashboardData() async {
    String userName = 'USER';
    double userProgress = 0.65;
    int treesSaved = 11235;
    int rewardPoints = 300;
    int monthlyWasteKg = 50;
    ProfileResponseModel? profileData;

    await _apiService.initTokenToHeader();

    try {
      final response = await _apiService.dio.get(urlProfile);
      if (response.data is Map) {
        final profile = ProfileResponseModel.fromJson(response.data as Map);
        profileData = profile;
        if (profile.fullName.isNotEmpty &&
            profile.fullName.toLowerCase() != 'user') {
          userName = profile.fullName.toUpperCase();
        } else if (profile.user?.firstName != null &&
            profile.user!.firstName!.isNotEmpty) {
          final lastName = profile.user?.lastName ?? '';
          userName = '${profile.user!.firstName!} $lastName'.trim().toUpperCase();
        } else if (profile.username.isNotEmpty) {
          userName = profile.username.toUpperCase();
        }

        if (userName.isNotEmpty && userName != 'USER') {
          SpHelper.saveString('KEY_USER_NAME', userName);
        }

        if (profile.numberOfBags > 0) {
          monthlyWasteKg = profile.numberOfBags * 5;
        }
        if (profile.walletBalance > 0) {
          rewardPoints = profile.walletBalance.toInt();
        }
      }
    } catch (_) {
      // Keep fallback
    }

    return HomeDashboardModel(
      userName: userName.toUpperCase(),
      profile: profileData,
      userProgress: userProgress,
      treesSaved: treesSaved,
      rewardPoints: rewardPoints,
      monthlyWasteKg: monthlyWasteKg,
      categories: const [
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
