import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../utils/app_theme.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import '../widgets/station_card.dart';
import '../widgets/bottom_nav.dart';
import 'qr_scan_screen.dart';
import 'profile_screen.dart';
import 'achievements_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final List<BikeStation> stations = MockData.getBikeStations();
  BikeStation? selectedStation;

  late AnimationController _mapAnimationController;
  final MapController _mapController = MapController();

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _mapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _mapAnimationController.forward();
  }

  @override
  void dispose() {
    _mapAnimationController.dispose();
    super.dispose();
  }

  void _onStationSelected(BikeStation station) {
    setState(() {
      selectedStation = station;
    });

    _showStationDetails(station);
  }

  void _zoomIn() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom + 1,
    );
  }

  void _zoomOut() {
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom - 1,
    );
  }

  void _showStationDetails(BikeStation station) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.35,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.7),
              offset: const Offset(0, -4),
              blurRadius: 8,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 4),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.textMedium,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  station.name,
                  style: AppTheme.titleSmall.copyWith(
                    color: AppTheme.titleBlue,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${station.distance} km stran',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildStatItem(
                      icon: Icons.pedal_bike,
                      value: '${station.availableBikes}',
                      label: 'Prosta kolesa',
                      color: AppTheme.success,
                    ),
                    const SizedBox(width: 32),
                    _buildStatItem(
                      icon: Icons.local_parking,
                      value: '${station.totalSlots - station.availableBikes}',
                      label: 'Postavljeno',
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: AppTheme.neomorphicButton(
                    color: AppTheme.primaryColor,
                    borderRadius: 16,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                QRScanScreen(station: station),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.qr_code_scanner, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Skeniraj QR kodo',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              value,
              style: AppTheme.displaySmall.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.caption.copyWith(
            color: AppTheme.textLight,
          ),
        ),
      ],
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
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
        break;
      case 2:
        Navigator.push(
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
                child: Column(
                  children: [
                    Text(
                      'Poiščite vožnjo',
                      style: AppTheme.titleMedium.copyWith(
                        fontSize: 36,
                        color: AppTheme.titleBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Izberite postajo za začetek',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textLight,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: AppTheme.neomorphicRaised(borderRadius: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: const MapOptions(
                            initialCenter: LatLng(45.8021, 15.1685),
                            initialZoom: 13.0,
                            minZoom: 10.0,
                            maxZoom: 18.0,
                          ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.pedalup',
                        ),
                        MarkerLayer(
                          markers: stations.map((station) {
                            return Marker(
                              width: selectedStation == station ? 60.0 : 48.0,
                              height: selectedStation == station ? 60.0 : 48.0,
                              point: LatLng(station.latitude, station.longitude),
                              child: GestureDetector(
                                onTap: () => _onStationSelected(station),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selectedStation == station
                                          ? AppTheme.primaryColor
                                          : AppTheme.primaryColor.withValues(alpha: 0.3),
                                      width: selectedStation == station ? 3 : 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: selectedStation == station
                                            ? AppTheme.primaryColor.withValues(alpha: 0.4)
                                            : Colors.black.withValues(alpha: 0.2),
                                        blurRadius: selectedStation == station ? 12 : 6,
                                        spreadRadius: selectedStation == station ? 2 : 1,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.pedal_bike,
                                          size: selectedStation == station ? 24 : 20,
                                          color: AppTheme.primaryColor,
                                        ),
                                        Text(
                                          '${station.availableBikes}',
                                          style: AppTheme.caption.copyWith(
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    // Zoom buttons
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Column(
                        children: [
                          Container(
                            decoration: AppTheme.neomorphicRaised(borderRadius: 8),
                            child: Column(
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _zoomIn,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey,
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: AppTheme.primaryColor,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _zoomOut,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(8),
                                      bottomRight: Radius.circular(8),
                                    ),
                                    child: const SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: Icon(
                                        Icons.remove,
                                        color: AppTheme.primaryColor,
                                        size: 24,
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
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: stations.length,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemBuilder: (context, index) {
                    final station = stations[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: StationCard(
                        station: station,
                        isSelected: selectedStation == station,
                        onTap: () => _onStationSelected(station),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mapAnimationController.reset();
    _mapAnimationController.forward();
  }
}