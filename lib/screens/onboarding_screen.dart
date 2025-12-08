import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../utils/app_theme.dart';
import 'map_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: Icons.eco_outlined,
      title: 'Trajnostna\nMobilnost',
      subtitle: 'Majhne vožnje, velik vpliv',
      description: 'Vsak korak na pedalu prispeva\nk bolj zelenemu jutrišnjemu',
    ),
    OnboardingData(
      icon: Icons.emoji_events_outlined,
      title: 'Zaslužite si\nNagrade',
      subtitle: 'Dosežek odklenjen',
      description: 'Spremenite svojo dnevno pot\nv pomembne mejnike',
    ),
    OnboardingData(
      icon: Icons.route_outlined,
      title: 'Najdite svojo\nPot',
      subtitle: 'Čaka vas svoboda',
      description: 'Odkrijte mesto skozi\nnovo perspektivo',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToMap();
    }
  }

  void _navigateToMap() {
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
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
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
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: TextButton(
                    onPressed: _navigateToMap,
                    child: Text(
                      'Preskoči',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textLight,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),
              // Bottom controls
              Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _pages.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor: AppTheme.primaryColor,
                        dotColor: AppTheme.primaryColor.withOpacity(0.2),
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 3,
                        spacing: 12,
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _onNextPressed,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? 'Začnimo'
                              : 'Nadaljuj',
                          style: AppTheme.bodyMedium.copyWith(
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w500,
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

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Icon(
              data.icon,
              size: 60,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 64),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 42,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
              height: 1.2,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            data.subtitle,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.primaryColor,
              letterSpacing: 2,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textMedium,
              height: 1.8,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}
