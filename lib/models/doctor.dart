import 'package:hive/hive.dart';

part 'doctor.g.dart';

@HiveType(typeId: 0)
class Doctor extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String specialty;

  @HiveField(3)
  String avatarUrl;

  @HiveField(4)
  List<WorkDay> workDays;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.avatarUrl,
    required this.workDays,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
      specialty: json['specialty'],
      avatarUrl: json['avatarUrl'],
      workDays: (json['workDays'] as List)
          .map((workDay) => WorkDay.fromJson(workDay))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'avatarUrl': avatarUrl,
      'workDays': workDays.map((workDay) => workDay.toJson()).toList(),
    };
  }
}

@HiveType(typeId: 1)
class WorkDay extends HiveObject {
  @HiveField(0)
  int weekday;

  @HiveField(1)
  List<String> slots;

  WorkDay({
    required this.weekday,
    required this.slots,
  });

  factory WorkDay.fromJson(Map<String, dynamic> json) {
    return WorkDay(
      weekday: json['weekday'],
      slots: List<String>.from(json['slots']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekday': weekday,
      'slots': slots,
    };
  }
}