import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/models.dart';
import 'ride_screen.dart';

class QRScanScreen extends StatefulWidget {
  final BikeStation station;

  const QRScanScreen({
    super.key,
    required this.station,
  });

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scanController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  void _simulateScan() {
    setState(() {
      _isScanning = true;
    });

    // Simulate scanning delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                RideScreen(startStation: widget.station),
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
    });
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
                child: Row(
                  children: [
                    Container(
                      decoration: AppTheme.neomorphicRaised(borderRadius: 12),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Skeniraj QR kodo',
                            style: AppTheme.titleSmall.copyWith(
                              fontSize: 28,
                              color: AppTheme.titleBlue,
                            ),
                          ),
                          Text(
                            widget.station.name,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Scanner area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: AppTheme.neomorphicRaised(borderRadius: 24),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // QR code corners
                            ...List.generate(4, (index) {
                              final isTop = index < 2;
                              final isLeft = index % 2 == 0;
                              return Positioned(
                                top: isTop ? 24 : null,
                                bottom: !isTop ? 24 : null,
                                left: isLeft ? 24 : null,
                                right: !isLeft ? 24 : null,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: isTop
                                          ? BorderSide(
                                              color: AppTheme.primaryColor,
                                              width: 3,
                                            )
                                          : BorderSide.none,
                                      bottom: !isTop
                                          ? const BorderSide(
                                              color: AppTheme.primaryColor,
                                              width: 3,
                                            )
                                          : BorderSide.none,
                                      left: isLeft
                                          ? const BorderSide(
                                              color: AppTheme.primaryColor,
                                              width: 3,
                                            )
                                          : BorderSide.none,
                                      right: !isLeft
                                          ? const BorderSide(
                                              color: AppTheme.primaryColor,
                                              width: 3,
                                            )
                                          : BorderSide.none,
                                    ),
                                  ),
                                ),
                              );
                            }),
                            // Scanning line animation
                            if (_isScanning)
                              AnimatedBuilder(
                                animation: _scanAnimation,
                                builder: (context, child) {
                                  return Positioned(
                                    top: _scanAnimation.value *
                                        (MediaQuery.of(context).size.width -
                                            148),
                                    left: 24,
                                    right: 24,
                                    child: Container(
                                      height: 2,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            AppTheme.primaryColor,
                                            AppTheme.primaryColor,
                                            Colors.transparent,
                                          ],
                                          stops: const [0.0, 0.2, 0.8, 1.0],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primaryColor
                                                .withValues(alpha: 0.5),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            // Center icon
                            if (!_isScanning)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_2,
                                    size: 120,
                                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Postavite QR kodo sem',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.textLight,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            if (_isScanning)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Skeniram...',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.primaryColor,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Instructions
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Text(
                      'Skenirajte QR kodo na kolesu',
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.textDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Poskrbite, da je koda jasno vidna',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: AppTheme.neomorphicRaised(borderRadius: 16),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isScanning ? null : _simulateScan,
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Text(
                              'Simuliraj skeniranje',
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
