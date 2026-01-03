import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/subscription_service.dart';
import '../models/models.dart';
import '../data/mock_data.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

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
          backgroundColor: AppTheme.error,
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
          decoration: AppTheme.neomorphicRaised(borderRadius: 24),
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
                  decoration: AppTheme.neomorphicFlat(
                    borderRadius: 12,
                    color: Colors.white,
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
                      decoration: AppTheme.neomorphicFlat(
                        borderRadius: 16,
                        color: Colors.white,
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
          decoration: AppTheme.neomorphicRaised(borderRadius: 24),
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
          decoration: AppTheme.neomorphicRaised(borderRadius: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration icon
              Container(
                width: 80,
                height: 80,
                decoration: AppTheme.neomorphicRaised(
                  borderRadius: 40,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.celebration,
                  size: 40,
                  color: AppTheme.success,
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
                decoration: AppTheme.neomorphicFlat(borderRadius: 16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.eco,
                      size: 32,
                      color: AppTheme.success,
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
              // Header with back button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        'Trgovina',
                        style: AppTheme.titleLarge.copyWith(
                          color: AppTheme.titleBlue,
                        ),
                      ),
                    ),
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
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),
                        // Subscription card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: AppTheme.neomorphicRaised(
                            borderRadius: 20,
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.card_membership,
                                size: 48,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Mesečna naročnina',
                                style: AppTheme.displaySmall.copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Dostop do vseh funkcionalnosti za en mesec',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textMedium,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              // Purchase option 1: Points
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: AppTheme.neomorphicFlat(
                                  borderRadius: 16,
                                  color: Colors.white,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.stars,
                                          size: 24,
                                          color: AppTheme.warning,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '10.000 točk',
                                          style: AppTheme.bodyLarge.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Vaše točke: ${profile.totalPoints.toString()}',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.textMedium,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      height: 48,
                                      decoration: AppTheme.neomorphicButton(
                                        color: canPurchaseWithPoints
                                            ? AppTheme.warning
                                            : Colors.grey,
                                        borderRadius: 12,
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: canPurchaseWithPoints
                                              ? () => _handlePurchase(context, profile, true)
                                              : null,
                                          borderRadius: BorderRadius.circular(12),
                                          child: Center(
                                            child: Text(
                                              canPurchaseWithPoints
                                                  ? 'Kupi z točkami'
                                                  : 'Premalo točk',
                                              style: AppTheme.bodyMedium.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Divider with OR
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: Colors.grey.withValues(alpha: 0.2),
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
                                      color: Colors.grey.withValues(alpha: 0.2),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Purchase option 2: Achievements
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: AppTheme.neomorphicFlat(
                                  borderRadius: 16,
                                  color: Colors.white,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.emoji_events,
                                          size: 24,
                                          color: AppTheme.success,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '3 dosežki',
                                          style: AppTheme.bodyLarge.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Vaši odklenjeni dosežki: $unlockedCount',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.textMedium,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      height: 48,
                                      decoration: AppTheme.neomorphicButton(
                                        color: canPurchaseWithAchievements
                                            ? AppTheme.success
                                            : Colors.grey,
                                        borderRadius: 12,
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: canPurchaseWithAchievements
                                              ? () => _handlePurchase(context, profile, false)
                                              : null,
                                          borderRadius: BorderRadius.circular(12),
                                          child: Center(
                                            child: Text(
                                              canPurchaseWithAchievements
                                                  ? 'Kupi z dosežki'
                                                  : 'Premalo dosežkov',
                                              style: AppTheme.bodyMedium.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
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
}

