class DiseaseInfo {
  final String id;
  final String name;
  final String scientificName;
  final String severity; // 'Low', 'Medium', 'High'
  final String description;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> suggestions;
  final String iconEmoji;
  final int colorHex;
  final bool isHealthy;
  final String prevention;
  final String treatment;

  const DiseaseInfo({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.severity,
    required this.description,
    required this.symptoms,
    required this.causes,
    required this.suggestions,
    required this.iconEmoji,
    required this.colorHex,
    this.isHealthy = false,
    this.prevention = '',
    this.treatment = '',
  });
}

class DiseaseDatabase {
  static const List<DiseaseInfo> diseases = [
    DiseaseInfo(
      id: 'northern_blight',
      name: 'Northern Leaf Blight',
      scientificName: 'Exserohilum turcicum',
      severity: 'High',
      description:
          'A fungal disease causing large, cigar-shaped gray-green to tan lesions on leaves, significantly reducing photosynthesis and yield.',
      symptoms: [
        'Long, elliptical gray-green lesions (up to 15cm)',
        'Lesions turn tan/brown as they mature',
        'Appears first on lower leaves, spreads upward',
        'Dark green water-soaked margins around lesions',
        'Severe blighting of whole leaves in humid conditions',
      ],
      causes: [
        'Fungus Exserohilum turcicum',
        'Cool temperatures (18–27°C) with high humidity',
        'Infected crop debris in soil',
        'Overhead irrigation promoting leaf wetness',
      ],
      suggestions: [
        'Apply fungicides containing propiconazole or azoxystrobin at first sign',
        'Plant resistant hybrids with Ht genes',
        'Practice crop rotation (non-host crops for 1–2 years)',
        'Remove and destroy infected plant residues after harvest',
        'Improve field drainage to reduce humidity',
        'Scout fields regularly from silking stage onwards',
      ],
      iconEmoji: '🍃',
      colorHex: 0xFF6B7C4A,
    ),
    DiseaseInfo(
      id: 'gray_leaf_spot',
      name: 'Gray Leaf Spot',
      scientificName: 'Cercospora zeae-maydis',
      severity: 'High',
      description:
          'A common fungal disease producing rectangular lesions with distinct parallel edges, often severely damaging in high-humidity regions.',
      symptoms: [
        'Small, rectangular tan to gray lesions',
        'Lesions have distinct parallel edges (vein-limited)',
        'Yellow halo may surround lesions',
        'Lesions coalesce causing large dead areas',
        'Premature leaf death in severe cases',
      ],
      causes: [
        'Fungus Cercospora zeae-maydis',
        'Warm temperatures (25–30°C) with high humidity',
        'Extended leaf wetness periods (12+ hours)',
        'Continuous maize cropping without rotation',
        'Minimum tillage leaving infected debris',
      ],
      suggestions: [
        'Use fungicides (strobilurins + triazoles) preventively',
        'Plant resistant or tolerant hybrids',
        'Rotate maize with soybeans or other non-host crops',
        'Increase plant spacing to improve air circulation',
        'Apply balanced fertilization — avoid excess nitrogen',
        'Time planting to avoid peak humidity periods',
      ],
      iconEmoji: '🌫️',
      colorHex: 0xFF8C8C7A,
    ),
    DiseaseInfo(
      id: 'common_rust',
      name: 'Common Rust',
      scientificName: 'Puccinia sorghi',
      severity: 'Medium',
      description:
          'A widespread fungal disease identifiable by brick-red powdery pustules on both leaf surfaces, reducing photosynthetic capacity.',
      symptoms: [
        'Circular to elongated brick-red/brown pustules',
        'Pustules appear on both upper and lower leaf surfaces',
        'Pustules rupture releasing reddish-brown spores',
        'Heavily infected leaves yellow and die prematurely',
        'Lesions turn dark brown/black as season progresses',
      ],
      causes: [
        'Obligate fungal pathogen Puccinia sorghi',
        'Cool, moist conditions (16–23°C)',
        'Wind-dispersed urediniospores from other hosts',
        'Susceptible hybrids in areas with early infection',
      ],
      suggestions: [
        'Apply mancozeb or triazole fungicides at early infection',
        'Plant rust-resistant hybrids where available',
        'Monitor fields from V6 stage — early action is key',
        'Avoid irrigation late in the day to reduce leaf wetness',
        'Ensure adequate potassium nutrition for plant strength',
        'Remove volunteer maize plants that harbor disease',
      ],
      iconEmoji: '🦀',
      colorHex: 0xFFB85C38,
    ),
    DiseaseInfo(
      id: 'healthy',
      name: 'Healthy Leaf',
      scientificName: 'No pathogen detected',
      severity: 'None',
      description:
          'The leaf appears healthy with no signs of fungal, bacterial, or viral disease. Continue standard agronomic practices.',
      symptoms: [
        'Uniform green coloration throughout',
        'No lesions, pustules, or discoloration',
        'Normal leaf texture and surface',
        'Proper leaf width and length for growth stage',
      ],
      causes: [],
      suggestions: [
        'Continue regular scouting every 7–10 days',
        'Maintain balanced fertilization program',
        'Monitor weather forecasts for disease-favorable conditions',
        'Keep records of field history for future reference',
        'Ensure proper plant density for good airflow',
        'Practice preventive crop management',
      ],
      iconEmoji: '✅',
      colorHex: 0xFF2D6A4F,
    ),
  ];

  static DiseaseInfo getById(String id) {
    return diseases.firstWhere(
      (d) => d.id == id,
      orElse: () => diseases.last,
    );
  }
}
