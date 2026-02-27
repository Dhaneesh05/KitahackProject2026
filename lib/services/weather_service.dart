import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Encapsulates everything the ForecastCard needs to display live weather.
class WeatherForecast {
  final String locality;
  final double precipitation;
  final String riskLevel;
  final Color riskColor;
  final int filledSegments; // 1=Low, 3=Moderate, 5=High

  const WeatherForecast({
    required this.locality,
    required this.precipitation,
    required this.riskLevel,
    required this.riskColor,
    required this.filledSegments,
  });

  factory WeatherForecast.fromPrecipitation(double mm, String locality) {
    final String level;
    final Color color;
    final int segments;

    if (mm > 20.0) {
      level = 'High';
      color = Colors.redAccent;
      segments = 5;
    } else if (mm >= 5.0) {
      level = 'Moderate';
      color = Colors.orange;
      segments = 3;
    } else {
      level = 'Low';
      color = Colors.green.shade500;
      segments = 1;
    }

    return WeatherForecast(
      locality: locality,
      precipitation: mm,
      riskLevel: level,
      riskColor: color,
      filledSegments: segments,
    );
  }
}

class WeatherService {
  static const _forecastBase = 'https://api.open-meteo.com/v1/forecast';

  /// Gets the user's current position, reverse-geocodes it to a city name,
  /// and fetches today's precipitation from Open-Meteo.
  static Future<WeatherForecast> getLiveForecast() async {
    // 1. Get GPS coordinates ─────────────────────────────────────────────────
    final Position pos = await _getPosition();

    // 2. Reverse-geocode lat/lng → city name (via Open-Meteo geocoding API)
    final String locality = await _reverseGeocode(pos.latitude, pos.longitude);

    // 3. Fetch today's predicted precipitation from Open-Meteo ───────────────
    final double precipitation = await _fetchPrecipitation(pos.latitude, pos.longitude);

    return WeatherForecast.fromPrecipitation(precipitation, locality);
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  static Future<Position> _getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
    );
  }

  static Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      const apiKey = '***REMOVED***';
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=$lat,$lng&result_type=locality|administrative_area_level_2'
        '&key=$apiKey',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final results = json['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final components = results[0]['address_components'] as List<dynamic>;
          String city = '';
          String state = '';
          for (final c in components) {
            final types = (c['types'] as List<dynamic>).cast<String>();
            if (types.contains('locality') && city.isEmpty) {
              city = c['long_name'] as String;
            } else if (types.contains('administrative_area_level_1') && state.isEmpty) {
              state = c['long_name'] as String;
            }
          }
          if (city.isNotEmpty && state.isNotEmpty) return '$city, $state';
          if (city.isNotEmpty) return city;
          // Fallback: first part of formatted_address
          final formatted = results[0]['formatted_address'] as String? ?? '';
          if (formatted.isNotEmpty) return formatted.split(',').first.trim();
        }
      }
    } catch (_) {}
    return 'Your Location';
  }

  static Future<double> _fetchPrecipitation(double lat, double lng) async {
    final uri = Uri.parse(
      '$_forecastBase?latitude=$lat&longitude=$lng'
      '&daily=precipitation_sum&timezone=auto'
      '&forecast_days=1',
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('Open-Meteo API error: ${res.statusCode}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;
    final list = (daily['precipitation_sum'] as List<dynamic>);
    return (list.first as num?)?.toDouble() ?? 0.0;
  }

  /// Returns hourly precipitation (mm) as FlSpot-ready (x, y) pairs
  /// for the past 24 hours through the next 48 hours.
  static Future<List<({double x, double y, String label})>> getHourlyPrecipitation() async {
    final Position pos = await _getPosition();
    final uri = Uri.parse(
      '$_forecastBase?latitude=${pos.latitude}&longitude=${pos.longitude}'
      '&hourly=precipitation&past_days=1&forecast_days=2&timezone=auto',
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) throw Exception('Open-Meteo error: ${res.statusCode}');

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>;
    final times = (hourly['time'] as List<dynamic>).cast<String>();
    final values = (hourly['precipitation'] as List<dynamic>);

    // Find the index of "now" so we centre the visible window around it
    final now = DateTime.now();
    int nowIndex = 0;
    for (int i = 0; i < times.length; i++) {
      final t = DateTime.tryParse(times[i]);
      if (t != null && t.isAfter(now)) { nowIndex = i; break; }
    }

    // Take 12h back + 36h forward (48 points total)
    final start = (nowIndex - 12).clamp(0, times.length - 1);
    final end   = (nowIndex + 36).clamp(0, times.length - 1);

    return List.generate(end - start, (i) {
      final idx = start + i;
      final t = DateTime.tryParse(times[idx]);
      final label = t != null ? '${t.hour.toString().padLeft(2, '0')}:00' : '';
      return (x: i.toDouble(), y: (values[idx] as num?)?.toDouble() ?? 0.0, label: label);
    });
  }
}
