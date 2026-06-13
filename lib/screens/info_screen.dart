import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/disease_model.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Disease Guide'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B4332), Color(0xFF40916C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Text('📚', style: TextStyle(fontSize: 40)),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Maize Disease Guide',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Learn to identify and manage the 3 most common maize leaf diseases.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Disease cards
          ...DiseaseDatabase.diseases.map(
            (disease) => _DiseaseExpandable(disease: disease),
          ),

          // About CNN Section
          const SizedBox(height: 8),
          _AboutCNNCard(),
        ],
      ),
    );
  }
}

// ── Disease Expandable Card ────────────────────────────────────────────────────
class _DiseaseExpandable extends StatefulWidget {
  final DiseaseInfo disease;
  const _DiseaseExpandable({required this.disease});

  @override
  State<_DiseaseExpandable> createState() => _DiseaseExpandableState();
}

class _DiseaseExpandableState extends State<_DiseaseExpandable> {
  bool _expanded = false;

  Color get _color => Color(widget.disease.colorHex);

  Color get _severityColor {
    switch (widget.disease.severity) {
      case 'High':
        return AppTheme.errorRed;
      case 'Medium':
        return AppTheme.warningOrange;
      case 'None':
        return AppTheme.successGreen;
      default:
        return AppTheme.accentAmber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _expanded ? _color.withValues(alpha: 0.4) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _expanded
                    ? _color.withValues(alpha: 0.06)
                    : Colors.transparent,
                borderRadius: _expanded
                    ? const BorderRadius.vertical(top: Radius.circular(18))
                    : BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        widget.disease.iconEmoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.disease.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.deepBrown,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _severityColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${widget.disease.severity} Severity',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _severityColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: _color,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: _color.withValues(alpha: 0.2)),
                  const SizedBox(height: 8),
                  Text(
                    widget.disease.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5C4033),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (widget.disease.symptoms.isNotEmpty) ...[
                    _SubSection(
                      title: '🔍 Key Symptoms',
                      color: _color,
                      items: widget.disease.symptoms.take(3).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (widget.disease.suggestions.isNotEmpty)
                    _SubSection(
                      title: '💊 Quick Remedies',
                      color: AppTheme.successGreen,
                      items: widget.disease.suggestions.take(3).toList(),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SubSection extends StatelessWidget {
  final String title;
  final Color color;
  final List<String> items;

  const _SubSection({
    required this.title,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.arrow_right_rounded, color: color, size: 18),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF5C4033),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── About CNN Card ─────────────────────────────────────────────────────────────
class _AboutCNNCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.deepBrown.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.deepBrown.withValues(alpha: 0.15)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 8),
              Text(
                'How the CNN Model Works',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.deepBrown,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Our Convolutional Neural Network (CNN) is trained on thousands of labeled maize leaf images. It extracts visual features: color, texture, shape of lesions, through multiple convolutional layers to classify diseases with high accuracy.',
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF5C4033),
              height: 1.6,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _Tag('TensorFlow Lite'),
              _Tag('MobileNetV2'),
              _Tag('Transfer Learning'),
              _Tag('~95% Accuracy'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }
}
