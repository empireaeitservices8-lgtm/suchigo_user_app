import 'package:flutter/material.dart';

enum WastePropertyType {
  residential,
  commercial,
}

class WasteCategoryDetailModel {
  final String id;
  final int? wasteTypeId;
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final bool isEnabled;

  const WasteCategoryDetailModel({
    required this.id,
    this.wasteTypeId,
    required this.title,
    required this.description,
    required this.icon,
    this.isSelected = false,
    this.isEnabled = true,
  });

  String get formattedTitle {
    final upper = title.trim().toUpperCase();
    if (upper == 'SANITARY WASTE') return 'Sanitary Waste';
    if (upper == 'SOLID WASTE') return 'Solid Waste';
    if (upper == 'ORGANIC WASTE') return 'Organic Waste';
    if (upper == 'E-WASTE') return 'E-Waste';
    return title;
  }

  WasteCategoryDetailModel copyWith({
    bool? isSelected,
    bool? isEnabled,
    int? wasteTypeId,
  }) {
    return WasteCategoryDetailModel(
      id: id,
      wasteTypeId: wasteTypeId ?? this.wasteTypeId,
      title: title,
      description: description,
      icon: icon,
      isSelected: isSelected ?? this.isSelected,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

class SubWasteRateModel {
  final String id;
  final String title;
  final String description;
  final String ratePerKg;
  final bool isActive;
  final String? wasteTypeName;

  const SubWasteRateModel({
    required this.id,
    required this.title,
    required this.description,
    required this.ratePerKg,
    this.isActive = true,
    this.wasteTypeName,
  });

  factory SubWasteRateModel.fromJson(Map<dynamic, dynamic> json) {
    final rate = json['rate_per_kg']?.toString() ?? '0.00';
    return SubWasteRateModel(
      id: json['id']?.toString() ?? '',
      title: json['name']?.toString() ?? json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      ratePerKg: '₹$rate / kg',
      isActive: json['is_active'] == true || json['is_active'] == 1,
      wasteTypeName: json['waste_type_name']?.toString(),
    );
  }
}
