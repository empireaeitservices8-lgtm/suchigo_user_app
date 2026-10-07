import 'package:flutter/material.dart';
import '../model/waste_details_model.dart';

abstract class WasteDetailsRepository {
  Future<List<WasteCategoryDetailModel>> getWasteCategories(
      WastePropertyType type);
  Future<List<SubWasteRateModel>> getSubWasteRates(String categoryId);
}

class WasteDetailsRepositoryImpl implements WasteDetailsRepository {
  @override
  Future<List<WasteCategoryDetailModel>> getWasteCategories(
      WastePropertyType type) async {
    return const [
      WasteCategoryDetailModel(
        id: 'sanitary',
        title: 'SANITARY WASTE',
        description: 'Diaper, Sanitary Pad,\nExpired Medicine, Hair Waste',
        icon: Icons.child_friendly_outlined,
      ),
      WasteCategoryDetailModel(
        id: 'solid',
        title: 'SOLID WASTE',
        description: 'Paper, Plastic, Metals,\nE-Waste, Glass, Wood',
        icon: Icons.delete_outline_rounded,
      ),
      WasteCategoryDetailModel(
        id: 'organic',
        title: 'ORGANIC WASTE',
        description: 'Food Scraps, Garden\nWaste, Compostables',
        icon: Icons.eco_outlined,
      ),
      WasteCategoryDetailModel(
        id: 'e_waste',
        title: 'E-WASTE',
        description: 'Electronics, Batteries,\nCables, Old Devices',
        icon: Icons.devices_other_outlined,
      ),
    ];
  }

  @override
  Future<List<SubWasteRateModel>> getSubWasteRates(String categoryId) async {
    return const [
      SubWasteRateModel(
        id: 'food_waste',
        title: 'Food Waste',
        description: 'Kitchen and food scraps',
        ratePerKg: '₹5.00 / kg',
      ),
    ];
  }
}
