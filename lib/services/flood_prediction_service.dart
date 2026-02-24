class FloodPredictionService {
  static final FloodPredictionService _instance = FloodPredictionService._internal();

  factory FloodPredictionService() {
    return _instance;
  }

  FloodPredictionService._internal();

  /// Simulates fetching predictive data from BigQuery ML ARIMA_PLUS models.
  Future<Map<String, dynamic>> getTodayFloodRisk() async {
    // Simulate a network/query delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Hardcoded mock response for the "High Risk" alert demonstration
    return {
      "riskLevel": "High",
      "predictedRainfall": "55.2mm",
      "trend": "rising",
      "confidence": "89%",
      "zone": "Downtown District, Zone 4"
    };
  }
}
