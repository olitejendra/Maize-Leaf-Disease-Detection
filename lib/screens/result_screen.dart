import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/disease_model.dart';

class ResultScreen extends StatefulWidget {
  final DiseaseInfo disease;
  final double confidence;
  final String? imagePath;

  const ResultScreen({
    super.key,
    required this.disease,
    required this.confidence,
    this.imagePath,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _activeTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color get _diseaseColor => Color(widget.disease.colorHex);

  Color get _severityColor {
    switch (widget.disease.severity) {
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
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          // ── Result Hero ────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: _diseaseColor,
            leading: IconButton(
              icon:
                  const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_border_rounded,
                    color: Colors.white),
                onPressed: () {},
              ),
            ],
            title: const Text('Diagnosis Result'),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildResultHero(),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // ── Confidence Bar ─────────────────────────────────
                _ConfidenceCard(
                  confidence: widget.confidence,
                  color: _diseaseColor,
                ),

                // ── Tab Bar ────────────────────────────────────────
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryGreen,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppTheme.primaryGreen,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Symptoms'),
                      Tab(text: 'Treatment'),
                    ],
                  ),
                ),

                // ── Tab Content ────────────────────────────────────
                IndexedStack(
                  index: _activeTab,
                  children: [
                    _OverviewTab(disease: widget.disease),
                    _SymptomsTab(disease: widget.disease),
                    _TreatmentTab(disease: widget.disease),
                  ],
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),

      // ── Bottom Action Bar ──────────────────────────────────────────
      bottomNavigationBar: _BottomActionBar(
        onScanAgain: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildResultHero() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _diseaseColor,
            _diseaseColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background emoji watermark
          Positioned(
            right: -20,
            bottom: -10,
            child: Opacity(
              opacity: 0.15,
              child: Text(
                widget.disease.iconEmoji,
                style: const TextStyle(fontSize: 150),
              ),
            ),
          ),
          // Content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Leaf image thumbnail if available
                  if (widget.imagePath != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(widget.imagePath!),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _severityColor.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _severityColor.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                size: 12, color: _severityColor),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.disease.severity} Severity',
                              style: TextStyle(
                                color: _severityColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.disease.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.disease.scientificName,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Confidence Card ────────────────────────────────────────────────────────────
class _ConfidenceCard extends StatelessWidget {
  final double confidence;
  final Color color;

  const _ConfidenceCard({required this.confidence, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Detection Confidence',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.deepBrown,
                      ),
                    ),
                    Text(
                      '${confidence.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: confidence / 100,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  confidence >= 90
                      ? '✅ High confidence — reliable diagnosis'
                      : confidence >= 70
                          ? '⚠️ Moderate confidence — consider re-scan'
                          : '❌ Low confidence — please re-scan',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
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

// ── Overview Tab ───────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final DiseaseInfo disease;
  const _OverviewTab({required this.disease});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(disease.iconEmoji,
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    const Text(
                      'About This Disease',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.deepBrown,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  disease.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5C4033),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Causes
          if (disease.causes.isNotEmpty) ...[
            const Text(
              'Primary Causes',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.deepBrown,
              ),
            ),
            const SizedBox(height: 10),
            ...disease.causes.map(
              (c) => _BulletItem(text: c, color: AppTheme.warningOrange),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Symptoms Tab ───────────────────────────────────────────────────────────────
class _SymptomsTab extends StatelessWidget {
  final DiseaseInfo disease;
  const _SymptomsTab({required this.disease});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.warningOrange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppTheme.warningOrange.withValues(alpha: 0.25)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_rounded,
                    color: AppTheme.warningOrange, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Compare these symptoms with your leaf for confirmation.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.warningOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(
            disease.symptoms.length,
            (i) => _NumberedSymptom(
              number: i + 1,
              text: disease.symptoms[i],
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberedSymptom extends StatelessWidget {
  final int number;
  final String text;

  const _NumberedSymptom({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF3D2B1F),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Treatment Tab ──────────────────────────────────────────────────────────────
class _TreatmentTab extends StatelessWidget {
  final DiseaseInfo disease;
  const _TreatmentTab({required this.disease});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.successGreen.withValues(alpha: 0.12),
                  AppTheme.lightGreen.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppTheme.successGreen.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Text('🌱', style: TextStyle(fontSize: 24)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Follow these recommendations for best results. Consult a local agronomist if symptoms persist.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.successGreen,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...disease.suggestions.map(
            (s) => _SuggestionCard(text: s),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String text;
  const _SuggestionCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: AppTheme.lightGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF3D2B1F),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bullet Item ────────────────────────────────────────────────────────────────
class _BulletItem extends StatelessWidget {
  final String text;
  final Color color;

  const _BulletItem({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF3D2B1F),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Action Bar ──────────────────────────────────────────────────────────
class _BottomActionBar extends StatelessWidget {
  final VoidCallback onScanAgain;
  const _BottomActionBar({required this.onScanAgain});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onScanAgain,
              icon: const Icon(Icons.refresh_rounded,
                  color: AppTheme.primaryGreen),
              label: const Text(
                'Scan Again',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppTheme.primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save_alt_rounded),
              label: const Text('Save Report'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
