import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/app_theme.dart';
import '../models/models.dart';
import '../data/mock_data.dart';

/// CO₂ saved per km (150g/km average car).
const double co2KgPerKm = 0.15;

/// Average car consumption L/100km.
const double fuelLPer100Km = 7.0;

/// Fuel price €/L.
const double fuelEurPerL = 1.7;

/// Shared analytics computed from ride list. Used by impact screen and detail pages.
class ImpactStats {
  ImpactStats(List<Ride> rides) : _rides = rides;
  final List<Ride> _rides;

  double get totalKm => _rides.fold(0.0, (s, r) => s + r.distance);
  int get totalRides => _rides.length;
  double get avgRideDistance => totalRides > 0 ? totalKm / totalRides : 0;
  double get avgRideDuration => totalRides > 0
      ? _rides.fold(0.0, (s, r) => s + r.duration) / totalRides
      : 0;
  double get longestRideKm => _rides.isEmpty
      ? 0
      : _rides.map((r) => r.distance).reduce((a, b) => a > b ? a : b);

  double kmInDays(int days) {
    final since = DateTime.now().subtract(Duration(days: days));
    return _rides
        .where((r) => r.startTime.isAfter(since))
        .fold(0.0, (s, r) => s + r.distance);
  }

  int longestStreak() {
    if (_rides.isEmpty) return 0;
    final dates = _rides
        .map((r) =>
            DateTime(r.startTime.year, r.startTime.month, r.startTime.day))
        .toSet()
        .toList()
      ..sort();
    if (dates.isEmpty) return 0;
    int maxStreak = 1, current = 1;
    for (int i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        current++;
      } else {
        if (current > maxStreak) maxStreak = current;
        current = 1;
      }
    }
    return current > maxStreak ? current : maxStreak;
  }

  int daysRiddenThisMonth() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    return _rides
        .map((r) =>
            DateTime(r.startTime.year, r.startTime.month, r.startTime.day))
        .where((d) => d.isAfter(monthStart.subtract(const Duration(days: 1))))
        .toSet()
        .length;
  }

  String mostCommonRidingTime() {
    if (_rides.isEmpty) return '–';
    int morning = 0, afternoon = 0, evening = 0;
    for (final r in _rides) {
      final h = r.startTime.hour;
      if (h < 12) {
        morning++;
      } else if (h < 18) {
        afternoon++;
      } else {
        evening++;
      }
    }
    if (morning >= afternoon && morning >= evening) return 'Jutro';
    if (afternoon >= evening) return 'Popoldne';
    return 'Večer';
  }

  String mostActiveWeekday() {
    if (_rides.isEmpty) return '–';
    const days = [
      'Ponedeljek',
      'Torek',
      'Sreda',
      'Četrtek',
      'Petek',
      'Sobota',
      'Nedelja'
    ];
    final counts = List.filled(7, 0);
    for (final r in _rides) {
      counts[r.startTime.weekday - 1]++;
    }
    int maxI = 0;
    for (int i = 1; i < 7; i++) {
      if (counts[i] > counts[maxI]) maxI = i;
    }
    return days[maxI];
  }

  Map<DateTime, int> rideCountByDay() {
    final map = <DateTime, int>{};
    for (final r in _rides) {
      final d = DateTime(r.startTime.year, r.startTime.month, r.startTime.day);
      map[d] = (map[d] ?? 0) + 1;
    }
    return map;
  }

  /// Kilometri po tednih (zadnjih 12 tednov). Index 0 = pred 12 tedni, 11 = prejšnji teden.
  List<double> kmPerWeekLast12Weeks() {
    final now = DateTime.now();
    final result = List.filled(12, 0.0);
    for (final r in _rides) {
      final start = DateTime(now.year, now.month, now.day);
      final diff = start
          .difference(
              DateTime(r.startTime.year, r.startTime.month, r.startTime.day))
          .inDays;
      final weekIndex = diff ~/ 7;
      if (weekIndex >= 0 && weekIndex < 12) {
        result[11 - weekIndex] += r.distance;
      }
    }
    return result;
  }

  /// Kilometri po mesecih (zadnjih 6 mesecev). Index 0 = pred 6 meseci, 5 = ta mesec.
  List<double> kmPerMonthLast6Months() {
    final now = DateTime.now();
    final result = List.filled(6, 0.0);
    for (final r in _rides) {
      final monthDiff =
          (now.year - r.startTime.year) * 12 + (now.month - r.startTime.month);
      if (monthDiff >= 0 && monthDiff < 6) {
        result[5 - monthDiff] += r.distance;
      }
    }
    return result;
  }

  /// Število voženj po mesecih (zadnjih 6 mesecev).
  List<int> ridesPerMonthLast6Months() {
    final now = DateTime.now();
    final result = List.filled(6, 0);
    for (final r in _rides) {
      final monthDiff =
          (now.year - r.startTime.year) * 12 + (now.month - r.startTime.month);
      if (monthDiff >= 0 && monthDiff < 6) {
        result[5 - monthDiff]++;
      }
    }
    return result;
  }

  /// Število voženj po dnevih v tednu (0 = Ponedeljek .. 6 = Nedelja).
  List<int> ridesPerWeekday() {
    final result = List.filled(7, 0);
    for (final r in _rides) {
      result[r.startTime.weekday - 1]++;
    }
    return result;
  }

  /// Oznake mesecev za zadnjih 6 mesecev (kratke: Jan, Feb, ...).
  static List<String> last6MonthLabels() {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Maj',
      'Jun',
      'Jul',
      'Avg',
      'Sep',
      'Okt',
      'Nov',
      'Dec'
    ];
    final now = DateTime.now();
    final list = <String>[];
    for (int i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      list.add(names[d.month - 1]);
    }
    return list;
  }

  double get co2SavedKg => totalKm * co2KgPerKm;
  double get fuelSavedL => totalKm / 100.0 * fuelLPer100Km;
  double get fuelSavedEur => fuelSavedL * fuelEurPerL;
}

