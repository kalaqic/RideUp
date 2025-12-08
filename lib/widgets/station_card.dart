import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../models/models.dart';

class StationCard extends StatelessWidget {
  final BikeStation station;
  final bool isSelected;
  final VoidCallback onTap;

  const StationCard({
    super.key,
    required this.station,
    required this.isSelected,
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
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isSelected ? 0.95 : 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.primaryColor.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
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
              ],
            ),
            Row(
              children: [
                _buildIconStat(
                  icon: Icons.pedal_bike,
                  value: station.availableBikes.toString(),
                  color: station.availableBikes > 5
                      ? AppTheme.success
                      : station.availableBikes > 0
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
