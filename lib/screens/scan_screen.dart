import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/disease_model.dart';
import 'result_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class ScanScreen extends StatefulWidget {
  final bool fromGallery;
  const ScanScreen({super.key, this.fromGallery = false});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  bool _isAnalyzing = false;
  int _analyzeStep = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  final List<String> _analyzeSteps = [
    'Preprocessing image...',
    'Extracting leaf features...',
    'Running CNN model...',
    'Analyzing patterns...',
    'Generating report...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim =
        Tween<double>(begin: 0.95, end: 1.05).animate(_pulseController);

    if (widget.fromGallery) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pickFromGallery());
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1080,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _takePhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1080,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  // ignore: unused_element
  void _showImagePickerSimulated() {
    // Simulates image selection for UI demo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Connect image_picker package to enable real photo selection.',
        ),
        backgroundColor: AppTheme.primaryGreen,
        action: SnackBarAction(
          label: 'Demo Scan',
          textColor: AppTheme.accentAmber,
          onPressed: _startAnalysis,
        ),
      ),
    );
  }

  Future<void> _startAnalysis() async {
    if (_selectedImage == null) {
      // Demo mode — navigate with hardcoded data (keep existing demo behavior)
      setState(() {
        _isAnalyzing = true;
        _analyzeStep = 0;
      });
      for (int i = 0; i < _analyzeSteps.length; i++) {
        await Future.delayed(const Duration(milliseconds: 700));
        if (mounted) setState(() => _analyzeStep = i);
      }
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() => _isAnalyzing = false);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResultScreen(
                disease: DiseaseDatabase.diseases[0],
                confidence: 92.4,
                imagePath: null,
              ),
            ));
      }
      return;
    }

    // ── Real API call ──────────────────────────────────────────────────────────
    setState(() {
      _isAnalyzing = true;
      _analyzeStep = 0;
    });

    // Animate the steps while the API call runs in parallel
    final apiCall = ApiService.predictDisease(_selectedImage!);

    for (int i = 0; i < _analyzeSteps.length - 1; i++) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) setState(() => _analyzeStep = i + 1);
    }

    try {
      final result = await apiCall; // wait for the real response
      if (!mounted) return;
      setState(() => _isAnalyzing = false);

      // Map API result → DiseaseModel for ResultScreen
      final disease = DiseaseInfo(
        id: result.disease.toLowerCase().replaceAll(' ', '_'),
        name: result.disease,
        scientificName: '',
        severity: result.severity,
        description: result.description,
        symptoms: [],
        causes: [],
        suggestions: result.treatment.isNotEmpty
            ? result.treatment
                .split('.')
                .where((s) => s.trim().isNotEmpty)
                .toList()
            : [],
        iconEmoji: result.isHealthy ? '✅' : '🍃',
        colorHex: result.isHealthy ? 0xFF2D6A4F : 0xFF6B7C4A,
        isHealthy: result.isHealthy,
        prevention: result.prevention,
        treatment: result.treatment,
      );

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              disease: disease,
              confidence: result.confidence,
              imagePath: _selectedImage!.path,
            ),
          ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analysis failed: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Scan Maize Leaf'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isAnalyzing ? _buildAnalyzingUI() : _buildScanUI(),
    );
  }

  // ── Scanning UI ──────────────────────────────────────────────────────────────
  Widget _buildScanUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Image Preview Area
          _ImagePreviewArea(
            image: _selectedImage,
            onTap: _takePhoto,
          ),
          const SizedBox(height: 24),

          // Instruction Card
          _InstructionCard(),
          const SizedBox(height: 28),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _ScanButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Take Photo',
                  isPrimary: true,
                  onTap: _takePhoto,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ScanButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  isPrimary: false,
                  onTap: _pickFromGallery,
                ),
              ),
            ],
          ),

          if (_selectedImage != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startAnalysis,
                icon: const Icon(Icons.biotech_rounded),
                label: const Text('Analyze Disease'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentAmber,
                  foregroundColor: AppTheme.deepBrown,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ),
          ],

          // Demo button for UI preview
          if (_selectedImage == null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _startAnalysis,
              icon: const Icon(Icons.play_circle_outline,
                  color: AppTheme.lightGreen),
              label: const Text(
                'Run Demo Scan →',
                style: TextStyle(
                  color: AppTheme.lightGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Analyzing UI ─────────────────────────────────────────────────────────────
  Widget _buildAnalyzingUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.lightGreen.withValues(alpha: 0.3),
                      AppTheme.primaryGreen.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: AppTheme.lightGreen,
                    width: 3,
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🌽', style: TextStyle(fontSize: 48)),
                    Text(
                      'AI',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryGreen,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Analyzing Your Leaf',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.deepBrown,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Our CNN model is processing the image\nto detect diseases accurately.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            // Steps Progress
            ...List.generate(_analyzeSteps.length, (i) {
              final isDone = i < _analyzeStep;
              final isCurrent = i == _analyzeStep;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDone
                      ? AppTheme.successGreen.withValues(alpha: 0.1)
                      : isCurrent
                          ? AppTheme.primaryGreen.withValues(alpha: 0.08)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDone
                        ? AppTheme.successGreen.withValues(alpha: 0.3)
                        : isCurrent
                            ? AppTheme.primaryGreen.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isDone
                          ? const Icon(Icons.check_circle_rounded,
                              color: AppTheme.successGreen, size: 20)
                          : isCurrent
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppTheme.primaryGreen,
                                  ),
                                )
                              : Icon(Icons.radio_button_unchecked,
                                  color: Colors.grey.shade300, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _analyzeSteps[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isCurrent ? FontWeight.w700 : FontWeight.w500,
                        color: isDone
                            ? AppTheme.successGreen
                            : isCurrent
                                ? AppTheme.primaryGreen
                                : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Image Preview Area ─────────────────────────────────────────────────────────
class _ImagePreviewArea extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;

  const _ImagePreviewArea({required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 240,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.file(image!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_rounded,
                      color: AppTheme.primaryGreen,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tap to capture or upload\na maize leaf image',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Supports JPG, PNG • Max 10MB',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Instruction Card ───────────────────────────────────────────────────────────
class _InstructionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tips = [
      ('📸', 'Good lighting', 'Natural daylight gives best results'),
      ('🎯', 'Focus on lesion', 'Center the diseased area in frame'),
      ('📏', 'Right distance', 'Hold 15–20 cm from the leaf'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How to get accurate results',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.deepBrown,
            ),
          ),
          const SizedBox(height: 12),
          ...tips.map(
            (t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Text(t.$1, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.$2,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.deepBrown,
                        ),
                      ),
                      Text(
                        t.$3,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
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

// ── Scan Button ────────────────────────────────────────────────────────────────
class _ScanButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ScanButton({
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary
                ? AppTheme.primaryGreen
                : AppTheme.primaryGreen.withValues(alpha: 0.3),
          ),
          boxShadow: [
            if (isPrimary)
              BoxShadow(
                color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : AppTheme.primaryGreen,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isPrimary ? Colors.white : AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
