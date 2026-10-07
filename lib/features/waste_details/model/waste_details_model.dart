import 'package:flutter/material.dart';

enum WastePropertyType {
  residential,
  commercial,
}

class WasteCategoryDetailModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;

  const WasteCategoryDetailModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isSelected = false,
  });

  WasteCategoryDetailModel copyWith({bool? isSelected}) {
    return WasteCategoryDetailModel(
      id: id,
      title: title,
      description: description,
      icon: icon,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class SubWasteRateModel {
  final String id;
  final String title;
  final String description;
  final String ratePerKg;

  const SubWasteRateModel({
    required this.id,
    required this.title,
    required this.description,
    required this.ratePerKg,
  });
}
