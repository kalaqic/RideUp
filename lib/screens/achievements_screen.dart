import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../utils/app_theme.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import '../widgets/bottom_nav.dart';
import 'map_screen.dart';
import 'profile_screen.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  final List<Achievement> achievements = MockData.getAchievements();
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      achievements.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + index * 100),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutBack,
      );
    }).toList();

    // Start animations with stagger
    Future.delayed(const Duration(milliseconds: 100), () {
      for (int i = 0; i < _controllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 100), () {
          if (mounted) {
            _controllers[i].forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
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
        );
        break;
      case 1:
        // Already on achievements
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const ProfileScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final totalPoints = achievements
        .where((a) => a.isUnlocked)
        .fold(0, (sum, a) => sum + a.points);

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
                      'Dosežki',
                      style: AppTheme.titleMedium.copyWith(
                        fontSize: 36,
                        color: AppTheme.titleBlue,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHeaderStat(
                          value: unlockedCount.toString(),
                          total: achievements.length.toString(),
                          label: 'Odklenjen',
                        ),
                        Container(
                          height: 30,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        ),
                        _buildHeaderStat(
                          value: totalPoints.toString(),
                          label: 'Skupne točke',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Achievements list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    return ScaleTransition(
                      scale: _animations[index],
                      child: _buildAchievementCard(achievement),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildHeaderStat({
    required String value,
    String? total,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: AppTheme.displaySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
            ),
            if (total != null) ...[
              Text(
                ' / ',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textLight,
                ),
              ),
              Text(
                total,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textLight,
                ),
              ),
            ],
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

  Widget _buildAchievementCard(Achievement achievement) {
    return GestureDetector(
      onTap: () => _showAchievementDetails(achievement),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: achievement.isUnlocked
            ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: achievement.color.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: achievement.color.withValues(alpha: 0.15),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
              )
            : AppTheme.neomorphicFlat(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: achievement.isUnlocked
                        ? achievement.color.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    achievement.icon,
                    size: 28,
                    color: achievement.isUnlocked
                        ? achievement.color
                        : Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              achievement.title,
                              style: AppTheme.bodyLarge.copyWith(
                                fontWeight: FontWeight.w500,
                                color: achievement.isUnlocked
                                    ? AppTheme.textDark
                                    : AppTheme.textLight,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (achievement.isUnlocked) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.verified,
                              size: 20,
                              color: achievement.color,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.description,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (achievement.points > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: achievement.isUnlocked
                          ? AppTheme.warning.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: achievement.isUnlocked
                              ? AppTheme.warning
                              : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          achievement.points.toString(),
                          style: AppTheme.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: achievement.isUnlocked
                                ? AppTheme.warning
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Napredek',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                    Text(
                      '${achievement.currentProgress} / ${achievement.maxProgress}',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearPercentIndicator(
                  padding: EdgeInsets.zero,
                  lineHeight: 8,
                  percent: achievement.progressPercentage.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  progressColor: achievement.isUnlocked
                      ? achievement.color
                      : Colors.grey,
                  barRadius: const Radius.circular(4),
                  animation: true,
                  animationDuration: 1000,
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  void _showAchievementDetails(Achievement achievement) {
    showGeneralDialog(
      context: context,
      barrierLabel: 'Podrobnosti dosežka',
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(Colors.white, achievement.color, 0.12)!,
                    Color.lerp(Colors.white, achievement.color, 0.06)!,
                    Colors.white,
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: achievement.color.withValues(alpha: 0.10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    offset: const Offset(0, 12),
                    blurRadius: 28,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.textMedium,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: achievement.color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          achievement.icon,
                          size: 60,
                          color: achievement.color,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          Text(
                            achievement.title,
                            style: AppTheme.titleSmall.copyWith(
                              fontSize: 28,
                              color: AppTheme.titleBlue,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (achievement.isUnlocked)
                            Icon(
                              Icons.verified,
                              size: 28,
                              color: achievement.color,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        achievement.description,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textMedium,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.pastelLavender.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Napredek',
                                  style: AppTheme.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${achievement.currentProgress}/${achievement.maxProgress}',
                                  style: AppTheme.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: achievement.color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: achievement.progressPercentage,
                              backgroundColor: Colors.grey.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
                              borderRadius: BorderRadius.circular(8),
                              minHeight: 8,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              achievement.isUnlocked
                                  ? 'Dosežek dokončan!'
                                  : '${(achievement.progressPercentage * 100).toInt()}% dokončano',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: achievement.isUnlocked
                              ? AppTheme.success.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.stars,
                              size: 20,
                              color: achievement.isUnlocked ? AppTheme.success : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${achievement.points} ${achievement.isUnlocked ? "Točk pridobljenih" : "Točk na voljo"}',
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                                color: achievement.isUnlocked ? AppTheme.success : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final blurFade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        final popupAnimation = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.18, 1, curve: Curves.easeOutCubic),
        );
        return Stack(
          children: [
            Positioned.fill(
              child: FadeTransition(
                opacity: blurFade,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.22),
                    ),
                  ),
                ),
              ),
            ),
            _DismissibleAchievementPopup(
              onDismiss: () => Navigator.of(context).pop(),
              child: FadeTransition(
                opacity: popupAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.14),
                    end: Offset.zero,
                  ).animate(popupAnimation),
                  child: child,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DismissibleAchievementPopup extends StatefulWidget {
  const _DismissibleAchievementPopup({
    required this.child,
    required this.onDismiss,
  });

  final Widget child;
  final VoidCallback onDismiss;

  @override
  State<_DismissibleAchievementPopup> createState() =>
      _DismissibleAchievementPopupState();
}

class _DismissibleAchievementPopupState
    extends State<_DismissibleAchievementPopup> {
  double _dragOffset = 0;
  bool _isDragging = false;

  void _onDragStart() {
    setState(() {
      _isDragging = true;
    });
  }

  void _onDragUpdate(double delta) {
    setState(() {
      _dragOffset = (_dragOffset + delta).clamp(0.0, 260.0);
    });
  }

  void _resetDrag() {
    setState(() {
      _dragOffset = 0;
      _isDragging = false;
    });
  }

  void _onDragEnd(double? velocity) {
    final shouldDismiss =
        _dragOffset > 120 || velocity != null && velocity > 900;
    if (shouldDismiss) {
      widget.onDismiss();
      return;
    }
    _resetDrag();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: _isDragging ? 0 : 180),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, _dragOffset, 0),
      child: Stack(
        children: [
          widget.child,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 72,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragStart: (_) => _onDragStart(),
              onVerticalDragUpdate: (details) => _onDragUpdate(details.delta.dy),
              onVerticalDragEnd: (details) => _onDragEnd(details.primaryVelocity),
              onVerticalDragCancel: _resetDrag,
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}
