import 'package:flutter/material.dart';
import '../../models/doctor.dart';
import '../../services/data_service.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  List<Doctor> _doctors = [];
  List<Doctor> _filteredDoctors = [];
  String _searchQuery = '';
  String? _selectedSpecialty;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  void _loadDoctors() {
    _doctors = DataService.getAllDoctors();
    _filteredDoctors = _doctors;
    setState(() {});
  }

  void _filterDoctors() {
    _filteredDoctors = _doctors.where((doctor) {
      final matchesSearch = doctor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          doctor.specialty.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesSpecialty = _selectedSpecialty == null || doctor.specialty == _selectedSpecialty;
      return matchesSearch && matchesSpecialty;
    }).toList();
    setState(() {});
  }

  List<String> get _specialties {
    return _doctors.map((doctor) => doctor.specialty).toSet().toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Doctors'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search doctors...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _filterDoctors();
              },
            ),
          ),
          // Specialty filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Filter by specialty',
                border: OutlineInputBorder(),
              ),
              value: _selectedSpecialty,
              items: [
                const DropdownMenuItem(value: null, child: Text('All Specialties')),
                ..._specialties.map((specialty) =>
                    DropdownMenuItem(value: specialty, child: Text(specialty))),
              ],
              onChanged: (value) {
                _selectedSpecialty = value;
                _filterDoctors();
              },
            ),
          ),
          const SizedBox(height: 16),
          // Doctors list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredDoctors.length,
              itemBuilder: (context, index) {
                final doctor = _filteredDoctors[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(doctor.avatarUrl),
                      onBackgroundImageError: (_, __) {},
                      child: const Icon(Icons.person), // Fallback
                    ),
                    title: Text(doctor.name),
                    subtitle: Text(doctor.specialty),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/doctor_profile',
                        arguments: doctor.id,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}