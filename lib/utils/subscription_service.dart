import 'package:flutter/foundation.dart';

class SubscriptionService extends ChangeNotifier {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  bool _hasActiveSubscription = false;
  DateTime? _renewalDate;
  bool? _purchasedWithPoints; // null = no subscription, true = purchased with points, false = with achievements

  bool get hasActiveSubscription => _hasActiveSubscription;
  DateTime? get renewalDate => _renewalDate;
  bool? get purchasedWithPoints => _purchasedWithPoints;

  void activateSubscription({required bool purchasedWithPoints}) {
    _hasActiveSubscription = true;
    _purchasedWithPoints = purchasedWithPoints;
    // Always set renewal date to 30 days from now (even if paused with points)
    _renewalDate = DateTime.now().add(const Duration(days: 30));
    notifyListeners();
  }

  void cancelSubscription() {
    _hasActiveSubscription = false;
    _renewalDate = null;
    _purchasedWithPoints = null;
    notifyListeners();
  }
}

