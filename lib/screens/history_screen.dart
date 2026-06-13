import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/disease_model.dart';
import 'result_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // Demo scan history entries
  static final _history = [
    _HistoryEntry(
      disease: DiseaseDatabase.diseases[0],
      confidence: 92.4,
      date: 'Today, 10:32 AM',
      fieldNote: 'Field A - North Block',
    ),
    _HistoryEntry(
      disease: DiseaseDatabase.diseases[2],
      confidence: 87.1,
      date: 'Yesterday, 3:15 PM',
      fieldNote: 'Field B - Row 12',
    ),
    _HistoryEntry(
      disease: DiseaseDatabase.diseases[3],
      confidence: 98.2,
      date: 'Jun 5, 2026',
      fieldNote: 'Greenhouse Sample',
    ),
    _HistoryEntry(
      disease: DiseaseDatabase.diseases[1],
      confidence: 79.6,
      date: 'Jun 3, 2026',
      fieldNote: 'Field C - South Wing',
    ),
    _HistoryEntry(
      disease: DiseaseDatabase.diseases[0],
      confidence: 95.0,
      date: 'Jun 1, 2026',
      fieldNote: 'Field A - East Block',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Scan History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Banner
          _StatsBanner(history: _history),

          // History List
          Expanded(
            child: _history.isEmpty
                ? _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _history.length,
                    itemBuilder: (context, i) => _HistoryCard(
                      entry: _history[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResultScreen(
                            disease: _history[i].disease,
                            confidence: _history[i].confidence,
                          ),
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

class _HistoryEntry {
  final DiseaseInfo disease;
  final double confidence;
  final String date;
  final String fieldNote;

  const _HistoryEntry({
    required this.disease,
    required this.confidence,
    required this.date,
    required this.fieldNote,
  });
}

// ── Stats Banner ───────────────────────────────────────────────────────────────
class _StatsBanner extends StatelessWidget {
  final List<_HistoryEntry> history;
  const _StatsBanner({required this.history});

  @override
  Widget build(BuildContext context) {
    final diseaseCount =
        history.where((h) => h.disease.severity != 'None').length;
    final healthyCount = history.length - diseaseCount;
    final avgConf = history.isEmpty
        ? 0.0
        : history.fold(0.0, (s, h) => s + h.confidence) / history.length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _StatCell(label: 'Total Scans', value: '${history.length}'),
          _Divider(),
          _StatCell(
              label: 'Diseases Found',
              value: '$diseaseCount',
              valueColor: AppTheme.errorRed),
          _Divider(),
          _StatCell(
              label: 'Healthy',
              value: '$healthyCount',
              valueColor: AppTheme.successGreen),
          _Divider(),
          _StatCell(
              label: 'Avg Confidence', value: '${avgConf.toStringAsFixed(0)}%'),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatCell({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: valueColor ?? AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.grey.shade200,
    );
  }
}

// ── History Card ───────────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final _HistoryEntry entry;
  final VoidCallback onTap;

  const _HistoryCard({required this.entry, required this.onTap});

  Color get _severityColor {
    switch (entry.disease.severity) {
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            // Disease Icon
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Color(entry.disease.colorHex).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  entry.disease.iconEmoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.disease.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.deepBrown,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.fieldNote,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 11, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        entry.date,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right side - confidence + severity
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _severityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    entry.disease.severity == 'None'
                        ? 'Healthy'
                        : '${entry.disease.severity} Risk',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _severityColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${entry.confidence.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(entry.disease.colorHex),
                  ),
                ),
                Text(
                  'confidence',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade300, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📋', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'No Scans Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.deepBrown,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your scan history will appear here\nafter your first leaf scan.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
