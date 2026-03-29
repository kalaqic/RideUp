import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/subscription_service.dart';
import '../models/models.dart';
import '../data/mock_data.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  BoxDecoration _popupSurfaceDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(Colors.white, AppTheme.primaryColor, 0.14)!,
          Color.lerp(Colors.white, AppTheme.primaryLight, 0.09)!,
          Colors.white,
        ],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: AppTheme.primaryColor.withValues(alpha: 0.12),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  BoxDecoration _shopCardDecoration({
    required double borderRadius,
    double primaryAlpha = 0.08,
    double lightAlpha = 0.05,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(Colors.white, AppTheme.primaryColor, primaryAlpha)!,
          Color.lerp(Colors.white, AppTheme.primaryLight, lightAlpha)!,
          Colors.white,
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: AppTheme.primaryColor.withValues(alpha: 0.10),
      ),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primaryColor.withValues(alpha: 0.08),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  bool _canPurchaseWithPoints(UserProfile profile) {
    return profile.totalPoints >= 10000;
  }

  bool _canPurchaseWithAchievements(UserProfile profile) {
    final unlockedAchievements = profile.achievements.where((a) => a.isUnlocked).length;
    return unlockedAchievements >= 3;
  }

  void _handlePurchase(BuildContext context, UserProfile profile, bool usePoints) {
    final canPurchase = usePoints 
        ? _canPurchaseWithPoints(profile)
        : _canPurchaseWithAchievements(profile);

    if (!canPurchase) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            usePoints
                ? 'Nimate dovolj točk. Potrebujete 10.000 točk.'
                : 'Nimate dovolj dosežkov. Potrebujete 3 odklenjena dosežka.',
          ),
          backgroundColor: AppTheme.primaryDark,
        ),
      );
      return;
    }

    // Step 1: Show confirmation dialog
    final pointsLeft = usePoints ? profile.totalPoints - 10000 : profile.totalPoints;
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: _popupSurfaceDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline,
                size: 48,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Potrdite nakup',
                style: AppTheme.displaySmall.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                usePoints
                    ? 'Ali ste prepričani, da želite porabiti 10.000 točk za mesečno naročnino?'
                    : 'Ali ste prepričani, da želite uporabiti 3 dosežke za mesečno naročnino?',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textMedium,
                ),
                textAlign: TextAlign.center,
              ),
              if (usePoints) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Preostale točke: ',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textMedium,
                        ),
                      ),
                      Text(
                        '$pointsLeft',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(dialogContext),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Center(
                              child: Text(
                                'Prekliči',
                                style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textMedium,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: AppTheme.neomorphicButton(
                        color: AppTheme.primaryColor,
                        borderRadius: 16,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(dialogContext);
                            _showLoadingAndSuccess(context, profile, usePoints);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Center(
                              child: Text(
                                'Potrdi',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
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
    );
  }

  void _showLoadingAndSuccess(BuildContext context, UserProfile profile, bool usePoints) {
    // Activate subscription
    SubscriptionService().activateSubscription(purchasedWithPoints: usePoints);
    
    // Step 2: Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(48),
          decoration: _popupSurfaceDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Obdelava...',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Simulate processing time
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog
      if (!context.mounted) return;
      _showSuccessDialog(context);
    });
  }

  void _showSuccessDialog(BuildContext context) {
    // Step 3: Show success dialog with inspiring message
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: _popupSurfaceDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.12),
                      AppTheme.primaryLight.withValues(alpha: 0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.10),
                  ),
                ),
                child: const Icon(
                  Icons.celebration,
                  size: 40,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'Čestitamo! 🎉',
                style: AppTheme.displaySmall.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Main message
              Text(
                'Vaša mesečna naročnina je aktivirana!',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Inspiring message
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.10),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.eco,
                      size: 32,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Skupaj delamo za bolj zeleno prihodnost!',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Z vašo odločitvijo pomagate ohranjati naš planet in zmanjšujete ogljični odtis. Hvala, da izbirate trajnostno mobilnost! 🌱',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textMedium,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Close button
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: AppTheme.neomorphicButton(
                    color: AppTheme.primaryColor,
                    borderRadius: 16,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context); // Also close the shop screen
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            'Odlično!',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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

  @override
  Widget build(BuildContext context) {
    final profile = MockData.getUserProfile();
    final canPurchaseWithPoints = _canPurchaseWithPoints(profile);
    final canPurchaseWithAchievements = _canPurchaseWithAchievements(profile);
    final unlockedCount = profile.achievements.where((a) => a.isUnlocked).length;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.radialGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        'Trgovina',
                        style: AppTheme.titleMedium.copyWith(
                          fontSize: 36,
                          color: AppTheme.titleBlue,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.10),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                          decoration: _shopCardDecoration(
                            borderRadius: 28,
                            primaryAlpha: 0.12,
                            lightAlpha: 0.08,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppTheme.primaryColor,
                                          AppTheme.primaryLight,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryColor.withValues(alpha: 0.20),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.workspace_premium_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Mesečna naročnina',
                                          style: AppTheme.titleSmall.copyWith(
                                            color: AppTheme.titleBlue,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Dostop do vseh funkcionalnosti za en mesec',
                                          style: AppTheme.bodyMedium.copyWith(
                                            color: AppTheme.textMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _featureChip(Icons.qr_code_scanner, 'Hitrejši dostop'),
                                  _featureChip(Icons.emoji_events_outlined, 'Nagrade'),
                                  _featureChip(Icons.eco_outlined, 'Moj vpliv'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: _shopCardDecoration(
                            borderRadius: 24,
                            primaryAlpha: 0.09,
                            lightAlpha: 0.06,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Izberite način nakupa',
                                style: AppTheme.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Uporabite točke ali odklenjene dosežke.',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textMedium,
                                ),
                              ),
                              const SizedBox(height: 24),
                              _purchaseOptionCard(
                                title: 'Nakup s točkami',
                                subtitle: 'Potrebujete 10.000 točk za 1 mesec naročnine.',
                                requirement: '10.000 točk',
                                currentValue: 'Vaše točke: ${profile.totalPoints}',
                                icon: Icons.stars_rounded,
                                accentColor: AppTheme.primaryColor,
                                enabled: canPurchaseWithPoints,
                                buttonText: canPurchaseWithPoints
                                    ? 'Kupi s točkami'
                                    : 'Premalo točk',
                                onTap: canPurchaseWithPoints
                                    ? () => _handlePurchase(context, profile, true)
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: AppTheme.primaryColor.withValues(alpha: 0.16),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'ALI',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.textLight,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: AppTheme.primaryColor.withValues(alpha: 0.16),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _purchaseOptionCard(
                                title: 'Nakup z dosežki',
                                subtitle: 'Zamenjajte 3 odklenjene dosežke za 1 mesec naročnine.',
                                requirement: '3 dosežki',
                                currentValue: 'Odklenjeni dosežki: $unlockedCount',
                                icon: Icons.emoji_events_rounded,
                                accentColor: AppTheme.primaryLight,
                                enabled: canPurchaseWithAchievements,
                                buttonText: canPurchaseWithAchievements
                                    ? 'Kupi z dosežki'
                                    : 'Premalo dosežkov',
                                onTap: canPurchaseWithAchievements
                                    ? () => _handlePurchase(context, profile, false)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.82),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.primaryColor.withValues(alpha: 0.10),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.info_outline,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  'Naročnina se aktivira takoj po potrditvi nakupa.',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.textMedium,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
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

  Widget _featureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _purchaseOptionCard({
    required String title,
    required String subtitle,
    required String requirement,
    required String currentValue,
    required IconData icon,
    required Color accentColor,
    required bool enabled,
    required String buttonText,
    required VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accentColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textMedium,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  requirement,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  currentValue,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: enabled
                  ? accentColor
                  : Color.lerp(Colors.white, AppTheme.primaryLight, 0.55)!,
              borderRadius: BorderRadius.circular(14),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.22),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(14),
                child: Center(
                  child: Text(
                    buttonText,
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

