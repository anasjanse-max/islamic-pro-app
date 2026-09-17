import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class PrayerService {
  static const String _baseUrl = 'https://api.aladhan.com/v1';

  static Future<Position> getCurrentLocation() async {
    final serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location service is turned off.');
    }

    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission was denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. '
            'Please enable it from app settings.',
      );
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    ).timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        throw Exception(
          'Could not get your current location.',
        );
      },
    );
  }

  static Future<String> getCityName(
      double latitude,
      double longitude,
      ) async {
    return 'Your Location';
  }

  static Future<Map<String, dynamic>> getPrayerTimes(
      double latitude,
      double longitude,
      ) async {
    final uri = Uri.parse(
      '$_baseUrl/timings'
          '?latitude=$latitude'
          '&longitude=$longitude'
          '&method=1'
          '&school=1',
    );

    final response = await http.get(uri).timeout(
      const Duration(seconds: 20),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Prayer API failed with status '
            '${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid prayer API response.');
    }

    if (decoded['code'] != 200) {
      throw Exception('Prayer timings could not be loaded.');
    }

    final data = decoded['data'];

    if (data is! Map) {
      throw Exception('Invalid prayer data.');
    }

    final timings = data['timings'];

    if (timings is! Map) {
      throw Exception('Prayer timings are missing.');
    }

    String hijriDate = '';

    final dateInfo = data['date'];

    if (dateInfo is Map) {
      final hijri = dateInfo['hijri'];

      if (hijri is Map) {
        final day = hijri['day']?.toString() ?? '';

        String monthName = '';

        final month = hijri['month'];

        if (month is Map) {
          monthName = month['en']?.toString() ?? '';
        }

        final year = hijri['year']?.toString() ?? '';

        final parts = <String>[
          day,
          monthName,
          year,
        ].where((item) => item.isNotEmpty).toList();

        hijriDate = parts.join(' ');
      }
    }

    return {
      'timings': Map<String, dynamic>.from(timings),
      'hijriDate': hijriDate,
      'date': dateInfo,
    };
  }
}