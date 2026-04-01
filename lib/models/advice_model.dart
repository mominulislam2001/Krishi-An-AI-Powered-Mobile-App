import 'package:flutter/material.dart';

enum AdviceSeverity { urgent, recommended, optional }

class AgriAdvice {
  final String title;
  final String description;
  final AdviceSeverity severity;
  final String cropType;
  final String season;
  final String weather;
  final IconData icon;

  AgriAdvice({
    required this.title,
    required this.description,
    required this.severity,
    required this.cropType,
    required this.season,
    required this.weather,
    required this.icon,
  });
}