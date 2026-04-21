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
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
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
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
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
                      child: _buildAchievementCard(achievement, index),
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

  Widget _buildGlassSurface({
    required Widget child,
    required BorderRadius borderRadius,
    EdgeInsetsGeometry? margin,
    Color tint = Colors.white,
    double tintAlpha = 0.24,
    double sigma = 8,
    Gradient? gradient,
    Border? border,
    List<BoxShadow>? boxShadow,
  }) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: Container(
            decoration: BoxDecoration(
              color:
                  gradient == null ? tint.withValues(alpha: tintAlpha) : null,
              gradient: gradient,
              borderRadius: borderRadius,
              border: border,
              boxShadow: boxShadow ??
                  [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.6),
                      offset: const Offset(-4, -4),
                      blurRadius: 10,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      offset: const Offset(6, 6),
                      blurRadius: 14,
                    ),
                  ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, int index) {
    final isUnlocked = achievement.isUnlocked;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showAchievementDetails(index),
        borderRadius: BorderRadius.circular(20),
        child: _buildGlassSurface(
          margin: const EdgeInsets.only(bottom: 16),
          borderRadius: BorderRadius.circular(20),
          tint: achievement.color,
          tintAlpha: isUnlocked ? 0.04 : 0.07,
          sigma: 9,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.5),
              offset: const Offset(-3, -3),
              blurRadius: 8,
            ),
            BoxShadow(
              color: isUnlocked
                  ? achievement.color.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.07),
              offset: const Offset(5, 6),
              blurRadius: 14,
            ),
          ],
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
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isUnlocked
                              ? [
                                  achievement.color.withValues(alpha: 0.22),
                                  achievement.color.withValues(alpha: 0.1),
                                ]
                              : [
                                  Colors.grey.withValues(alpha: 0.18),
                                  Colors.grey.withValues(alpha: 0.08),
                                ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        achievement.icon,
                        size: 28,
                        color: isUnlocked ? achievement.color : Colors.grey,
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
                                    fontWeight: FontWeight.w600,
                                    color: isUnlocked
                                        ? AppTheme.textDark
                                        : AppTheme.textMedium,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isUnlocked) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.verified_rounded,
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
                          color: isUnlocked
                              ? AppTheme.warning.withValues(alpha: 0.12)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 16,
                              color:
                                  isUnlocked ? AppTheme.warning : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              achievement.points.toString(),
                              style: AppTheme.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                color:
                                    isUnlocked ? AppTheme.warning : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
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
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearPercentIndicator(
                      padding: EdgeInsets.zero,
                      lineHeight: 9,
                      percent: achievement.progressPercentage.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.withValues(alpha: 0.16),
                      progressColor:
                          isUnlocked ? achievement.color : Colors.grey,
                      barRadius: const Radius.circular(8),
                      animation: true,
                      animationDuration: 900,
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

  Future<void> _showAchievementDetails(int initialIndex) async {
    final pageController = PageController(initialPage: initialIndex);
    final currentIndex = ValueNotifier<int>(initialIndex);
    await showGeneralDialog(
      context: context,
      barrierLabel: 'Podrobnosti dosežka',
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ValueListenableBuilder<int>(
          valueListenable: currentIndex,
          builder: (context, index, _) {
            return Center(
              child: Material(
                color: Colors.transparent,
                child: SafeArea(
                  minimum:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragEnd: (details) {
                      final velocity = details.primaryVelocity ?? 0;
                      if (velocity < -250 &&
                          currentIndex.value < achievements.length - 1) {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeInOutCubic,
                        );
                      } else if (velocity > 250 && currentIndex.value > 0) {
                        pageController.previousPage(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeInOutCubic,
                        );
                      }
                    },
                    child: SizedBox(
                      width: 380,
                      height: MediaQuery.of(context).size.height * 0.56,
                      child: PageView.builder(
                        controller: pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (value) => currentIndex.value = value,
                        itemCount: achievements.length,
                        itemBuilder: (context, pageIndex) {
                          final pageAchievement = achievements[pageIndex];
                          final pageUnlocked = pageAchievement.isUnlocked;
                          return _buildGlassSurface(
                            borderRadius: BorderRadius.circular(32),
                            tintAlpha: 0.98,
                            sigma: 12,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.992),
                                Colors.white.withValues(alpha: 0.986),
                                pageAchievement.color
                                    .withValues(alpha: 0.00005),
                              ],
                              stops: const [0.0, 0.62, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.45),
                                offset: const Offset(-4, -4),
                                blurRadius: 10,
                              ),
                              BoxShadow(
                                color: pageUnlocked
                                    ? pageAchievement.color
                                        .withValues(alpha: 0.05)
                                    : Colors.white.withValues(alpha: 0.2),
                                offset: const Offset(6, 8),
                                blurRadius: 18,
                              ),
                            ],
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.6,
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        24, 10, 24, 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          icon: const Icon(Icons.close_rounded),
                                          color: AppTheme.textDark,
                                          splashRadius: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (achievements.length > 1)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        'Povlecite levo/desno za druge dosežke',
                                        style: AppTheme.caption.copyWith(
                                          color: AppTheme.textLight,
                                        ),
                                      ),
                                    ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.fromLTRB(
                                          24, 6, 24, 20),
                                      child: _buildAchievementDetailsBody(
                                          pageAchievement),
                                    ),
                                  ),
                                  if (achievements.length > 1)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                            achievements.length, (dotIndex) {
                                          final active = dotIndex == index;
                                          return AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 180),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 3),
                                            width: active ? 18 : 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: active
                                                  ? pageAchievement.color
                                                  : AppTheme.textLight
                                                      .withValues(alpha: 0.35),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final blurFade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        final dialogAnimation = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.1, 1, curve: Curves.easeOutCubic),
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
            FadeTransition(
              opacity: dialogAnimation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                  CurvedAnimation(
                    parent: dialogAnimation,
                    curve: Curves.easeOutBack,
                  ),
                ),
                child: child,
              ),
            ),
          ],
        );
      },
    );
    pageController.dispose();
    currentIndex.dispose();
  }

  double _achievementCo2SavedKg(Achievement achievement) {
    final text =
        '${achievement.title} ${achievement.description}'.toLowerCase();
    final isCo2Achievement = text.contains('co2') || text.contains('co₂');
    if (isCo2Achievement) {
      return achievement.currentProgress.toDouble();
    }
    // Fallback estimate for non-CO2 achievements.
    return achievement.currentProgress * 0.15;
  }

  Widget _buildAchievementDetailsBody(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;
    final co2SavedKg = _achievementCo2SavedKg(achievement);
    final percent =
        (achievement.progressPercentage * 100).clamp(0, 100).toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        achievement.color.withValues(alpha: 0.2),
                        achievement.color.withValues(alpha: 0.08),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    achievement.icon,
                    size: 42,
                    color: achievement.color,
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: achievement.color.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isUnlocked ? Icons.check_rounded : Icons.lock_rounded,
                      size: 16,
                      color: achievement.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: AppTheme.bodyLarge.copyWith(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement.description,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textMedium,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildGlassSurface(
          borderRadius: BorderRadius.circular(20),
          tint: Colors.transparent,
          tintAlpha: 0.0,
          sigma: 5,
          boxShadow: const [],
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: achievement.progressPercentage.clamp(0.0, 1.0),
                  valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
                  borderRadius: BorderRadius.circular(8),
                  minHeight: 10,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${achievement.currentProgress}/${achievement.maxProgress}',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  isUnlocked ? 'Dosežek dokončan!' : 'Nadaljuj, skoraj si tam.',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildMetaChip(
              icon: Icons.stars_rounded,
              text:
                  '${achievement.points} ${isUnlocked ? "Točk pridobljenih" : "Točk na voljo"}',
              color: achievement.color,
            ),
            _buildMetaChip(
              icon: Icons.eco_rounded,
              text: '${co2SavedKg.toStringAsFixed(1)} kg CO₂',
              color: AppTheme.textMedium,
            ),
            _buildMetaChip(
              icon: isUnlocked ? Icons.check_rounded : Icons.lock_rounded,
              text: isUnlocked
                  ? 'Odklenjeno'
                  : achievement.currentProgress > 0
                      ? 'V procesu'
                      : 'Ni se začeto',
              color: AppTheme.textMedium,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTheme.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
