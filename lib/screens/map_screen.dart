import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../utils/app_theme.dart';
import '../utils/reservation_service.dart';
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
  final ReservationService _reservationService = ReservationService();
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
    _reservationService.addListener(_onReservationChanged);
  }

  @override
  void dispose() {
    _reservationService.removeListener(_onReservationChanged);
    _mapAnimationController.dispose();
    super.dispose();
  }

  void _onReservationChanged() {
    if (mounted) {
      setState(() {});
    }
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

  int _availableBikesFor(BikeStation station) {
    final reservedCount = _reservationService.isReservedForStation(station.id) ? 1 : 0;
    final adjusted = station.availableBikes - reservedCount;
    return adjusted < 0 ? 0 : adjusted;
  }

  String? _reservationTextFor(BikeStation station) {
    if (_reservationService.isReservedForStation(station.id)) {
      return 'Rezervirano: ${_reservationService.formattedRemainingTime}';
    }
    return null;
  }

  void _toggleReservation(BikeStation station) {
    if (_reservationService.isReservedForStation(station.id)) {
      _reservationService.cancelReservation();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rezervacija preklicana.'),
          backgroundColor: AppTheme.primaryDark,
        ),
      );
      return;
    }

    if (_availableBikesFor(station) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Na tej postaji trenutno ni prostih koles za rezervacijo.'),
          backgroundColor: AppTheme.primaryDark,
        ),
      );
      return;
    }

    _reservationService.reserveStation(station.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kolo na postaji ${station.name} je rezervirano za 10 minut.'),
        backgroundColor: AppTheme.primaryDark,
      ),
    );
  }

  void _showStationDetails(BikeStation station) {
    showGeneralDialog(
      context: context,
      barrierLabel: 'Podrobnosti postaje',
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: ListenableBuilder(
              listenable: _reservationService,
              builder: (context, _) {
                final availableBikes = _availableBikesFor(station);
                final isReservedHere = _reservationService.isReservedForStation(station.id);
                final hasReservationElsewhere =
                    _reservationService.hasActiveReservation && !isReservedHere;
                final canReserveHere = availableBikes > 0 || isReservedHere;

                return Container(
                  height: MediaQuery.of(context).size.height * 0.43,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(Colors.white, AppTheme.primaryColor, 0.10)!,
                        Color.lerp(Colors.white, AppTheme.primaryLight, 0.06)!,
                        Colors.white,
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.06),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        offset: const Offset(0, 12),
                        blurRadius: 28,
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
                        if (isReservedHere) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  size: 16,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Rezervirano še ${_reservationService.formattedRemainingTime}',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _buildStatItem(
                              icon: Icons.pedal_bike,
                              value: '$availableBikes',
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
                        const Spacer(),
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: !canReserveHere
                                ? AppTheme.primaryColor.withValues(alpha: 0.05)
                                : isReservedHere
                                    ? Color.lerp(Colors.white, AppTheme.primaryColor, 0.15)
                                    : Color.lerp(Colors.white, AppTheme.primaryLight, 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.primaryColor.withValues(
                                alpha: canReserveHere ? 0.10 : 0.06,
                              ),
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: canReserveHere ? () => _toggleReservation(station) : null,
                              borderRadius: BorderRadius.circular(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isReservedHere ? Icons.close_rounded : Icons.lock_clock_outlined,
                                    color: canReserveHere
                                        ? AppTheme.primaryColor
                                        : AppTheme.textLight,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    !canReserveHere
                                        ? 'Ni prostih koles'
                                        : isReservedHere
                                            ? 'Prekliči rezervacijo'
                                            : hasReservationElsewhere
                                                ? 'Rezerviraj tukaj za 10 min'
                                                : 'Rezerviraj kolo za 10 min',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: canReserveHere
                                          ? AppTheme.primaryColor
                                          : AppTheme.textLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
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
                );
              },
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
            _DismissibleBottomPopup(
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
                                          '${_availableBikesFor(station)}',
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
                        availableBikes: _availableBikesFor(station),
                        isSelected: selectedStation == station,
                        reservationText: _reservationTextFor(station),
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

class _DismissibleBottomPopup extends StatefulWidget {
  const _DismissibleBottomPopup({
    required this.child,
    required this.onDismiss,
  });

  final Widget child;
  final VoidCallback onDismiss;

  @override
  State<_DismissibleBottomPopup> createState() => _DismissibleBottomPopupState();
}

class _DismissibleBottomPopupState extends State<_DismissibleBottomPopup> {
  double _dragOffset = 0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (_) {
        setState(() {
          _isDragging = true;
        });
      },
      onVerticalDragUpdate: (details) {
        setState(() {
          _dragOffset = (_dragOffset + details.delta.dy).clamp(0.0, 240.0);
        });
      },
      onVerticalDragEnd: (details) {
        final shouldDismiss =
            _dragOffset > 120 || details.primaryVelocity != null && details.primaryVelocity! > 900;
        if (shouldDismiss) {
          widget.onDismiss();
          return;
        }
        setState(() {
          _dragOffset = 0;
          _isDragging = false;
        });
      },
      onVerticalDragCancel: () {
        setState(() {
          _dragOffset = 0;
          _isDragging = false;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: _isDragging ? 0 : 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _dragOffset, 0),
        child: widget.child,
      ),
    );
  }
}