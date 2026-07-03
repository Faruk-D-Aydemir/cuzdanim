import 'package:flutter/material.dart';

class ChildProfile {
  ChildProfile({
    required this.id,
    required this.name,
    this.weeklyLimit,
    this.colorValue = 0xFF7B1FA2,
  });

  final String id;
  final String name;
  final double? weeklyLimit;
  final int colorValue;

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'weeklyLimit': weeklyLimit,
    'colorValue': colorValue,
  };

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      weeklyLimit: json['weeklyLimit'] != null
          ? (json['weeklyLimit'] as num).toDouble()
          : null,
      colorValue: json['colorValue'] as int? ?? 0xFF7B1FA2,
    );
  }
}

enum SessionRole { parent, child }
