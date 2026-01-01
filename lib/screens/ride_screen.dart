import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/models.dart';
import 'ride_summary_screen.dart';

class RideScreen extends StatefulWidget {
  final BikeStation startStation;

  const RideScreen({
    super.key,
    required this.startStation,
  });

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _secondsElapsed = 0;
  double _distance = 0;
  double _speed = 0;
  int _points = 0;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _speedController;
  late Animation<double> _speedAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _speedController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _speedAnimation = Tween<double>(
      begin: 15.0,
      end: 22.0,
    ).animate(CurvedAnimation(
      parent: _speedController,
      curve: Curves.easeInOut,
    ));

    _startRide();
  }

  void _startRide() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
        _distance += (18 + (_secondsElapsed % 5)) / 3600; // Simulate distance
        _speed = _speedAnimation.value;
        _points = (_distance * 10).round();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _speedController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _endRide() {
    _timer?.cancel();
    
    final ride = Ride(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now().subtract(Duration(seconds: _secondsElapsed)),
      endTime: DateTime.now(),
      distance: _distance,
      duration: _secondsElapsed ~/ 60,
      points: _points,
      startStation: widget.startStation.name,
      endStation: widget.startStation.name, // Same station for simplicity
    );

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            RideSummaryScreen(ride: ride),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.radialGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  children: [
                    Text(
                      'Vozim',
                      style: AppTheme.titleLarge.copyWith(
                        color: AppTheme.titleBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppTheme.success,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.success.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Timer
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Time display
                      Container(
                        width: 200,
                        height: 200,
                        decoration: AppTheme.neomorphicRaised(
                          borderRadius: 100,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatTime(_secondsElapsed),
                                style: AppTheme.displayLarge.copyWith(
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                'Trajanje',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.textLight,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 64),
                      // Stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStat(
                            value: _distance.toStringAsFixed(2),
                            unit: 'km',
                            label: 'Razdalja',
                            icon: Icons.route,
                          ),
                          _buildStat(
                            value: _speed.toStringAsFixed(0),
                            unit: 'km/h',
                            label: 'Hitrost',
                            icon: Icons.speed,
                          ),
                          _buildStat(
                            value: _points.toString(),
                            unit: 'pts',
                            label: 'Točke',
                            icon: Icons.stars,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Station info
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.neomorphicRaised(borderRadius: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Začetek iz',
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.textLight,
                            ),
                          ),
                          Text(
                            widget.startStation.name,
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // End ride button
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: double.infinity,
                  height: 64,
                  decoration: AppTheme.neomorphicButton(
                    color: AppTheme.error,
                    borderRadius: 16,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _endRide,
                      borderRadius: BorderRadius.circular(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.stop, color: Colors.white),
                          const SizedBox(width: 12),
                          Text(
                            'Zaključi vožnjo',
                            style: AppTheme.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat({
    required String value,
    required String unit,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor.withValues(alpha: 0.5),
          size: 24,
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: AppTheme.displaySmall.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: AppTheme.caption.copyWith(
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.caption.copyWith(
            color: AppTheme.textLight,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
