import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/models.dart';

class StationCard extends StatelessWidget {
  final BikeStation station;
  final int availableBikes;
  final bool isSelected;
  final String? reservationText;
  final VoidCallback onTap;

  const StationCard({
    super.key,
    required this.station,
    required this.availableBikes,
    required this.isSelected,
    this.reservationText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 180,
        padding: const EdgeInsets.all(20),
        decoration: isSelected
            ? AppTheme.neomorphicPressed()
            : AppTheme.neomorphicRaised(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${station.distance} km stran',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textLight,
                  ),
                ),
                if (reservationText != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            reservationText!,
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            Row(
              children: [
                _buildIconStat(
                  icon: Icons.pedal_bike,
                  value: availableBikes.toString(),
                  color: availableBikes > 5
                      ? AppTheme.success
                      : availableBikes > 0
                          ? AppTheme.warning
                          : AppTheme.error,
                ),
                const SizedBox(width: 16),
                _buildIconStat(
                  icon: Icons.local_parking,
                  value: (station.totalSlots - station.availableBikes)
                      .toString(),
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconStat({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
