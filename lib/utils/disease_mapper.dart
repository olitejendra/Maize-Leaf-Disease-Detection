import '../models/disease_model.dart';

class DiseaseMapper {
  static DiseaseInfo fromApi(String name, double confidence) {
    return DiseaseDatabase.diseases.firstWhere(
      (d) => d.name.toLowerCase() == name.toLowerCase(),
      orElse: () => DiseaseDatabase.diseases[0],
    );
  }
}
