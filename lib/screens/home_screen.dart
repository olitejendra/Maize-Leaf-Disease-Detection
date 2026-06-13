import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'scan_screen.dart';
import 'history_screen.dart';
import 'info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _cardsController;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _cardsFade;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _heroFade = CurvedAnimation(parent: _heroController, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroController, curve: Curves.easeOut));
    _cardsFade = CurvedAnimation(
      parent: _cardsController,
      curve: Curves.easeOut,
    );

    _heroController.forward().then((_) => _cardsController.forward());
  }

  @override
  void dispose() {
    _heroController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppTheme.primaryGreen,
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroBanner(
                fadeAnim: _heroFade,
                slideAnim: _heroSlide,
              ),
              collapseMode: CollapseMode.parallax,
            ),
            title: const Text('MaizeScan'),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InfoScreen()),
                ),
              ),
            ],
          ),

          // ── Body Content ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _cardsFade,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel('Quick Actions'),
                    const SizedBox(height: 12),
                    _QuickActionsRow(),
                    const SizedBox(height: 28),
                    const _SectionLabel('Disease Guide'),
                    const SizedBox(height: 12),
                    _DiseaseGuideGrid(),
                    const SizedBox(height: 28),
                    const _SectionLabel('Tips & Alerts'),
                    const SizedBox(height: 12),
                    const _TipsBanner(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ── FAB Scan Button ───────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScanScreen()),
        ),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.document_scanner_rounded, size: 22),
        label: const Text(
          'Scan Leaf',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ── Hero Banner ────────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;

  const _HeroBanner({required this.fadeAnim, required this.slideAnim});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF40916C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative corn leaf pattern
          const Positioned(
            right: -20,
            top: -10,
            child: Opacity(
              opacity: 0.12,
              child: Text('🌽', style: TextStyle(fontSize: 160)),
            ),
          ),
          const Positioned(
            left: -10,
            bottom: -20,
            child: Opacity(
              opacity: 0.08,
              child: Text('🌿', style: TextStyle(fontSize: 130)),
            ),
          ),
          // Main hero text
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
              child: FadeTransition(
                opacity: fadeAnim,
                child: SlideTransition(
                  position: slideAnim,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentAmber.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'AI-Powered Detection',
                          style: TextStyle(
                            color: AppTheme.accentAmber,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Detect Maize\nDiseases Instantly',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Scan a leaf photo and get diagnosis\n& treatment suggestions in seconds.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
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

// ── Section Label ──────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppTheme.deepBrown,
        letterSpacing: 0.2,
      ),
    );
  }
}

// ── Quick Actions ──────────────────────────────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
        icon: Icons.camera_alt_rounded,
        label: 'Camera\nScan',
        color: AppTheme.primaryGreen,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScanScreen()),
        ),
      ),
      _ActionItem(
        icon: Icons.photo_library_rounded,
        label: 'Gallery\nUpload',
        color: AppTheme.lightGreen,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ScanScreen(fromGallery: true),
          ),
        ),
      ),
      _ActionItem(
        icon: Icons.history_rounded,
        label: 'Scan\nHistory',
        color: AppTheme.warningOrange,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HistoryScreen()),
        ),
      ),
      _ActionItem(
        icon: Icons.menu_book_rounded,
        label: 'Disease\nGuide',
        color: AppTheme.deepBrown,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InfoScreen()),
        ),
      ),
    ];

    return Row(
      children: actions
          .map(
            (a) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: a,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Disease Guide Grid ─────────────────────────────────────────────────────────
class _DiseaseGuideGrid extends StatelessWidget {
  final _diseases = const [
    {
      'name': 'Northern Leaf Blight',
      'emoji': '🍃',
      'severity': 'High',
      'color': 0xFF6B7C4A,
    },
    {
      'name': 'Gray Leaf Spot',
      'emoji': '🌫️',
      'severity': 'High',
      'color': 0xFF8C8C7A,
    },
    {
      'name': 'Common Rust',
      'emoji': '🦀',
      'severity': 'Medium',
      'color': 0xFFB85C38,
    },
    {
      'name': 'Healthy Leaf',
      'emoji': '✅',
      'severity': 'None',
      'color': 0xFF2D6A4F,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: _diseases.length,
      itemBuilder: (context, i) {
        final d = _diseases[i];
        final color = Color(d['color'] as int);
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InfoScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      d['emoji'] as String,
                      style: const TextStyle(fontSize: 22),
                    ),
                    _SeverityBadge(d['severity'] as String),
                  ],
                ),
                Text(
                  d['name'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final String severity;
  const _SeverityBadge(this.severity);

  Color get _color {
    switch (severity) {
      case 'High':
        return AppTheme.errorRed;
      case 'Medium':
        return AppTheme.warningOrange;
      case 'Low':
        return AppTheme.accentAmber;
      default:
        return AppTheme.successGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        severity,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: _color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Tips Banner ────────────────────────────────────────────────────────────────
class _TipsBanner extends StatelessWidget {
  const _TipsBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentAmber.withValues(alpha: 0.2),
            AppTheme.accentAmber.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accentAmber.withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Text('💡', style: TextStyle(fontSize: 32)),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Best Scanning Tips',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppTheme.deepBrown,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'For accurate results, scan in good natural light. Hold the camera 15–20 cm from the leaf. Ensure the lesion covers most of the frame.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5C4033),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
