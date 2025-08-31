import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/doctor.dart';
import 'data_service.dart';

class SeedService {
  static Future<void> loadSeedData() async {
    try {
      // Check if data already exists
      final existingDoctors = DataService.getAllDoctors();
      if (existingDoctors.isNotEmpty) {
        print('Seed data already loaded');
        return;
      }

      // Load JSON file
      final String jsonString = await rootBundle.loadString('lib/assets/seed/seed_doctors.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Parse doctors
      final List<dynamic> doctorsJson = jsonData['doctors'];
      final List<Doctor> doctors = doctorsJson
          .map((json) => Doctor.fromJson(json))
          .toList();

      // Save to Hive
      await DataService.saveDoctors(doctors);

      print('Seed data loaded successfully: ${doctors.length} doctors');
    } catch (e) {
      print('Error loading seed data: $e');
    }
  }
}