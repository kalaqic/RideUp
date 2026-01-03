import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/models.dart';
import 'achievements_screen.dart';
import 'map_screen.dart';

class RideSummaryScreen extends StatefulWidget {
  final Ride ride;

  const RideSummaryScreen({
    super.key,
    required this.ride,
  });

  @override
  State<RideSummaryScreen> createState() => _RideSummaryScreenState();
}

class _RideSummaryScreenState extends State<RideSummaryScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimations = List.generate(4, (index) {
      return Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Interval(
          index * 0.2,
          0.6 + index * 0.1,
          curve: Curves.easeOutCubic,
        ),
      ));
    });

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carbonSaved = (widget.ride.distance * 0.21).toStringAsFixed(1);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.radialGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Title
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.success.withValues(alpha: 0.1),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 40,
                          color: AppTheme.success,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Vožnja dokončana',
                        style: AppTheme.titleLarge.copyWith(
                          color: AppTheme.titleBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Odlično delo!',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textLight,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Stats
                Column(
                    children: [
                      SlideTransition(
                        position: _slideAnimations[0],
                        child: _buildStatCard(
                          icon: Icons.timer_outlined,
                          value: '${widget.ride.duration}',
                          unit: 'min',
                          label: 'Trajanje',
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SlideTransition(
                        position: _slideAnimations[1],
                        child: _buildStatCard(
                          icon: Icons.route,
                          value: widget.ride.distance.toStringAsFixed(1),
                          unit: 'km',
                          label: 'Razdalja',
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SlideTransition(
                        position: _slideAnimations[2],
                        child: _buildStatCard(
                          icon: Icons.stars,
                          value: widget.ride.points.toString(),
                          unit: 'pts',
                          label: 'Pridobljene točke',
                          color: AppTheme.warning,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SlideTransition(
                        position: _slideAnimations[3],
                        child: _buildStatCard(
                          icon: Icons.eco,
                          value: carbonSaved,
                          unit: 'kg',
                          label: 'Prihranjeno CO₂',
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                ),
                const SizedBox(height: 32),
                // Buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        height: 56,
                        decoration: AppTheme.neomorphicButton(
                          color: AppTheme.primaryColor,
                          borderRadius: 16,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                      const AchievementsScreen(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                  transitionDuration: const Duration(milliseconds: 300),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Center(
                              child: Text(
                                'Poglej dosežke',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        height: 56,
                        decoration: AppTheme.neomorphicRaised(borderRadius: 16),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                      const MapScreen(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                  transitionDuration: const Duration(milliseconds: 300),
                                ),
                                (route) => false,
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Center(
                              child: Text(
                                'Nazaj na zemljevid',
                                style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String unit,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: AppTheme.neomorphicRaised(borderRadius: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
                Text(
                  label,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
