import 'package:flutter/material.dart';

class CreditCardInfo {
  CreditCardInfo({
    required this.id,
    required this.name,
    required this.dueDay,
    this.lastFourDigits = '',
    this.colorValue = 0xFF1565C0,
  });

  final String id;
  final String name;
  final int dueDay;
  final String lastFourDigits;
  final int colorValue;

  Color get color => Color(colorValue);

  int daysUntilDue([DateTime? from]) {
    final now = from ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var dueDate = DateTime(now.year, now.month, dueDay);
    if (!dueDate.isAfter(today)) {
      dueDate = DateTime(now.year, now.month + 1, dueDay);
    }
    return dueDate.difference(today).inDays;
  }

  DateTime nextDueDate([DateTime? from]) {
    final now = from ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var dueDate = DateTime(now.year, now.month, dueDay);
    if (!dueDate.isAfter(today)) {
      dueDate = DateTime(now.year, now.month + 1, dueDay);
    }
    return dueDate;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dueDay': dueDay,
    'lastFourDigits': lastFourDigits,
    'colorValue': colorValue,
  };

  factory CreditCardInfo.fromJson(Map<String, dynamic> json) {
    return CreditCardInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      dueDay: json['dueDay'] as int,
      lastFourDigits: json['lastFourDigits'] as String? ?? '',
      colorValue: json['colorValue'] as int? ?? 0xFF1565C0,
    );
  }
}
