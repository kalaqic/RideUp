import 'package:flutter/material.dart';

class BikeStation {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int availableBikes;
  final int totalSlots;
  final double distance;

  BikeStation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.availableBikes,
    required this.totalSlots,
    required this.distance,
  });
}

class Ride {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final double distance;
  final int duration; // in minutes
  final int points;
  final String startStation;
  final String endStation;

  Ride({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.distance,
    required this.duration,
    required this.points,
    required this.startStation,
    required this.endStation,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int maxProgress;
  final int currentProgress;
  final bool isUnlocked;
  final int points;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.maxProgress,
    required this.currentProgress,
    required this.isUnlocked,
    required this.points,
  });

  double get progressPercentage => currentProgress / maxProgress;
}

class UserProfile {
  final String name;
  final String email;
  final int totalRides;
  final double totalDistance;
  final int totalPoints;
  final int carbonSaved; // in kg
  final List<Ride> recentRides;
  final List<Achievement> achievements;
  final String memberSince;
  final bool hasActiveSubscription;
  final DateTime? subscriptionRenewalDate;
  final bool? subscriptionPurchasedWithPoints; // null if no subscription, true if purchased with points, false if with achievements

  UserProfile({
    required this.name,
    required this.email,
    required this.totalRides,
    required this.totalDistance,
    required this.totalPoints,
    required this.carbonSaved,
    required this.recentRides,
    required this.achievements,
    required this.memberSince,
    this.hasActiveSubscription = false,
    this.subscriptionRenewalDate,
    this.subscriptionPurchasedWithPoints,
  });
}
