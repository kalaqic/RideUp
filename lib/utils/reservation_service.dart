import 'dart:async';

import 'package:flutter/foundation.dart';

class ReservationService extends ChangeNotifier {
  static final ReservationService _instance = ReservationService._internal();
  factory ReservationService() => _instance;
  ReservationService._internal();

  static const Duration reservationDuration = Duration(minutes: 10);

  Timer? _timer;
  String? _reservedStationId;
  DateTime? _reservedUntil;

  String? get reservedStationId => _reservedStationId;
  DateTime? get reservedUntil => _reservedUntil;

  bool get hasActiveReservation {
    if (_reservedStationId == null || _reservedUntil == null) return false;
    return _reservedUntil!.isAfter(DateTime.now());
  }

  bool isReservedForStation(String stationId) {
    return hasActiveReservation && _reservedStationId == stationId;
  }

  Duration get remainingTime {
    if (!hasActiveReservation || _reservedUntil == null) {
      return Duration.zero;
    }
    final diff = _reservedUntil!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  String get formattedRemainingTime {
    final remaining = remainingTime;
    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void reserveStation(String stationId) {
    _reservedStationId = stationId;
    _reservedUntil = DateTime.now().add(reservationDuration);
    _startTicker();
    notifyListeners();
  }

  void cancelReservation() {
    _timer?.cancel();
    _timer = null;
    _reservedStationId = null;
    _reservedUntil = null;
    notifyListeners();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!hasActiveReservation) {
        cancelReservation();
        return;
      }
      notifyListeners();
    });
  }
}
