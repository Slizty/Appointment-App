import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 4)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String phoneNumber;

  @HiveField(2)
  String? name;

  @HiveField(3)
  UserRole role;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  String? doctorId;

  User({
    required this.id,
    required this.phoneNumber,
    this.name,
    required this.role,
    required this.createdAt,
    this.doctorId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'doctorId': doctorId,
    };
  }
}

@HiveType(typeId: 5)
enum UserRole {
  @HiveField(0)
  patient,

  @HiveField(1)
  doctor,
}