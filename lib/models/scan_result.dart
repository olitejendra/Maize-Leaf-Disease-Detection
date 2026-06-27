import '../services/api_service.dart';

class ScanResult {
  final String imagePath;
  final PredictionResult prediction;
  final DateTime scannedAt;

  ScanResult({
    required this.imagePath,
    required this.prediction,
    required this.scannedAt,
  });

  Map<String, dynamic> toJson() => {
        'imagePath': imagePath,
        'disease': prediction.disease,
        'confidence': prediction.confidence,
        'isHealthy': prediction.isHealthy,
        'severity': prediction.severity,
        'description': prediction.description,
        'treatment': prediction.treatment,
        'prevention': prediction.prevention,
        'scannedAt': scannedAt.toIso8601String(),
      };
}