// --- Main "Moj vpliv" screen: 3 section cards ---

class ImpactScreen extends StatelessWidget {
  const ImpactScreen({super.key});

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
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom -
                          kToolbarHeight -
                          32,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Moj vpliv',
                              style: AppTheme.titleMedium.copyWith(
                                fontSize: 36,
                                color: AppTheme.titleBlue,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            _SectionCard(
                              icon: Icons.trending_up,
                              title: 'Osebna analiza uspešnosti',
                              description:
                                  'Skupaj km, vožnje, povprečja in serije',
                              color: const Color(0xFF6B55D3),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PersonalPerformancePage(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _SectionCard(
                              icon: Icons.calendar_today,
                              title: 'Analiza navad in doslednosti',
                              description:
                                  'Dni v mesecu, čas vožnje, toplotna mapa',
                              color: const Color(0xFF0891B2),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const HabitAnalyticsPage(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _SectionCard(
                              icon: Icons.eco,
                              title: 'Vpliv na okolje',
                              description:
                                  'CO₂ prihranek, gorivo in izbira kolesa',
                              color: const Color(0xFF059669),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EnvironmentalImpactPage(),
                                ),
                              ),
                            ),
                          ],
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
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: color, size: 36),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textMedium,
                        height: 1.4,
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

// --- Detail page: Osebna analiza uspešnosti ---

class PersonalPerformancePage extends StatelessWidget {
  const PersonalPerformancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = ImpactStats(MockData.getAllRidesForAnalytics());
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.radialGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Osebna analiza uspešnosti',
                  style: AppTheme.titleSmall.copyWith(
                    color: AppTheme.titleBlue,
                    fontSize: 20,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _StatCard(
                      icon: Icons.straighten,
                      label: 'Skupaj kilometrov (vse življenje)',
                      value: '${stats.totalKm.toStringAsFixed(1)} km',
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.date_range,
                      label: 'Kilometri v zadnjih 7 dneh',
                      value: '${stats.kmInDays(7).toStringAsFixed(1)} km',
                      color: AppTheme.primaryLight,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.calendar_month,
                      label: 'Kilometri v zadnjih 30 dneh',
                      value: '${stats.kmInDays(30).toStringAsFixed(1)} km',
                      color: AppTheme.primaryLight,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.calendar_today,
                      label: 'Kilometri v zadnjih 365 dneh',
                      value: '${stats.kmInDays(365).toStringAsFixed(1)} km',
                      color: AppTheme.primaryLight,
                    ),
                    const SizedBox(height: 20),
                    _chartSectionTitle(
                        'Kilometri po tednih (zadnjih 12 tednov)'),
                    const SizedBox(height: 12),
                    _KmPerWeekLineChart(stats: stats),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.directions_bike,
                      label: 'Število voženj',
                      value: '${stats.totalRides}',
                      color: AppTheme.success,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.route,
                      label: 'Povprečna razdalja vožnje',
                      value: '${stats.avgRideDistance.toStringAsFixed(1)} km',
                      color: AppTheme.warning,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.access_time,
                      label: 'Povprečno trajanje vožnje',
                      value: '${stats.avgRideDuration.toStringAsFixed(0)} min',
                      color: AppTheme.warning,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.flag,
                      label: 'Najdaljša vožnja',
                      value: '${stats.longestRideKm.toStringAsFixed(1)} km',
                      color: AppTheme.error,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.local_fire_department,
                      label: 'Najdaljša serija',
                      value: '${stats.longestStreak()} zaporednih dni',
                      color: const Color(0xFFFF9800),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Detail page: Analiza navad in doslednosti ---

class HabitAnalyticsPage extends StatelessWidget {
  const HabitAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = ImpactStats(MockData.getAllRidesForAnalytics());
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.radialGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Analiza navad in doslednosti',
                  style: AppTheme.titleSmall.copyWith(
                    color: AppTheme.titleBlue,
                    fontSize: 18,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _StatCard(
                      icon: Icons.today,
                      label: 'Število dni z vožnjo ta mesec',
                      value: '${stats.daysRiddenThisMonth()}',
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.schedule,
                      label: 'Najpogostejši čas vožnje',
                      value: stats.mostCommonRidingTime(),
                      color: AppTheme.primaryLight,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.view_week,
                      label: 'Najbolj aktiven dan v tednu',
                      value: stats.mostActiveWeekday(),
                      color: AppTheme.success,
                    ),
                    const SizedBox(height: 20),
                    _chartSectionTitle('Vožnje po mesecih (zadnjih 6 mesecev)'),
                    const SizedBox(height: 12),
                    _RidesPerMonthBarChart(stats: stats),
                    const SizedBox(height: 20),
                    _chartSectionTitle('Vožnje po dnevih v tednu'),
                    const SizedBox(height: 12),
                    _RidesPerWeekdayBarChart(stats: stats),
                    const SizedBox(height: 20),
                    Text(
                      'Toplotna mapa (aktivnost po dnevih)',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _HeatmapCalendar(rideCountByDay: stats.rideCountByDay()),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Detail page: Vpliv na okolje ---

class EnvironmentalImpactPage extends StatelessWidget {
  const EnvironmentalImpactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = ImpactStats(MockData.getAllRidesForAnalytics());
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.radialGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Vpliv na okolje',
                  style: AppTheme.titleSmall.copyWith(
                    color: AppTheme.titleBlue,
                    fontSize: 20,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _StatCard(
                      icon: Icons.eco,
                      label: 'Ocenjene prihranjene CO₂',
                      value: '${stats.co2SavedKg.toStringAsFixed(1)} kg',
                      subtitle:
                          'Izračun: ${stats.totalKm.toStringAsFixed(0)} km × 0,15 kg CO₂/km (povprečni osebni avto)',
                      color: const Color(0xFF4CAF50),
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.directions_car_outlined,
                      label: 'Kolikokrat ste izbrali kolo namesto avta',
                      value: '${stats.totalRides}',
                      subtitle: 'Število vaših voženj z bikom',
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.local_gas_station,
                      label: 'Prihranek goriva',
                      value: '${stats.fuelSavedEur.toStringAsFixed(2)} €',
                      subtitle:
                          'Pribl. ${stats.fuelSavedL.toStringAsFixed(1)} L goriva (7 L/100 km, 1,70 €/L)',
                      color: AppTheme.warning,
                    ),
                    const SizedBox(height: 20),
                    _chartSectionTitle(
                        'Prihranek CO₂ po mesecih (zadnjih 6 mesecev)'),
                    const SizedBox(height: 12),
                    _Co2PerMonthBarChart(stats: stats),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Shared widgets ---

Widget _chartSectionTitle(String title) {
  return Text(
    title,
    style: AppTheme.bodyMedium.copyWith(
      fontWeight: FontWeight.w600,
      color: AppTheme.textDark,
    ),
  );
}

BarTouchData _barTouchData({
  required String suffix,
  int fractionDigits = 0,
}) {
  return BarTouchData(
    enabled: true,
    touchTooltipData: BarTouchTooltipData(
      tooltipRoundedRadius: 12,
      tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      tooltipMargin: 8,
      getTooltipItem: (group, groupIndex, rod, rodIndex) {
        final value = rod.toY.toStringAsFixed(fractionDigits);
        return BarTooltipItem(
          '$value$suffix',
          AppTheme.bodySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        );
      },
    ),
  );
}

LineTouchData _lineTouchData({
  required String suffix,
  int fractionDigits = 0,
}) {
  return LineTouchData(
    handleBuiltInTouches: true,
    touchTooltipData: LineTouchTooltipData(
      tooltipRoundedRadius: 12,
      tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      tooltipMargin: 8,
      getTooltipItems: (touchedSpots) {
        return touchedSpots.map((spot) {
          final value = spot.y.toStringAsFixed(fractionDigits);
          return LineTooltipItem(
            '$value$suffix',
            AppTheme.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          );
        }).toList();
      },
    ),
  );
}

class _KmPerWeekLineChart extends StatelessWidget {
  final ImpactStats stats;

  const _KmPerWeekLineChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final data = stats.kmPerWeekLast12Weeks();
    final maxY =
        (data.isEmpty ? 1.0 : data.reduce((a, b) => a > b ? a : b)) + 5;
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]));
    }
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 11,
          minY: 0,
          maxY: maxY,
          lineTouchData: _lineTouchData(suffix: ' km', fractionDigits: 1),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppTheme.textLight.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: AppTheme.caption.copyWith(color: AppTheme.textLight),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 2,
                getTitlesWidget: (value, meta) => Text(
                  'T${(value.toInt() + 1)}',
                  style: AppTheme.caption.copyWith(color: AppTheme.textLight),
                ),
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.primaryColor,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryColor.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RidesPerMonthBarChart extends StatelessWidget {
  final ImpactStats stats;

  const _RidesPerMonthBarChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final data = stats.ridesPerMonthLast6Months();
    final labels = ImpactStats.last6MonthLabels();
    final maxY =
        (data.isEmpty ? 1 : data.reduce((a, b) => a > b ? a : b)) + 2.0;
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          minY: 0,
          maxY: maxY,
          barTouchData: _barTouchData(suffix: ''),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppTheme.textLight.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: AppTheme.caption.copyWith(color: AppTheme.textLight),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i >= 0 && i < labels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        labels[i],
                        style: AppTheme.caption
                            .copyWith(color: AppTheme.textLight),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(6, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i].toDouble(),
                  color: AppTheme.primaryColor,
                  width: 20,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _RidesPerWeekdayBarChart extends StatelessWidget {
  final ImpactStats stats;

  const _RidesPerWeekdayBarChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    const labels = ['P', 'T', 'S', 'Č', 'P', 'S', 'N'];
    final data = stats.ridesPerWeekday();
    final maxY =
        (data.isEmpty ? 1 : data.reduce((a, b) => a > b ? a : b)) + 2.0;
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          minY: 0,
          maxY: maxY,
          barTouchData: _barTouchData(suffix: ''),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppTheme.textLight.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: AppTheme.caption.copyWith(color: AppTheme.textLight),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i >= 0 && i < 7) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        labels[i],
                        style: AppTheme.caption
                            .copyWith(color: AppTheme.textLight),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i].toDouble(),
                  color: const Color(0xFF0891B2),
                  width: 16,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _Co2PerMonthBarChart extends StatelessWidget {
  final ImpactStats stats;

  const _Co2PerMonthBarChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final kmPerMonth = stats.kmPerMonthLast6Months();
    final co2PerMonth = kmPerMonth.map((km) => km * co2KgPerKm).toList();
    final labels = ImpactStats.last6MonthLabels();
    final maxY = (co2PerMonth.isEmpty
            ? 1.0
            : co2PerMonth.reduce((a, b) => a > b ? a : b)) +
        2.0;
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          minY: 0,
          maxY: maxY,
          barTouchData: _barTouchData(suffix: ' kg', fractionDigits: 1),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppTheme.textLight.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}',
                  style: AppTheme.caption.copyWith(color: AppTheme.textLight),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i >= 0 && i < labels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        labels[i],
                        style: AppTheme.caption
                            .copyWith(color: AppTheme.textLight),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(6, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: co2PerMonth[i],
                  color: const Color(0xFF059669),
                  width: 20,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _HeatmapCalendar extends StatelessWidget {
  final Map<DateTime, int> rideCountByDay;

  const _HeatmapCalendar({required this.rideCountByDay});

  @override
  Widget build(BuildContext context) {
    const int weeksCount = 12;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 84));
    final mondayOffset = (start.weekday - 1);
    final startMonday = start.subtract(Duration(days: mondayOffset));
    int maxCount = 1;
    for (final c in rideCountByDay.values) {
      if (c > maxCount) maxCount = c;
    }
    // Ensure at least 4 so we show multiple intensity levels even with few data points
    if (maxCount < 4) maxCount = 4;

    Color colorFor(int weekIndex, int dayOfWeek) {
      final day = startMonday.add(Duration(days: weekIndex * 7 + dayOfWeek));
      final key = DateTime(day.year, day.month, day.day);
      final count = rideCountByDay[key] ?? 0;
      if (count == 0) return Colors.grey.shade200;
      final intensity = count / maxCount;
      if (intensity <= 0.25) {
        return AppTheme.primaryColor.withValues(alpha: 0.3);
      }
      if (intensity <= 0.5) return AppTheme.primaryColor.withValues(alpha: 0.5);
      if (intensity <= 0.75) {
        return AppTheme.primaryColor.withValues(alpha: 0.75);
      }
      return AppTheme.primaryColor;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.neomorphicRaised(borderRadius: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Manj',
                  style: AppTheme.caption.copyWith(color: AppTheme.textLight)),
              Row(
                children: [
                  Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 4),
                  Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 4),
                  Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(2))),
                ],
              ),
              Text('Več',
                  style: AppTheme.caption.copyWith(color: AppTheme.textLight)),
            ],
          ),
          const SizedBox(height: 12),
          Table(
            children: [
              for (int dayRow = 0; dayRow < 7; dayRow++)
                TableRow(
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text(
                        ['P', 'T', 'S', 'Č', 'P', 'S', 'N'][dayRow],
                        style: AppTheme.caption
                            .copyWith(color: AppTheme.textLight),
                      ),
                    ),
                    for (int weekCol = 0; weekCol < weeksCount; weekCol++)
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          height: 24,
                          decoration: BoxDecoration(
                            color: colorFor(weekCol, dayRow),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.04),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: AppTheme.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle!,
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.textLight,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}
